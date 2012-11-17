import random
import string
from tornado import gen
from Sharing.SharingRecord import SharingRecord
from Storage.DatabaseFactory import DatabaseFactory

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
        sharing_collection = DatabaseFactory.get_sharing_collection()
        query = {SharingRecord.SECRET_KEY : sharing_secret}
        yield gen.Task(sharing_collection.remove, query)
        callback()




