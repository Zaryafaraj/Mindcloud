import cStringIO
import shutil
from tornado.httputil import HTTPFile
from Sharing.SharingActionDelegate import SharingActionDelegate
from Sharing.SharingEvent import SharingEvent
from Storage.StorageResourceType import StorageResourceType

__author__ = 'afathali'
from tornado import gen
from Sharing.SharingAction import SharingAction
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

__author__ = 'afathali'

class UpdateSharedNoteAction(SharingAction):

    __user_id = None
    __collection_name = None
    __note_name = None
    __note_file = None
    #TODO for testing purposes
    name = " "

    def __init__(self, user_id, collection_name, note_name,  note_file):
        self.__user_id = user_id
        self.__collection_name = collection_name
        if isinstance(note_file, HTTPFile):
            note_file = cStringIO.StringIO(note_file.body)
        self.__note_file = note_file
        self.__note_name = note_name

    @gen.engine
    def execute(self, callback=None, delegate=None):
        result_code = StorageResponse.BAD_REQUEST
        if self.__user_id and self.__collection_name and\
           self.__note_name and self.__note_file:
            result_code = yield gen.Task(StorageServer.add_note_to_collection,
                self.__user_id, self.__collection_name, self.__note_name,
                self.__note_file)

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
        return SharingEvent.UPDATE_NOTE

    def get_associated_file(self):
        return self.__note_file

    def get_action_resource_name(self):
        """
        Returns the name of the resource affected by this action
        """
        return self.get_note_name()

    def clone_for_user_and_collection(self, user_id, collection_name):
        clone_note_file = cStringIO.StringIO()
        self.__note_file.seek(0)
        shutil.copyfileobj(self.__note_file, clone_note_file)
        new_action = UpdateSharedNoteAction(user_id, collection_name,
            self.__note_name, clone_note_file)
        return new_action

    @gen.engine
    def was_successful(self, callback=None):
        answer = yield gen.Task(StorageServer.does_note_resource_exist, self.__user_id,
            self.__collection_name, self.__note_name,
            StorageResourceType.NOTE_MANIFEST)
        callback(answer)

    def get_collection_name(self):
        return self.__collection_name
