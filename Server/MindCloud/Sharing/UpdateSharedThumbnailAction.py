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

class UpdateSharedThumbnailAction(SharingAction):

    #TODO for testing purposes
    name = " "

    def __init__(self, user_id, collection_name, thumbnail_file):
        self.__user_id = user_id
        self.__collection_name = collection_name
        if isinstance(thumbnail_file, HTTPFile):
            thumbnail_file = cStringIO.StringIO(thumbnail_file.body)
        self.__thumbnail_file = thumbnail_file

    @gen.engine
    def execute(self,callback=None, delegate=None):
        result_code = StorageResponse.BAD_REQUEST
        if self.__user_id and self.__collection_name and self.__thumbnail_file:
            result_code = yield gen.Task(StorageServer.add_thumbnail,
                self.__user_id, self.__collection_name,
                self.__thumbnail_file)

        if delegate is not None:
            if isinstance(delegate, SharingActionDelegate):
                delegate.actionFinishedExecuting(self, result_code)
        elif callback is not None:
            callback(result_code)

    def get_user_id(self):
        return self.__user_id

    def get_action_type(self):
        return SharingEvent.UPDATE_THUMBNAIL

    def get_associated_file(self):
        return self.__thumbnail_file

    def get_collection_name(self):
        return self.__collection_name

    def get_action_resource_name(self):
        """
        Returns the name of the resource affected by this action
        """
        return 'thumbnail'
    def clone_for_user_and_collection(self, user_id, collection_name):
        clone_manifest_file = cStringIO.StringIO()
        shutil.copyfileobj(self.__thumbnail_file, clone_manifest_file)
        new_action = UpdateSharedThumbnailAction(user_id, collection_name,
            clone_manifest_file)
        return new_action

    def was_successful(self, callback=None):
        if callback:
            callback(True)


    def set_img_secret(self, img_secret):
        """
        sets a temporary image secret that can be used to retrieve an update image result
        from the server
        """
        self.__img_secret = img_secret

    def get_img_secret(self):
        return self.__img_secret
