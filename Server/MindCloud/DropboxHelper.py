"""
Developed for mindcloud
"""
import httplib
import os
import cStringIO
from tornado.httputil import HTTPFile

__author__ = 'afathali'

from StorageResponse import StorageResponse
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
    def get_folders(db_client, parent_name, user_id = 'unknown'):
        """
        Get all the folder that are sub folders of a given folder

        Args:
            -``db_client``: A dropbox client object created from create_client method
            -``parent_name``: Name of the parent folder for which the subfolders are
            retrieved
            -``user_id``: The id of the user making the call

        Returns:
            - A list of the subfolder names
        """
        try:
            metadata = db_client.metadata(parent_name)
            contents = metadata[DropboxHelper.CONTENT_KEY]
            #Pythonic Zen master \m/
            #Filter the name of the folders from the root metadata
            result = [content[DropboxHelper.PATH_KEY].replace("/","")
                      for content in contents if content[DropboxHelper.IS_DIR] == True]
            return result

        except rest.ErrorResponse as exception:
            print "user: " + str(user_id) + ": " + str(exception.status) + ": " + exception.error_msg
            return []

    @staticmethod
    def create_folder(db_client, folder_name, parent_folder = '/'):
        """
        Create a folder inside the parent folder for a user

        Args:
            -``db_client``: A dropbox client object created from create_client method
            -``folder_name``: Name of the folder to be created
            -``parent_folder``: The parent folder under which the new folder will be
            created.

        Returns:
            - A MindCloud Storage response (HTTP Response) corresponding with the results
            of the operation
        """

        try:
            db_client.file_create_folder("/".join([parent_folder,folder_name]))
            return StorageResponse.OK

        except rest.ErrorResponse as exception:
        #if the folder already exists notify the user
            if exception.status == 403:
                return StorageResponse.DUPLICATED
            else:
                print str(exception.status) + ": " + exception.error_msg
                return StorageResponse.SERVER_EXCEPTION

    @staticmethod
    def delete_folder(db_client, folder_name, parent_folder ='/'):
        """
        Removes the folder with folder_name which is a sub folder of parent_folder

        Args:
            -``db_client``: A dropbox client object created from create_client method
            -``folder_name``: Name of the folder to be removed
            -``parent_folder``: The parent folder under which the folder will be
            deleted.

        Returns:
            - A MindCloud Storage response (HTTP Response) corresponding with the results
            of the operation
        """

        try:
            db_client.file_delete("/".join([parent_folder,folder_name]))
            return StorageResponse.OK
        except rest.ErrorResponse as exception:
            if exception.status == 404:
                return StorageResponse.NOT_FOUND
            else:
                print str(exception.status) + ": " + exception.error_msg
                return StorageResponse.SERVER_EXCEPTION

    @staticmethod
    def move_folder(db_client, old_path, new_path):
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

        try:
            db_client.file_move(old_path, new_path)
            return StorageResponse.OK
        except rest.ErrorResponse as exception:
            if exception.status == 404:
                return StorageResponse.NOT_FOUND
            elif exception.status == 403:
                return StorageResponse.DUPLICATED
            else:
                print str(exception.status) + ": " + exception.error_msg
                return StorageResponse.SERVER_EXCEPTION

    @staticmethod
    def add_file(db_client, parent, file, overwrite = True, file_name = None):
        """
        Adds a file to the parent folder.
        The file will have the same name as the file object and will be located in the parent path.

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
            of the operation
        """

        try:
            #The file input is not hashable and won't save on Dropbox
            #It should be converted to a file like object
            #We use the fast StringIO cStringIO for performance reason

            if isinstance(file, HTTPFile):
                #create the path in dropbox
                if file_name is None:
                    file_name = file.filename
                file_path = parent + "/" + file_name
                file_obj = cStringIO.StringIO(file.body)
                db_client.put_file(file_path, file_obj, overwrite=overwrite)
                return StorageResponse.OK
            else:
                #Its a normal file
                if file_name is None:
                    file_name = file.name
                file_path = parent + "/" + file_name
                db_client.put_file(file_path, file, overwrite=overwrite)
                return StorageResponse.OK
        except rest.ErrorResponse as exception:
            print str(exception.status) + ": " + exception.error_msg
            return StorageResponse.SERVER_EXCEPTION
        except Exception as exception:
            print exception.message

    @staticmethod
    def get_file(db_client, path, rev=None):
        """
        Retrieves the file specified by the path.

        Args:
            -``db_client``: A dropbox client object created from create_client method
            -``path``: The absolute path to the file
            -``rev``: Optional parameter determining the revision of the file to retrieve
            If not specified the latest revision is retrieved

        Returns:
        - A file containing the thumbnail img or None if no thumbnail exists
        """
        try:
            httpResponse = db_client.get_file(path,rev)
            thumbnail_data = httpResponse.read()
            #create a file like object from thumbnail_data
            thumbnail_file = cStringIO.StringIO(thumbnail_data)
            httpResponse.close()
            return thumbnail_file

        except  rest.ErrorResponse as exception:
            if exception.status == 404:
                return None
            else:
                print str(exception.status) + ": " + exception.error_msg
                return None



