"""
Handles all the interaction with the storage mechanism
"""
__author__ = 'afathali'

from Accounts import Accounts
from DropboxHelper import DropboxHelper
from StorageResponse import StorageResponse

class StorageServer:
    """
    A static class handling all the interactions with *all* the storage services.
    """

    __THUMBNAIL_FILENAME = 'thumbnail.jpg'

    @staticmethod
    def __get_storage(user_id):
        """
        Retrieve an instance of the current valid storage system for the user with user_id
        In future` if we add different storage mechanism it should be placed here
        """

        account_info = Accounts.get_account(user_id)
        if account_info is not None:
            key = account_info['ticket'][0]
            secret = account_info['ticket'][1]
            storage = DropboxHelper.create_client(key, secret)
            return storage

        else:
            return None

    @staticmethod
    def list_collections(user_id):
        """
        List all the collections that the user with user_id has access to

        Args:
            - ``user_id``: user id corresponding to the user

        Returns:
            - A list containing the name of all the collections available to the user

        """
        storage = StorageServer.__get_storage(user_id)
        if storage is not  None:
            result = DropboxHelper.get_folders(storage, "/", user_id)
            return  result
        else:
            return []

    @staticmethod
    def add_collection(user_id, collection_name, file=None):
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
             """

        storage = StorageServer.__get_storage(user_id)
        if storage is not None:
            result_code = DropboxHelper.create_folder(storage, collection_name)
            if result_code == StorageResponse.OK and file is not None:
                parent_path = '/' + collection_name
                DropboxHelper.add_file(storage, parent_path, file)
            return result_code
        else:
            return StorageResponse.SERVER_EXCEPTION

    @staticmethod
    def remove_collection(user_id, collection_name):
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

        storage = StorageServer.__get_storage(user_id)
        if storage is not None:
            result_code = DropboxHelper.delete_folder(storage, collection_name)
            return result_code
        else:
            return StorageResponse.SERVER_EXCEPTION

    @staticmethod
    def rename_collection(user_id, old_collection_name, new_collection_name):
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

        """

        #Make sure that the paths are absolute and from root
        old_collection_name = '/' + old_collection_name
        new_collection_name = '/' + new_collection_name

        storage = StorageServer.__get_storage(user_id)
        if storage is not None:
            result_code = DropboxHelper.move_folder(storage,old_collection_name,new_collection_name)
            return result_code
        else:
            return StorageResponse.SERVER_EXCEPTION

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

        thumbnail_path = "/%s/%s" % collection_name, StorageServer.__THUMBNAIL_FILENAME
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

