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
    def add_collection(user_id, collection_name):
        """
        Adds a collection to the user collections

        Args:
            - ``user_id``: user id corresponding to the user
            -``collection_name``: The name of the collection. It is assumed that this name
             has been validated prior to calling this function

        Returns:
            - A StorageResponse status code that represent the status of the server
             """

        storage = StorageServer.__get_storage(user_id)
        if storage is not None:
            result_code = DropboxHelper.create_folder(storage, collection_name)
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
        -``

        """

        #Make sure that the paths are absolute and from root
        old_collection_name = '/' + old_collection_name
        new_collection_name = '/' + new_collection_name

        storage = StorageServer.__get_storage(user_id)
        if storage is not None:
            result_code = DropboxHelper.move_collection(storage,old_collection_name,new_collection_name)
            return result_code
        else:
            return StorageResponse.SERVER_EXCEPTION
