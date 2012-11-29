from tornado import gen
from Sharing.SharingAction import SharingAction
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

__author__ = 'afathali'

class UpdateSharedManifestAction(SharingAction):

    __user_id = None
    __collection_name = None
    __manifest_file = None

    def __init__(self):
        raise NotImplemented

    def __init__(self, user_id, collection_name, manifest_file):
        self.__user_id = user_id
        self.__collection_name = collection_name
        self.__manifest_file = manifest_file

    @gen.engine
    def execute(self, callback):
        result_code = StorageResponse.BAD_REQUEST
        if self.__user_id and self.__collection_name and self.__manifest_file:
            result_code = yield gen.Task(StorageServer.save_collection_manifest,
                self.__user_id, self.__collection_name, self.__manifest_file)
        callback(result_code)


