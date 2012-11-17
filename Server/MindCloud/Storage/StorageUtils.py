from tornado import gen
from Storage.StorageServer import StorageServer

__author__ = 'afathali'

class StorageUtils:

    SHARING_POSTFIX = '-shared'

    @staticmethod
    @gen.engine
    def find_best_collection_name_for_user(collection_name, user_id, callback):
        """
        Gets a proper non existing collection name for the user
        If no collection with collection_name exists in the user account
        it simply returns collection_name, otherwise resolves the name
        to a unique collection_name to be used

        -Args:
            -``collection_name``: The proposed name of the collection
            -``user_id``: The user for which the collection name is
            checked

        -Returns:
            - A unique name to be used to store the collection for the user
        """
        collections = yield gen.Task(StorageServer.list_collections, user_id)
        temp_collection_name = collection_name
        first_postfix = StorageUtils.SHARING_POSTFIX
        second_postfix = 1
        if temp_collection_name in collections:
            temp_collection_name += first_postfix
            while temp_collection_name in collections:
                temp_collection_name = collection_name + \
                                       StorageUtils.SHARING_POSTFIX +\
                                       str(second_postfix)
                second_postfix += 1

        callback(temp_collection_name)

