import os
import random
import string
import uuid
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
    def create_sharing_record(user_id, collection_name, callback):
        sharing_secret = SharingController.generate_sharing_secret()
        sharing_collection = DatabaseFactory.get_sharing_collection()
        sharing_record = {SharingRecord.SECRET_KEY : sharing_secret,
                          SharingRecord.OWNER_KEY : user_id,
                          SharingRecord.COLLECTION_NAME_KEY : collection_name,
                          SharingRecord.SUBSCIRBERS_KEY : [(user_id,collection_name)]}
        yield gen.Task(sharing_collection.insert, sharing_record)
        callback()

    @staticmethod
    def get_sharing_info(sharing_secret, callback):
        sharing_collection = DatabaseFactory.get_sharing_collection()
        query = {SharingRecord.SECRET_KEY : sharing_secret}
        sharing_records_cursor = yield gen.Task(sharing_collection.find, query)
        #if we have more sharing spaces with this sharing secret
        #something is horribly wrong
        assert sharing_records_cursor.count() == 1
        sharing_record_bson = sharing_records_cursor[0]
        sharing_record = SharingRecord(
                        sharing_record_bson[SharingRecord.SECRET_KEY],
                        sharing_record_bson[SharingRecord.OWNER_KEY],
                        sharing_record_bson[SharingRecord.COLLECTION_NAME_KEY],
                        sharing_record_bson[SharingRecord.SUBSCIRBERS_KEY])
        callback(sharing_record)




