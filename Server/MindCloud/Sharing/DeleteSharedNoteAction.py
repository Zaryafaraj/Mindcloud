from tornado import gen
from Sharing.SharingAction import SharingAction
from Sharing.SharingActionDelegate import SharingActionDelegate
from Sharing.SharingEvent import SharingEvent
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

__author__ = 'afathali'

class DeleteSharedNoteAction(SharingAction):

    __user_id = None
    __collection_name = None
    __note_name = None

    name = ''

    def __init__(self, user_id, collection_name, note_name):
        self.__user_id = user_id
        self.__collection_name = collection_name
        self.__note_name = note_name

    @gen.engine
    def execute(self, callback=None, delegate=None):
        result_code = StorageResponse.BAD_REQUEST
        if self.__user_id and self.__collection_name and self.__note_name:
            result_code = yield gen.Task(StorageServer.remove_note,
                self.__user_id, self.__collection_name, self.__note_name)

        if delegate is not None:
            if isinstance(delegate, SharingActionDelegate):
                delegate.actionFinishedExecuting(self, result_code)
        elif callback is not None:
            callback(result_code)

    def get_note_name(self):
        return self.__note_name

    def get_user_id(self):
        return self.__user_id

    def get_action_type(self):
        return SharingEvent.DELETE_NOTE

    def get_associated_file(self):
        return None

    def get_action_resource_name(self):
        """
        Returns the name of the resource affected by this action
        """
        return self.get_note_name()

    def get_collection_name(self):
        return self.__collection_name

    def clone_for_user_and_collection(self, user_id, collection_name):

        new_sharing_action = DeleteSharedNoteAction(user_id, collection_name,
            self.__note_name)
        return new_sharing_action

    def was_successful(self, callback=None):
        if callback:
            callback(True)
