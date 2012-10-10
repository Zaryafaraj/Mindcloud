"""
Developed for mindcloud
"""
import httplib
import os
import cStringIO
from tornado import gen
from tornado.httputil import HTTPFile
from AsynchDropbox import client

__author__ = 'afathali'

from Storage.StorageResponse import StorageResponse
from AsynchDropbox.session import AsyncDropboxSession

class DropboxHelper:
    #TODO for loggign purposes pass the userID to each method
    """
    Handles all the interactions with dropbox.
    """

    #Mindcloud config for dropbox
    __APP_KEY =  'h7f38af0ewivq6s'
    __APP_SECRET = 'iiq8oz2lae46mwp'
    __ACCESS_TYPE = 'app_folder'

    CONTENT_KEY = 'contents'
    PATH_KEY = 'path'
    IS_DIR = 'is_dir'

    @staticmethod
    def create_session():
        """
        Initiate and return a session for interacting with dropbox
        """
        sess = AsyncDropboxSession(DropboxHelper.__APP_KEY, DropboxHelper.__APP_SECRET,
            DropboxHelper.__ACCESS_TYPE)
        return sess

    @staticmethod
    def create_client(key, secret):
        """
        Create an authenticate client that has been authorized by the user
        from the session.
        Key and secret are the oAuth params that the user authenticated with
        """
        sess = DropboxHelper.create_session()
        sess.set_token(key, secret)
        db_client = client.DropboxClient(sess)
        return db_client

    @staticmethod
    @gen.engine
    def get_folders(db_client, parent_name, callback, user_id = 'unknown'):
        """
        Get all the folder that are sub folders of a given folder

        Args:
            -``db_client``: A dropbox client object created from create_client method
            -``parent_name``: Name of the parent folder for which the subfolders are
            retrieved
            -``user_id``: The id of the user making the call
            -``callback``: The callback function to call

        Returns:
            - A list of the subfolder names will be passed to the call back
        """
        metadata = yield gen.Task(db_client.metadata,parent_name)
        contents = metadata[DropboxHelper.CONTENT_KEY]
        #TODO add error catching
        #Pythonic Zen master \m/
        #Filter the name of the folders from the root metadata
        result = [content[DropboxHelper.PATH_KEY].replace("/","")
                  for content in contents if content[DropboxHelper.IS_DIR] == True]
        callback(result)

    @staticmethod
    @gen.engine
    def create_folder(db_client, folder_name, callback, parent_folder = '/'):
        """
        Create a folder inside the parent folder for a user

        Args:
            -``db_client``: A dropbox client object created from create_client method
            -``folder_name``: Name of the folder to be created
            -``parent_folder``: The parent folder under which the new folder will be
            created.
            -``callback``: The function to call with the response code of the operation

        Returns:
            -When the operation is done callback is called with the response code
            of the operation
        """

        response = yield gen.Task(db_client.file_create_folder,
            "/".join([parent_folder,folder_name]))
        callback(response.code)

    @staticmethod
    @gen.engine
    def delete_folder(db_client, folder_name, callback, parent_folder ='/'):
        """
        Removes the folder with folder_name which is a sub folder of parent_folder

        Args:
            -``db_client``: A dropbox client object created from create_client method
            -``folder_name``: Name of the folder to be removed
            -``parent_folder``: The parent folder under which the folder will be
            deleted.

        Returns:
            - A MindCloud Storage response (HTTP Response) corresponding with the results
            of the operation will be passed to the callback
        """

        file_path = "/".join([parent_folder,folder_name])
        response = yield gen.Task(db_client.file_delete, file_path)
        callback(response.code)

    @staticmethod
    @gen.engine
    def move_folder(db_client, old_path, new_path, callback):
        """
        Moves a collection from old_path to new_path
        This can be used both for files and folders.

        Args:
            -``db_client``: A dropbox client object created from create_client method
            -``old_path``: The current path of the folder to be moved. Note that this
            should be an absolute path starting from the root : /foo/baar
            -``new_path``: Where to move the folder.
             Note that this should be an absolute path starting from the root : /foo/baar
             if there already is a collection with new_path. This functions new path will be
             modified to keep both files

        Returns:
            - A MindCloud Storage response (HTTP Response) corresponding with the results
            of the operation
        """

        response = yield gen.Task(db_client.file_move, old_path, new_path)
        callback(response.code)

    @staticmethod
    @gen.engine
    def add_file(db_client, parent, file, callback, overwrite = True, file_name = None):
        """
        Adds a file to the parent folder.
        The file will have the same name as the file object and will be located in the parent path.
        If the parent does not exist it gets created

        Args:
            -``db_client``: A dropbox client object created from create_client method
            -``parent``: The parent folder in which the new file will be located (does not include the file itself)
             example: /foo/bar
             -``file``: A file or a file like object that will be uploaded to the dropbox
             -``overwrite``: Optional parameter if true will overwrite the file
             -``fileName``: Optional parameter if set the name of the uploaded filename
             will be set to that. If not the file name will be derived from the file itself

        Returns:
            - A MindCloud Storage response (HTTP Response) corresponding with the results
            will be passed to the callback
        """

        if isinstance(file, HTTPFile):
            #The file input is not hashable and won't save on Dropbox
            #It should be converted to a file like object
            #We use the fast StringIO cStringIO for performance reason
            #create the path in dropbox
            #TODO should refactor this
            if file_name is None:
                file_name = file.filename
            file_obj = cStringIO.StringIO(file.body)
            file_path = parent + "/" + file_name
            yield gen.Task(db_client.put_file, file_path, file_obj, callback=callback,
            overwrite=overwrite)
            callback(StorageResponse.OK)
        else:
            #Its a normal file
            if file_name is None:
                file_name = file.name
                #If the file is an os file (for testing purposes)
                if '/' in file_name or '\\' in file_name:
                    file_name = os.path.basename(file_name)
            file_path = parent + "/" + file_name
            yield gen.Task(db_client.put_file, file_path, file,
                overwrite=overwrite)
            callback(StorageResponse.OK)

    @staticmethod
    @gen.engine
    def get_file(db_client, path, callback, rev=None):
        """
        Retrieves the file specified by the path.

        Args:
            -``db_client``: A dropbox client object created from create_client method
            -``path``: The absolute path to the file
            -``rev``: Optional parameter determining the revision of the file to retrieve
            If not specified the latest revision is retrieved

        Returns:
        - A file containing the thumbnail img or None if no thumbnail exists will be passed
        to the callback
        """

        httpResponse = yield gen.Task(db_client.get_file,path, rev=rev)
        thumbnail_data = httpResponse.body
        #create a file like object from thumbnail_data
        thumbnail_file = cStringIO.StringIO(thumbnail_data)
        #should we close this ?
        callback(thumbnail_file)



