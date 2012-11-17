import os
import random
import string
import uuid

__author__ = 'afathali'

class SharingController:

    __SECRET_LENGTH = 8

    @staticmethod
    def generate_sharing_secret():
        chars = string.ascii_uppercase + string.digits
        return ''.join(random.choice(chars) for x in range(SharingController.__SECRET_LENGTH))

    @staticmethod
    def create_sharing_record(user_id, collection_name):
        sharing_secret = SharingController.generate_sharing_secret()



