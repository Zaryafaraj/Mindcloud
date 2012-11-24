import random
import string
from tornado import gen
from Sharing.SharingRecord import SharingRecord
from Storage.DatabaseFactory import DatabaseFactory
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer
from Storage.StorageUtils import StorageUtils

__author__ = 'afathali'

class SharingController:

    __SECRET_LENGTH = 8
    __SUBSCRIBER_ID_KEY = 'subscriber_id'
    __SUBSCRIBER_COLLECTION_NAME_KEY = 'shared_collection_name'
    __SHARING_SPACE_SECRET_KEY = 'sharing_secret'

    @staticmethod
    def __generate_sharing_secret():
        chars = string.ascii_uppercase + string.digits
        return ''.join(random.choice(chars) for x in range(SharingController.__SECRET_LENGTH))

    @staticmethod
    @gen.engine
    def __add_subscriber(user_id, collection_name, sharing_secret, callback):
        """
        Adds a subscriber with user id and collection and sharing secret
        to the subscribers db. user_id and collection_name uniquely identify
        the subscriber and maps it to the sharing_secret of the sharing space
        """

        subscriber_collection = DatabaseFactory.get_subscribers_collection()
        subscriber_record = {SharingController.__SUBSCRIBER_ID_KEY : user_id,
                             SharingController.__SUBSCRIBER_COLLECTION_NAME_KEY : collection_name,
                             SharingController.__SHARING_SPACE_SECRET_KEY : sharing_secret}
        yield gen.Task(subscriber_collection.insert, subscriber_record)
        callback()

    @staticmethod
    @gen.engine
    def __get_sharing_secret_from_subscriber_info(user_id, collection_name, callback):
        """
        Retrieves the sharing secret of a sharing space, uniquely identified
        by the user_id and collection name.

        -Returns:
            - The secret is passed to the callback. If there is no such
            subscriber then None is passed
        """
        subscriber_collection = DatabaseFactory.get_subscribers_collection()
        query = {SharingController.__SUBSCRIBER_ID_KEY : user_id,
                 SharingController.__SUBSCRIBER_COLLECTION_NAME_KEY : collection_name}
        subscriber_record_cursor = yield gen.Task(subscriber_collection.find, query)
        result_count = len(subscriber_record_cursor[0][0])
        #if user_id and collection_name are not uniquely identifying the
        #share space then we are in trouble
        if result_count > 2:
            print 'More than two sharing info found for: ' + user_id + ' - ' + collection_name
            result_count = None

        if not result_count:
            callback(None)

        else:
            subscriber_record_bson = subscriber_record_cursor[0][0][0]
            callback(subscriber_record_bson[SharingController.__SHARING_SPACE_SECRET_KEY])

    @staticmethod
    @gen.engine
    def __get_sharing_record_from_subscriber_info(user_id, collection_name, callback):
        """
        Provides the sharing record from a subscribers user_id and
         the subscribed collection_name in his own account.

         -Returns:
            -The sharing record object or None
        """
        sharing_secret = yield gen.Task(SharingController.__get_sharing_secret_from_subscriber_info,
                                        user_id,
                                        collection_name)
        if sharing_secret is None:
            callback(None)
        else:
            sharing_info = yield gen.Task(SharingController.__get_sharing_record_by_secret,
                sharing_secret)
            callback(sharing_info)

    @staticmethod
    @gen.engine
    def __remove_subscriber(user_id, collection_name, callback):
        """
        Removes the subscriber from the subscribers collection.
        user_id and collection_name identify a sharing space uniquely.
        """
        subscriber_collection = DatabaseFactory.get_subscribers_collection()
        query = {SharingController.__SUBSCRIBER_ID_KEY : user_id,
                 SharingController.__SUBSCRIBER_COLLECTION_NAME_KEY : collection_name}
        yield gen.Task(subscriber_collection.remove, query)
        callback()

    @staticmethod
    @gen.engine
    def __remove_all_subscribers(sharing_secret, callback):
        """
        Removes all the subscribers to a sharing space identified by
        a sharing_secret
        """
        subscriber_collection = DatabaseFactory.get_subscribers_collection()
        query = {SharingController.__SHARING_SPACE_SECRET_KEY: sharing_secret}
        yield gen.Task(subscriber_collection.remove, query)
        callback()

    @staticmethod
    @gen.engine
    def create_sharing_record(user_id, collection_name, callback):
        """
        Returns:
            -The sharing secret key for the create sharing record
        """
        exsiting_sharing_record =  yield gen.Task(SharingController.get_sharing_record_by_owner_info,
            user_id, collection_name)

        exsiting_sharing_secret = None
        if exsiting_sharing_record is not None:
            exsiting_sharing_secret = exsiting_sharing_record.get_sharing_secret()
        if exsiting_sharing_secret is not None:
            callback(exsiting_sharing_secret)
        else:
            sharing_secret = SharingController.__generate_sharing_secret()
            sharing_collection = DatabaseFactory.get_sharing_collection()
            sharing_record = {SharingRecord.SECRET_KEY : sharing_secret,
                              SharingRecord.OWNER_KEY : user_id,
                              SharingRecord.COLLECTION_NAME_KEY : collection_name,
                              SharingRecord.SUBSCIRBERS_KEY : [(user_id,collection_name)]}
            yield gen.Task(sharing_collection.insert, sharing_record)
            yield gen.Task(SharingController.__add_subscriber, user_id, collection_name,
                sharing_secret)
            callback(sharing_secret)

    @staticmethod
    @gen.engine
    def __get_sharing_record_by_secret(sharing_secret, callback):
        """
        Returns:
            -A Sharing record object containing information of the
            sharing space with the sharing_secret and None if the
            sharing record for the specified sharing secret does not
            exist
        """
        sharing_collection = DatabaseFactory.get_sharing_collection()
        query = {SharingRecord.SECRET_KEY : sharing_secret}
        sharing_records_cursor = yield gen.Task(sharing_collection.find, query)
        result_count = len(sharing_records_cursor[0][0])
        #if we have more sharing spaces with this sharing secret
        #something is horribly wrong
        assert result_count < 2

        if not result_count:
            callback(None)

        else:
            #FIXME: is there a better way to these in asyncMongo other
            #than these ugly indicies
            sharing_record_bson = sharing_records_cursor[0][0][0]
            sharing_record = SharingRecord(
                            sharing_record_bson[SharingRecord.SECRET_KEY],
                            sharing_record_bson[SharingRecord.OWNER_KEY],
                            sharing_record_bson[SharingRecord.COLLECTION_NAME_KEY],
                            sharing_record_bson[SharingRecord.SUBSCIRBERS_KEY])
            callback(sharing_record)

    @staticmethod
    @gen.engine
    def get_sharing_record_by_owner_info(user_id, collection_name, callback):
        """
        An overload of the above funtion.

        -Args:
            -``user_id``: The id of the owner of the collection
            -``collection_name``: The name of the owners collection
        """
        sharing_collection = DatabaseFactory.get_sharing_collection()
        query = {SharingRecord.OWNER_KEY : user_id ,
                 SharingRecord.COLLECTION_NAME_KEY : collection_name}
        sharing_records_cursor = yield gen.Task(sharing_collection.find, query)
        result_count = len(sharing_records_cursor[0][0])

        #if we have more sharing spaces with this sharing secret
        #something is horribly wrong
        assert result_count < 2

        if not result_count:
            callback(None)

        else:
            #FIXME: is there a better way to these in asyncMongo other
            #than these ugly indicies
            sharing_record_bson = sharing_records_cursor[0][0][0]
            sharing_record = SharingRecord(
                sharing_record_bson[SharingRecord.SECRET_KEY],
                sharing_record_bson[SharingRecord.OWNER_KEY],
                sharing_record_bson[SharingRecord.COLLECTION_NAME_KEY],
                sharing_record_bson[SharingRecord.SUBSCIRBERS_KEY])
            callback(sharing_record)


    @staticmethod
    @gen.engine
    def __remove_sharing_record_by_secret(sharing_secret, callback):
        """
        Removes a sharing record identified by the sharing_secret

        Returns:
            - void. The callback will be called
        """
        sharing_collection = DatabaseFactory.get_sharing_collection()
        query = {SharingRecord.SECRET_KEY : sharing_secret}
        yield gen.Task(sharing_collection.remove, query)
        yield gen.Task(SharingController.__remove_all_subscribers, sharing_secret)
        callback()

    @staticmethod
    @gen.engine
    def remove_sharing_record_by_owner_info(owner_id, collection_name, callback):
        """
        Overload of remove sharing collection

        Returns:
            -void. The callback will be called
        """
        sharing_collection = DatabaseFactory.get_sharing_collection()
        query = {SharingRecord.OWNER_KEY : owner_id,
                 SharingRecord.COLLECTION_NAME_KEY: collection_name}
        sharing_record = yield gen.Task(SharingController.get_sharing_record_by_owner_info,
        owner_id, collection_name)
        if sharing_record is None:
            callback()
        else:
            sharing_secret = sharing_record.get_sharing_secret()
            yield gen.Task(sharing_collection.remove, query)
            yield gen.Task(SharingController.__remove_all_subscribers, sharing_secret)
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
        yield gen.Task(sharing_collection.update, doc_key, doc_content)
        callback()

    @staticmethod
    @gen.engine
    def __rename_subscriber_collection_name(user_id, old_collection_name,
                                            new_collection_name, callback):
        """
        Updates the subscriber table for the user with user_id with the new name
        for its collection
        """

        sharing_collection = DatabaseFactory.get_sharing_collection()
        key = {SharingController.__SUBSCRIBER_ID_KEY : user_id,
                 SharingController.__SUBSCRIBER_COLLECTION_NAME_KEY : old_collection_name}
        new_content = {SharingController.__SUBSCRIBER_ID_KEY : user_id,
                       SharingController.__SUBSCRIBER_COLLECTION_NAME_KEY : new_collection_name}
        yield gen.Task(sharing_collection.update, key, new_content)
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
        sharing_record = yield gen.Task(SharingController.__get_sharing_record_by_secret,
                                        sharing_secret)

        if sharing_record is None:
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
                    callback(None)

                #Update Mongo
                else:
                    #Update sharing collection
                    sharing_record.__add_subscriber(user_id, dest_collection_name)
                    yield gen.Task(SharingController.__update_sharing_record, sharing_record)
                    #Update subscribers collection
                    yield gen.Task(SharingController.__add_subscriber, user_id, dest_collection_name,
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

        sharing_record = yield gen.Task(SharingController.__get_sharing_record_from_subscriber_info,
            user_id, collection_name)
        if sharing_record is not None:
            # if the unsubscriber is the owner
            # Remove the sharing info and remove the subscription info for everyone
            if sharing_record.get_owner_user_id() == user_id:
                yield gen.Task(SharingController.__remove_all_subscribers,
                    sharing_record.get_sharing_secret())
                yield gen.Task(SharingController.__remove_sharing_record_by_secret,
                    sharing_record.get_sharing_secret())
            else:
            #remove the subscription info and update the sharing space for the user
                yield gen.Task(SharingController.__remove_subscriber, user_id, collection_name)
                sharing_record.__remove_subscriber(user_id, collection_name)
                yield gen.Task(SharingController.__update_sharing_record, sharing_record)

            callback(StorageResponse.OK)
        else:
            callback(StorageResponse.NOT_FOUND)

    @staticmethod
    @gen.engine
    def rename_shared_collection(user_id, old_collection_name, new_collection_name, callback):

       sharing_record = yield gen.Task(SharingController.__get_sharing_record_from_subscriber_info,
           user_id, old_collection_name)

       if sharing_record is not None:
           if sharing_record.get_owner_user_id() == user_id:
               sharing_record.set_owner_collection_name(new_collection_name)

           #since owner is also a subscriber this rename should be done in each case
           sharing_record.rename_subsciber_collection_name(user_id,
               old_collection_name, new_collection_name)

           #update sharing related tables
           yield gen.Task(SharingController.__update_sharing_record, sharing_record)
           yield gen.Task(SharingController.__rename_subscriber_collection_name, user_id,
               old_collection_name, new_collection_name)

       else:
           callback(None)



