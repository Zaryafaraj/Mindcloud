__author__ = 'Fathalian'
from Sharing.SharingAction import SharingAction
from tornado import gen
from Sharing.SharingEvent import SharingEvent


class SendCustomMessageAction(SharingAction):
    """
    This action represents communication of a diff file between listeners
    It does not involve any changes to permanent storage.
    """
    __msg_id = None
    __user_id = None
    __collection_name = None
    __msg = None
    name = " "

    def __init__(self, user_id, msg_id, collection_name, message):
        self.__user_id = user_id
        self.__collection_name = collection_name
        self.__msg = message
        self.__msg_id = msg_id

    def get_custom_message(self):
        return self.__msg

    @gen.engine
    def execute(self, callback=None, delegate=None, retry_counter=0):
        #a custom message has nothing to execute
        callback(200)

    def get_collection_name(self):
        return self.__collection_name

    def get_user_id(self):
        return self.__user_id

    def get_action_type(self):
        return SharingEvent.SEND_CUSTOM_MSG

    def get_associated_file(self):
        return None

    def clone_for_user_and_collection(self, user_id, collection_name):
        new_action = SendCustomMessageAction(user_id, self.__msg_id, collection_name, self.__msg)
        return new_action

    def get_action_resource_name(self):
        """
        Returns the name of the resource affected by this action. In this case its an ephemeral ID
        """
        return self.__msg_id

    @gen.engine
    def was_successful(self, callback=None):
        callback(True)
