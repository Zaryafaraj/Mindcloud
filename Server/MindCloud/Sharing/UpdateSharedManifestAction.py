from tornado import gen
from Sharing.SharingAction import SharingAction
from Sharing.SharingActionDelegate import SharingActionDelegate
from Sharing.SharingEvent import SharingEvent
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

__author__ = 'afathali'

class UpdateSharedManifestAction(SharingAction):

    __user_id = None
    __collection_name = None
    __manifest_file = None
    #TODO for testing purposes
    name = " "

    def __init__(self, user_id, collection_name, manifest_file):
        self.__user_id = user_id
        self.__collection_name = collection_name
        self.__manifest_file = manifest_file

    @gen.engine
    def execute(self,callback=None, delegate=None):
        result_code = StorageResponse.BAD_REQUEST
        if self.__user_id and self.__collection_name and self.__manifest_file:
            result_code = yield gen.Task(StorageServer.save_collection_manifest,
                self.__user_id, self.__collection_name, self.__manifest_file)

        if delegate is not None:
            if isinstance(delegate, SharingActionDelegate):
                delegate.actionFinishedExecuting(self, result_code)
        elif callback is not None:
            callback(result_code)

    def get_user_id(self):
        return self.__user_id

    def get_action_type(self):
        return SharingEvent.UPDATE_MANIFEST

    def get_associated_file(self):
        return self.__manifest_file

    def get_collection_name(self):
        return self.__collection_name

    def get_action_resource_name(self):
        """
        Returns the name of the resource affected by this action
        """
        return 'manifest'
