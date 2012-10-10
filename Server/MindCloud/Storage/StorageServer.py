"""
Handles all the interaction with the storage mechanism
"""
from tornado import gen
from Helpers.DropboxHelper import DropboxHelper
from Storage.StorageResponse import StorageResponse

__author__ = 'afathali'

from Accounts import Accounts

class StorageServer:
    """
    A static class handling all the interactions with *all* the storage services.
    """

    __THUMBNAIL_FILENAME = 'thumbnail.jpg'

    @staticmethod
    @gen.engine
    def __get_storage(user_id, callback):
        """
        Retrieve an instance of the current valid storage system for the user with user_id
        In future` if we add different storage mechanism it should be placed here
        """

        account_info = yield gen.Task(Accounts.get_account,user_id)
        if account_info is not None:
            key = account_info['ticket'][0]
            secret = account_info['ticket'][1]
            storage = DropboxHelper.create_client(key, secret)
            callback(storage)

        else:
            callback(None)

    @staticmethod
    @gen.engine
    def list_collections(user_id, callback):
        """
        List all the collections that the user with user_id has access to

        Args:
            - ``user_id``: user id corresponding to the user

        Returns:
            - A list containing the name of all the collections available to the user
            will be passed to the callback method

        """
        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not  None:
            result = yield gen.Task(DropboxHelper.get_folders, db_client=storage,parent_name="/",
                user_id=user_id)
            callback(result)
        else:
            callback([])

    @staticmethod
    @gen.engine
    def add_collection(user_id, collection_name, callback, file=None):
        """
        Adds a collection to the user collections.
        If a file is specified that single file will be stored in the newly created collection.

        Args:
            - ``user_id``: user id corresponding to the user
            -``collection_name``: The name of the collection. It is assumed that this name
             has been validated prior to calling this function
            - ``file`` an optional file object that will be placed in the new collection

        Returns:
            - A StorageResponse status code that represent the status of the server
            will be passed to the callback
             """

        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            result_code = yield gen.Task(DropboxHelper.create_folder,storage, collection_name)
            #Make the file a closure so that it will be enclosed in the callback
            file_closure = file
            if result_code == StorageResponse.OK and file_closure is not None :
                parent_path = '/' + collection_name
                result_code = yield gen.Task(DropboxHelper.add_file, storage, parent_path,
                file)
            callback(result_code)
        else:
            callback(StorageResponse.SERVER_EXCEPTION)

    @staticmethod
    @gen.engine
    def remove_collection(user_id, collection_name, callback):
        """
        Removes a collection from the user collections.

        Args:
            - ``user_id``: user id corresponding to the user
            - ``collection_name``: The name of the collection to be removed.
            It is assumed that this name has been validated prior to calling
            this function

        Returns:
            - A StorageResponse status code that represents the status of the operation
            """

        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            result_code = yield gen.Task(DropboxHelper.delete_folder, storage, collection_name)
            callback(result_code)
        else:
            callback(StorageResponse.SERVER_EXCEPTION)

    @staticmethod
    @gen.engine
    def rename_collection(user_id, old_collection_name, new_collection_name, callback):
        """
        Renames a collection with old_collection_name to new_collection_name
        Both the old_collection and new_collection should and will be under
        root. However no need to specify a path for old_collection_name and
        new_collection_name

        Args:
            - ``user_id``: user id corresponding to the user
            - ``old_collection_name``: The name of the collection to be renamed.
            It is assumed that this name has been validated prior to calling
            this function. This is just a name. Example : collection1 and not /collection1
            - ``new_collection_name``: The new name for old_collection collection to be renamed.
            It is assumed that this name has been validated prior to calling
            this function. This is just a name. Example : collection2 and not /collection2

        Returns:
            - A StorageResponse status code that represents the status of the operation
            will be passed to the callback

        """

        #Make sure that the paths are absolute and from root
        old_collection_name = '/' + old_collection_name
        new_collection_name = '/' + new_collection_name

        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            result_code = yield gen.Task(DropboxHelper.move_folder, storage,
                old_collection_name, new_collection_name)
            callback(result_code)
        else:
            callback(StorageResponse.SERVER_EXCEPTION)

    @staticmethod
    def get_thumbnail(user_id, collection_name):
        """
        Retrurns an image thumbnail file for the collection.
        If the collection does not have any thumbnails returns None

        Args:
            - ``user_id``: user id corresponding to the user
            - ``collection_name``: The name of the collection for which the
            thumbnails will be retrieved .

        Returns:
            - A file or a file like object containing the image or None if the
            image does not exist or there was a problem retrieving it
        """

        thumbnail_path = "/%s/%s" % (collection_name, StorageServer.__THUMBNAIL_FILENAME)
        storage = StorageServer.__get_storage(user_id)
        if storage is not None:
           return DropboxHelper.get_file(storage, thumbnail_path)
        else:
            return None

    @staticmethod
    def add_thumbnail(user_id, collection_name, file):
        """
        Adds a thumbnail image to the collection

        Args:
            - ``user_id``: user id corresponding to the user
            - ``collection_name``: The name of the collection for which the
            thumbnails will be added

        Returns:

            -An StorageResponse indicating the result of the operation
        """

        thumbnail_path = "/%s" % collection_name
        storage = StorageServer.__get_storage(user_id)
        if storage is not None:
            return DropboxHelper.add_file(storage, thumbnail_path, file,
                file_name=StorageServer.__THUMBNAIL_FILENAME)
        else:
            return None

