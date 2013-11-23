__author__ = 'Fathalian'
from Sharing.SharingAction import SharingAction
from tornado.httputil import HTTPFile
from tornado import gen
import cStringIO
import shutil
from Sharing.SharingEvent import SharingEvent


class SendDiffFileAction(SharingAction):
    """
    This action represents communication of a diff file between listeners
    It does not involve any changes to permanent storage.
    """
    __user_id = None
    __collection_name = None
    __diff_file = None
    #Resource path is the path starting from root of the collection to the
    #location that the file is located. For example if the file is in the
    #collection the resourcePath == file name
    __resource_path = None
    name = " "

    def __init__(self, user_id, collection_name, diff_file, resource_path):
        self.__user_id = user_id
        self.__collection_name = collection_name
        self.__resource_path = resource_path
        if isinstance(diff_file, HTTPFile):
            diff_file = cStringIO.StringIO(diff_file.body)
        self.__diff_file = diff_file

    @gen.engine
    def execute(self, callback=None, delegate=None, retry_counter=0):
        #a diff file has nothing to execute.
        callable(200)

    def get_collection_name(self):
        return self.__collection_name

    def get_user_id(self):
        return self.__user_id

    def get_action_type(self):
        return SharingEvent.SEND_DIFF_FILE

    def get_associated_file(self):
        return self.__diff_file

    def clone_for_user_and_collection(self, user_id, collection_name):
        clone_note_file = cStringIO.StringIO()
        self.__diff_file.seek(0)
        shutil.copyfileobj(self.__diff_file, clone_note_file)
        new_action = SendDiffFileAction(user_id, collection_name,
                                        clone_note_file, self.__resource_path)
        return new_action

    def get_action_resource_name(self):
        """
        Returns the name of the resource affected by this action
        """
        return self.__resource_path

    @gen.engine
    def was_successful(self, callback=None):
        callback(True)
