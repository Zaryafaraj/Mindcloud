import shutil
import cStringIO
from tornado import gen
from tornado.httputil import HTTPFile
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

        if isinstance(manifest_file, HTTPFile):
            manifest_file = cStringIO.StringIO(manifest_file.body)
        self.__manifest_file = manifest_file

    @gen.engine
    def execute(self, callback=None, delegate=None, retry_counter=0):
        result_code = StorageResponse.BAD_REQUEST
        if self.__user_id and self.__collection_name and self.__manifest_file:
            result_code = yield gen.Task(StorageServer.save_collection_manifest,
                self.__user_id, self.__collection_name, self.__manifest_file)

        retry_counter += 1
        if delegate is not None:
            if isinstance(delegate, SharingActionDelegate):
                delegate.actionFinishedExecuting(self, result_code, retry_count=retry_counter)
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
    def clone_for_user_and_collection(self, user_id, collection_name):
        clone_manifest_file = cStringIO.StringIO()
        self.__manifest_file.seek(0)
        shutil.copyfileobj(self.__manifest_file, clone_manifest_file)
        new_action = UpdateSharedManifestAction(user_id, collection_name,
            clone_manifest_file)
        return new_action

    def was_successful(self, callback=None):
        if callback:
            callback(True)
