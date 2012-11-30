from Sharing.SharingEvent import SharingEvent

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

    def __init__(self):
        raise NotImplemented

    def __init__(self, user_id, collection_name, note_name,  note_img_file):
        self.__user_id = user_id
        self.__collection_name = collection_name
        self.__note_img_file = note_img_file
        self.__note_name = note_name

    @gen.engine
    def execute(self, callback):
        result_code = StorageResponse.BAD_REQUEST
        if self.__user_id and self.__collection_name and\
           self.__note_name and self.__note_img_file:
            result_code = yield gen.Task(StorageServer.add_image_to_note,
                self.__user_id, self.__collection_name, self.__note_name,
                self.__note_img_file),
        callback(result_code)

    def get_user_id(self):
        return self.__user_id

    def get_action_type(self):
        return SharingEvent.UPDATE_NOTE_IMG

