import cStringIO
import shutil
from tornado.httputil import HTTPFile
from Sharing.SharingActionDelegate import SharingActionDelegate
from Sharing.SharingEvent import SharingEvent
from Sharing.UpdateSharedNoteAction import UpdateSharedNoteAction
from Storage.StorageResourceType import StorageResourceType

__author__ = 'afathali'

from tornado import gen
from Sharing.SharingAction import SharingAction
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

class UpdateSharedNoteImageAction(SharingAction):

    __user_id = None
    __collection_name = None
    __note_name = None
    __note_img_file = None
    __img_secret = None
    name = " "


    def __init__(self, user_id, collection_name, note_name,  note_img_file):
        self.__user_id = user_id
        self.__collection_name = collection_name
        if isinstance(note_img_file, HTTPFile):
            note_img_file = cStringIO.StringIO(note_img_file.body)
        self.__note_img_file = note_img_file
        self.__note_name = note_name

    @gen.engine
    def execute(self, callback=None, delegate=None):
        result_code = StorageResponse.BAD_REQUEST
        if self.__user_id and self.__collection_name and\
           self.__note_name and self.__note_img_file:
            result_code = yield gen.Task(StorageServer.add_image_to_note,
                self.__user_id, self.__collection_name, self.__note_name,
                self.__note_img_file)

        if delegate is not None:
            if isinstance(delegate, SharingActionDelegate):
                delegate.actionFinishedExecuting(self, result_code)

        elif callback is not None:
            callback(result_code)

    def get_note_name(self):
        return self.__note_name

    def get_collection_name(self):
        return self.__collection_name

    def get_user_id(self):
        return self.__user_id

    def get_action_type(self):
        return SharingEvent.UPDATE_NOTE_IMG

    def get_associated_file(self):
        return self.__note_img_file

    def set_img_secret(self, img_secret):
        """
        sets a temporary image secret that can be used to retrieve an update image result
        from the server
        """
        self.__img_secret = img_secret

    def get_img_secret(self):
        return self.__img_secret

    def get_action_resource_name(self):
        """
        Returns the name of the resource affected by this action
        """
        return self.get_note_name()

    def clone_for_user_and_collection(self, user_id, collection_name):
        clone_note_file = cStringIO.StringIO()
        shutil.copyfileobj(self.__note_img_file, clone_note_file)
        new_action = UpdateSharedNoteImageAction(user_id, collection_name,
            self.__note_name, clone_note_file)
        return new_action

    @gen.engine
    def was_successful(self, callback=None):
        answer = yield gen.Task(StorageServer.does_note_resource_exist, self.__user_id,
            self.__collection_name, self.__note_name,
            StorageResourceType.NOTE_IMG)
        callback(answer)

    def get_collection_name(self):
        return self.__collection_name
