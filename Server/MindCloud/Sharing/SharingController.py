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

    @staticmethod
    def generate_sharing_secret():
        chars = string.ascii_uppercase + string.digits
        return ''.join(random.choice(chars) for x in range(SharingController.__SECRET_LENGTH))

    @staticmethod
    @gen.engine
    def create_sharing_record(user_id, collection_name, callback):
        """
        Returns:
            -The sharing secret key for the create sharing record
        """
        sharing_secret = SharingController.generate_sharing_secret()
        sharing_collection = DatabaseFactory.get_sharing_collection()
        sharing_record = {SharingRecord.SECRET_KEY : sharing_secret,
                          SharingRecord.OWNER_KEY : user_id,
                          SharingRecord.COLLECTION_NAME_KEY : collection_name,
                          SharingRecord.SUBSCIRBERS_KEY : [(user_id,collection_name)]}
        yield gen.Task(sharing_collection.insert, sharing_record)
        callback(sharing_secret)

    @staticmethod
    @gen.engine
    def get_sharing_record(sharing_secret, callback):
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
    def remove_sharing_record(sharing_secret, callback):
        """
        Removes a sharing record identified by the sharing_secret

        Returns:
            - void. The callback will be called
        """
        sharing_collection = DatabaseFactory.get_sharing_collection()
        query = {SharingRecord.SECRET_KEY : sharing_secret}
        yield gen.Task(sharing_collection.remove, query)
        callback()

    @staticmethod
    @gen.engine
    def update_sharing_record(sharing_record, callback):
        """
        updates the sharing recrod in the mongoDB database.
        The passed in sharing record will replace the one
        in the db
        """
        sharing_collection = DatabaseFactory.get_sharing_collection()
        doc_key = {SharingRecord.SECRET_KEY: sharing_record.get_sharing_secret()}
        doc_content = sharing_record.toDictionary()
        yield gen.Task(sharing_collection.update, doc_key, doc_content)
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
            None if the operation wasn't successful
        """

        #Get the sharing space
        sharing_record = yield gen.Task(SharingController.get_sharing_record,
                                        sharing_secret)


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
            sharing_record.add_subscriber(user_id, dest_collection_name)
            yield gen.Task(SharingController.update_sharing_record, sharing_record)
            callback(dest_collection_name)






