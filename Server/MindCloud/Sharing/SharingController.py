import json
import random
import string
from tornado import gen
from Cache.MindcloudCache import MindcloudCache
from Logging import Log
from Sharing.SharingRecord import SharingRecord
from Storage.DatabaseFactory import DatabaseFactory
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer
from Storage.StorageUtils import StorageUtils

__author__ = 'afathali'


class SharingController:
    __log = Log.log()

    SECRET_LENGTH = 8
    SUBSCRIBER_ID_KEY = 'subscriber_id'
    SUBSCRIBER_COLLECTION_NAME_KEY = 'shared_collection_name'
    SHARING_SPACE_SECRET_KEY = 'sharing_secret'
    __cache = MindcloudCache()

    @staticmethod
    def __generate_sharing_secret():
        chars = string.ascii_uppercase + string.digits
        return ''.join(random.choice(chars) for x in range(SharingController.SECRET_LENGTH))

    #implementation detail
    @staticmethod
    @gen.engine
    def add_subscriber(user_id, collection_name, sharing_secret, callback):
        """
        Adds a subscriber with user id and collection and sharing secret
        to the subscribers db. user_id and collection_name uniquely identify
        the subscriber and maps it to the sharing_secret of the sharing space

        This is implementation detail. Do not use for actual logic
        """

        if sharing_secret is None or user_id is None or collection_name is None:
            SharingController.__log.warning('Sharing Controller - A value was none in add subscriber')
            callback()

        else:
            subscriber_collection = DatabaseFactory.get_subscribers_collection()
            subscriber_record = {SharingController.SUBSCRIBER_ID_KEY: user_id,
                                 SharingController.SUBSCRIBER_COLLECTION_NAME_KEY: collection_name,
                                 SharingController.SHARING_SPACE_SECRET_KEY: sharing_secret}
            yield gen.Task(subscriber_collection.insert, subscriber_record)
            #add it to the cache to, since we get synchronization for free. this should be
            #optimal
            yield gen.Task(SharingController.__cache.set_subscriber_info,
                           user_id, collection_name, sharing_secret)
            callback()

    @staticmethod
    @gen.engine
    def get_sharing_secret_from_subscriber_info(user_id, collection_name, callback):
        """
        Retrieves the sharing secret of a sharing space, uniquely identified
        by the user_id and collection name.

        -Returns:
            - The secret is passed to the callback. If there is no such
            subscriber then None is passed
        """
        #first look up in the cache
        sharing_secret = yield gen.Task(SharingController.__cache.get_subscriber_info,
                                        user_id, collection_name)
        if sharing_secret is not None:
            #this means we have looked up in the DB before and the sharing secret wasn't there
            if sharing_secret == 'false':
                callback(None)
            else:
                callback(sharing_secret)

        #if cache miss it look up in the DB
        else:
            subscriber_collection = DatabaseFactory.get_subscribers_collection()
            query = {SharingController.SUBSCRIBER_ID_KEY: user_id,
                     SharingController.SUBSCRIBER_COLLECTION_NAME_KEY: collection_name}
            subscriber_record_cursor = yield gen.Task(subscriber_collection.find, query)
            result_count = len(subscriber_record_cursor[0][0])
            #if user_id and collection_name are not uniquely identifying the
            #share space then we are in trouble
            if result_count >= 2:
                SharingController.__log.warning(
                    'SharingController - More than two sharing info found for: ' + user_id + ' - ' + collection_name)
                result_count = 0

            if not result_count:
                SharingController.__log.info(
                    'SharingController - No sharing record found for user %s and collection %s' % (
                        user_id, collection_name))
                #cache the lack of info so we don't hit the DB every time we ask for a non existing sharing record
                yield gen.Task(SharingController.__cache.set_subscriber_info, user_id, collection_name, 'false')
                callback(None)

            else:
                subscriber_record_bson = subscriber_record_cursor[0][0][0]
                sharing_secret = subscriber_record_bson[SharingController.SHARING_SPACE_SECRET_KEY]
                if sharing_secret is None or not len(sharing_secret):
                    SharingController.__log.info(
                        'SharingController - Sharing secret is None or Empty for user %s and collection %s' % (
                            user_id, collection_name))
                    yield gen.Task(SharingController.__cache.set_subscriber_info, user_id, collection_name, 'false')
                    callback(None)
                else:
                    #set the cache for future usage
                    yield gen.Task(SharingController.__cache.set_subscriber_info,
                                   user_id, collection_name, sharing_secret)
                    #now call back to the user
                    callback(sharing_secret)

    @staticmethod
    @gen.engine
    def get_sharing_record_from_subscriber_info(user_id, collection_name, callback):
        """
        Provides the sharing record from a subscribers user_id and
         the subscribed collection_name in his own account.

         -Returns:
            -The sharing record object or None
        """
        sharing_secret = yield gen.Task(SharingController.get_sharing_secret_from_subscriber_info,
                                        user_id,
                                        collection_name)
        if sharing_secret is None or not len(sharing_secret):
            SharingController.__log.info(
                'SharingController - sharing secret is none or empty for user %s and collection %s' % (
                    user_id, collection_name))
            callback(None)
        else:
            sharing_info = yield gen.Task(SharingController.get_sharing_record_by_secret,
                                          sharing_secret)
            if sharing_info is None:
                SharingController.__log.info(
                    'SharingController - Sharing info is none for %s and collection %s' % (user_id, collection_name))
            callback(sharing_info)


    #implementation detail
    @staticmethod
    @gen.engine
    def remove_subscriber(user_id, collection_name, callback):
        """
        Removes the subscriber from the subscribers collection.
        user_id and collection_name identify a sharing space uniquely.

        This is implementation detail. Do not use for actual logic, does
        not guarauntee  updates to sharing record
        """
        subscriber_collection = DatabaseFactory.get_subscribers_collection()
        query = {SharingController.SUBSCRIBER_ID_KEY: user_id,
                 SharingController.SUBSCRIBER_COLLECTION_NAME_KEY: collection_name}
        yield gen.Task(subscriber_collection.remove, query)
        #remove from cache too
        yield gen.Task(SharingController.__cache.remove_subscriber_info,
                       user_id, collection_name)
        if callback is not None:
            callback()


    #implementation detail
    @staticmethod
    @gen.engine
    def remove_all_subscribers(sharing_secret, callback):
        """
        Removes all the subscribers to a sharing space identified by
        a sharing_secret

        implementation detail, does not gurantee sharing record updates.
        do not use for logic
        """
        subscriber_collection = DatabaseFactory.get_subscribers_collection()
        query = {SharingController.SHARING_SPACE_SECRET_KEY: sharing_secret}
        #first get the sharing record
        sharing_record = yield gen.Task(SharingController.get_sharing_record_by_secret,
                                        sharing_secret)

        if sharing_record is None:
            SharingController.__log.info('SharingController - Sharing record is None for secret %s' % sharing_secret)
            callback(None)
        else:
            subscribers_list = sharing_record.get_subscribers()
            for subscriber_info in subscribers_list:
                subscriber_id = subscriber_info[0]
                subscriber_collection_name = subscriber_info[1]
                #just remove it from the cache
                SharingController.__cache.remove_subscriber_info(subscriber_id,
                                                                 subscriber_collection_name, callback=None)

            #remove everything from the db in one shot
            yield gen.Task(subscriber_collection.remove, query)
            callback()

    @staticmethod
    @gen.engine
    def create_sharing_record(user_id, collection_name, callback):
        """
        Returns:
            -The sharing secret key for the create sharing record
        """

        #check to see whether that particular collection has been shared before
        exsisting_sharing_secret = yield gen.Task(SharingController.get_sharing_secret_from_subscriber_info,
                                                  user_id, collection_name)
        if exsisting_sharing_secret is not None:
            SharingController.__log.info(
                'SharingController - exsiting sharing record found for user %s and collection %s' % (
                    user_id, collection_name))
            callback(exsisting_sharing_secret)

        #we couldn't find the sharing secret so create a new sharing record
        else:
            sharing_secret = SharingController.__generate_sharing_secret()
            sharing_collection = DatabaseFactory.get_sharing_collection()
            sharing_record = {SharingRecord.SECRET_KEY: sharing_secret,
                              SharingRecord.OWNER_KEY: user_id,
                              SharingRecord.COLLECTION_NAME_KEY: collection_name,
                              SharingRecord.SUBSCIRBERS_KEY: [(user_id, collection_name)]}

            #add sharing record to the cache
            yield gen.Task(sharing_collection.insert, sharing_record)
            yield gen.Task(SharingController.add_subscriber, user_id, collection_name,
                           sharing_secret)

            #cache both the subscription info and the sharing record itself
            sharing_record_json = json.dumps(sharing_record)
            yield gen.Task(SharingController.__cache.set_sharing_record,
                           sharing_secret, sharing_record_json)
            callback(sharing_secret)

    @staticmethod
    @gen.engine
    def get_sharing_record_by_secret(sharing_secret, callback):
        """
        Returns:
            -A Sharing record object containing information of the
            sharing space with the sharing_secret and None if the
            sharing record for the specified sharing secret does not
            exist
        """
        #try the cache
        sharing_record_json_str = yield gen.Task(SharingController.__cache.get_sharing_record,
                                                 sharing_secret)
        #cache hit
        if sharing_record_json_str is not None:
            if sharing_record_json_str == 'false':
                callback(None)
            else:
                sharing_record_obj = json.loads(sharing_record_json_str)
                sharing_record = SharingRecord(
                    sharing_record_obj[SharingRecord.SECRET_KEY],
                    sharing_record_obj[SharingRecord.OWNER_KEY],
                    sharing_record_obj[SharingRecord.COLLECTION_NAME_KEY],
                    sharing_record_obj[SharingRecord.SUBSCIRBERS_KEY])
                callback(sharing_record)

        #cache miss
        else:
            sharing_collection = DatabaseFactory.get_sharing_collection()
            query = {SharingRecord.SECRET_KEY: sharing_secret}
            sharing_records_cursor = yield gen.Task(sharing_collection.find, query)
            result_count = len(sharing_records_cursor[0][0])
            #if we have more sharing spaces with this sharing secret
            #something is horribly wrong
            if result_count >= 2:
                SharingController.__log.warning(
                    'SharingController - More than two sharing info found for: %s' % sharing_secret)
                yield gen.Task(SharingController.__cache.set_sharing_record, sharing_secret, 'false')
                callback(None)

            if not result_count:
                SharingController.__log.warning('SharingController - no sharing info found for: %s' % sharing_secret)
                yield gen.Task(SharingController.__cache.set_sharing_record, sharing_secret, 'false')
                callback(None)

            else:
                #FIXME: is there a better way to these in asyncMongo other
                #than these ugly indicies
                sharing_record_bson = sharing_records_cursor[0][0][0]
                try:
                    sharing_record = SharingRecord(
                        sharing_record_bson[SharingRecord.SECRET_KEY],
                        sharing_record_bson[SharingRecord.OWNER_KEY],
                        sharing_record_bson[SharingRecord.COLLECTION_NAME_KEY],
                        sharing_record_bson[SharingRecord.SUBSCIRBERS_KEY])
                    callback(sharing_record)
                except Exception:
                    SharingController.__log.warning(
                        'SharingController - corrupted sharing info found for: %s' % sharing_secret)
                    yield gen.Task(SharingController.__cache.set_sharing_record, sharing_secret, 'false')
                    callback(None)

    @staticmethod
    @gen.engine
    def get_sharing_record_by_owner_info(user_id, collection_name, callback):
        """
        An overload of the above funtion.

        -Args:
            -``user_id``: The id of the owner of the collection
            -``collection_name``: The name of the owners collection
        """
        sharing_secret = yield gen.Task(SharingController.get_sharing_secret_from_subscriber_info,
                                        user_id, collection_name)
        if sharing_secret is None:
            SharingController.__log.info(
                'SharingController - No Sharing secret found for owner %s and collection %s' % (
                    user_id, collection_name))
            callback(None)
        else:
            sharing_record = yield gen.Task(SharingController.get_sharing_record_by_secret,
                                            sharing_secret)
            if sharing_record is None:
                SharingController.__log.info(
                    'SharingController - No Sharing info found for sharing secret %s' % sharing_secret)
                callback(None)
            else:
                callback(sharing_record)

    @staticmethod
    @gen.engine
    def remove_sharing_record_by_secret(sharing_secret, callback):
        """
        Removes a sharing record identified by the sharing_secret

        Returns:
            - void. The callback will be called
        """
        sharing_collection = DatabaseFactory.get_sharing_collection()
        query = {SharingRecord.SECRET_KEY: sharing_secret}
        #first remove subscribers
        yield gen.Task(SharingController.remove_all_subscribers, sharing_secret)
        #the collection itself
        yield gen.Task(sharing_collection.remove, query)
        #remove the record from the cache too
        yield gen.Task(SharingController.__cache.remove_sharing_record, sharing_secret)
        callback()

    @staticmethod
    @gen.engine
    def remove_sharing_record_by_owner_info(owner_id, collection_name, callback):
        """
        Overload of remove sharing collection

        Returns:
            -void. The callback will be called
        """
        sharing_secret = yield gen.Task(SharingController.get_sharing_secret_from_subscriber_info,
                                        owner_id, collection_name)
        if sharing_secret is None:
            SharingController.__log.info(
                'SharingController - No Sharing secret found for owner %s and collection %s' % (
                    owner_id, collection_name))
            callback()
        else:
            yield gen.Task(SharingController.remove_sharing_record_by_secret, sharing_secret)
            callback()

    @staticmethod
    @gen.engine
    def __update_sharing_record(sharing_record, callback):
        """
        updates the sharing recrod in the mongoDB database.
        The passed in sharing record will replace the one
        in the db

        This method is very dangerous as the user must make sure that
        they also update the subscribers collection in mongo
        """
        sharing_collection = DatabaseFactory.get_sharing_collection()
        doc_key = {SharingRecord.SECRET_KEY: sharing_record.get_sharing_secret()}
        doc_content = sharing_record.toDictionary()
        sharing_record_json = sharing_record.to_json_str()
        yield gen.Task(sharing_collection.update, doc_key, doc_content)
        #update the cache
        yield gen.Task(SharingController.__cache.set_sharing_record,
                       sharing_record.get_sharing_secret(), sharing_record_json)
        callback()

    @staticmethod
    @gen.engine
    def __rename_subscriber_collection_name(user_id, old_collection_name,
                                            new_collection_name, sharing_secret,
                                            callback):
        """
        Updates the subscriber table for the user with user_id with the new name
        for its collection
        """

        sharing_collection = DatabaseFactory.get_subscribers_collection()
        key = {SharingController.SUBSCRIBER_ID_KEY: user_id,
               SharingController.SUBSCRIBER_COLLECTION_NAME_KEY: old_collection_name}
        new_content = {SharingController.SUBSCRIBER_ID_KEY: user_id,
                       SharingController.SUBSCRIBER_COLLECTION_NAME_KEY: new_collection_name,
                       SharingController.SHARING_SPACE_SECRET_KEY: sharing_secret}
        yield gen.Task(sharing_collection.update, key, new_content)

        #remove the old content from cache
        yield gen.Task(SharingController.__cache.remove_subscriber_info,
                       user_id, old_collection_name)
        #add new content to the cache
        yield gen.Task(SharingController.__cache.set_subscriber_info,
                       user_id, new_collection_name, sharing_secret)
        #TODO I can probalby use the replace cmd in memcache to reduce these two calls to one
        callback()

    @staticmethod
    @gen.engine
    def subscribe_to_sharing_space(user_id, sharing_secret, callback):
        """
        Subscribes the user with the user_id to the sharing space
        with sharing_secret. The user will be added to the sharing list
        and both his account and mindcloud db will be updated

        -Args:
            -``user_id``: The id of the user who wants to subscribe
            -``sharing_secret``: The sharing secret identifying the
            sharing space

        -Returns:
            - The name of the shared collection in the subscribers account.
            None otherwise
        """

        #Get the sharing space
        sharing_record = yield gen.Task(SharingController.get_sharing_record_by_secret,
                                        sharing_secret)

        if sharing_record is None:
            SharingController.__log.info(
                'SharingController - no sharing info found for sharing secret %s' % sharing_secret)
            callback(None)
        else:
            #if we are already subscribed return
            existing_collection_name = \
                sharing_record.get_collection_name_for_subscriber(user_id)
            if existing_collection_name is not None:
                callback(existing_collection_name)
            else:
                #Get the sharedCollection and figure out the name
                original_collection_name = sharing_record.get_owner_collection_name()
                dest_collection_name = yield gen.Task(
                    StorageUtils.find_best_collection_name_for_user,
                    original_collection_name,
                    user_id)

                #Copy sharing content
                src_user_id = sharing_record.get_owner_user_id()
                response = yield gen.Task(StorageServer.copy_collection_between_accounts,
                                          src_user_id,
                                          user_id,
                                          original_collection_name,
                                          dest_collection_name)

                #if error happens just return it
                if response != StorageResponse.OK:
                    SharingController.__log.warning(
                        'SharingController -failed to copy resources between sharing partners for user %s and user %s; error %s' % (
                            src_user_id, user_id, str(response)))
                    callback(None)

                #Update Mongo
                else:
                    #Update sharing collection
                    sharing_record.add_subscriber(user_id, dest_collection_name)
                    yield gen.Task(SharingController.__update_sharing_record, sharing_record)
                    #Update subscribers collection
                    yield gen.Task(SharingController.add_subscriber, user_id, dest_collection_name,
                                   sharing_secret)
                    callback(dest_collection_name)

    @staticmethod
    @gen.engine
    def unsubscribe_from_sharing_space(user_id, collection_name, callback):
        """
        Unsubscribes the user with user_id from the sharing space.
        The sharing space is uniquely identified by having (user_id, collection_name)
        in the list of the subscribers.
        If the user is both the subscriber and the owner of the collection
        the sharing record for the collection is removed. In that sense the
        collection is unshared.

        -Args
            -``user_id``: The id of the subscriber who wants to unsubscribe
            -``collection_name``: The name of the collection in the
            subscribers account that is shared

        -Returns:
            -The status of the operation
        """

        sharing_record = yield gen.Task(SharingController.get_sharing_record_from_subscriber_info,
                                        user_id, collection_name)
        if sharing_record is not None:
            # if the unsubscriber is the owner
            # Remove the sharing info and remove the subscription info for everyone
            if sharing_record.get_owner_user_id() == user_id:
                SharingController.__log.info(
                    'SharingController - removing user %s is owner of shared collection %s; removing all subscribers and unsharing' % (
                        user_id, collection_name))
                yield gen.Task(SharingController.remove_all_subscribers,
                               sharing_record.get_sharing_secret())
                yield gen.Task(SharingController.remove_sharing_record_by_secret,
                               sharing_record.get_sharing_secret())
            else:
            #remove the subscription info and update the sharing space for the user
                yield gen.Task(SharingController.remove_subscriber, user_id, collection_name)
                sharing_record.remove_subscriber(user_id, collection_name)
                yield gen.Task(SharingController.__update_sharing_record, sharing_record)

            callback(StorageResponse.OK)
        else:
            SharingController.__log.info(
                'SharingController - sharing record not found for subscriber %s and collection %s' % (
                    user_id, collection_name))
            callback(StorageResponse.NOT_FOUND)

    @staticmethod
    @gen.engine
    def rename_shared_collection(user_id, old_collection_name, new_collection_name, callback):
        """
        Renames a shared collection .

            -Args:
                -``user_id``: The id of the user for which the shared collection will be renamed.
                the user could be the owner of the shared space or just a subscriber
                -``old_collection_name``: The name to change
                -``new_collection_name``: The name to change into

            -Returns:
                -Appropriate response code for the operation
        """

        sharing_record = yield gen.Task(SharingController.get_sharing_record_from_subscriber_info,
                                        user_id, old_collection_name)

        if sharing_record is not None:
            if sharing_record.get_owner_user_id() == user_id:
                sharing_record.set_owner_collection_name(new_collection_name)
                #since owner is also a subscriber this rename should be done in each case
            sharing_record.rename_subscriber_collection_name(user_id,
                                                             old_collection_name, new_collection_name)

            #update sharing related tables
            yield gen.Task(SharingController.__update_sharing_record, sharing_record)
            yield gen.Task(SharingController.__rename_subscriber_collection_name, user_id,
                           old_collection_name, new_collection_name, sharing_record.get_sharing_secret())
            callback(StorageResponse.OK)
        else:
            SharingController.__log.info(
                'SharingController - sharing record not found for subscriber %s and old collection %s' % (
                    user_id, old_collection_name))
            callback(StorageResponse.NOT_FOUND)

