"""
Handles all the interaction with the storage mechanism
"""
import json
from tornado import gen
from Cache.MindcloudCache import MindcloudCache
from Helpers.DropboxHelper import DropboxHelper
from Logging import Log
from Storage.StorageResourceType import StorageResourceType
from Storage.StorageResponse import StorageResponse

__author__ = 'afathali'

from Accounts import Accounts


class StorageServer:
    """
    A static class handling all the interactions with *all* the storage services.
    """

    __log = Log.log()
    __cache = MindcloudCache()
    __THUMBNAIL_FILENAME = 'thumbnail.jpg'
    __CATEGORIES_FILENAME = 'XooML2.xml'
    __COLLECTION_FILE_NAME = 'XooML2.xml'
    __NOTE_FILE_NAME = 'XooML2.xml'
    __NOTE_IMG_FILE_NAME = 'img.jpg'
    __EMPTY_CATEGORIES = '<?xml version="1.0" encoding="UTF-8"?><root xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xooml="http://kftf.ischool.washington.edu/xmlns/xooml" xsi:schemaLocation="http://kftf.ischool.washington.edu/xmlns/xooml http://kftf.ischool.washington.edu/XMLschema/0.41/XooML.xsd"></root>'

    @staticmethod
    @gen.engine
    def __get_storage(user_id, callback):
        """
        Retrieve an instance of the current valid storage system for the user with user_id
        In future` if we add different storage mechanism it should be placed here
        """

        #Try cache
        account_info = \
            yield gen.Task(StorageServer.__cache.get_user_info, user_id)
        if account_info is not None:
            account_obj = json.loads(account_info)
            key = account_obj['key']
            secret = account_obj['secret']
            storage = DropboxHelper.create_client(key, secret)
            callback(storage)
        else:
            #get it from DB
            account_info = yield gen.Task(Accounts.get_account, user_id)
            if account_info is not None:
                key = account_info['ticket'][0]
                secret = account_info['ticket'][1]
                #cache it
                account_info_json = json.dumps({'key': key, 'secret': secret})
                yield gen.Task(StorageServer.__cache.set_user_info,
                               user_id, account_info_json)
                storage = DropboxHelper.create_client(key, secret)
                callback(storage)
            else:
                callback(None)

    @staticmethod
    @gen.engine
    def does_note_resource_exist(user_id, collection_name, note_name, resource_type, callback):
        """
        Determines whether a note xooml exists or note or the note folder
        itself exists or not

        -Args:
            -``user_id``: The id of the user
            -``colection_name``: The name of the collection in which the note
            eixsts
            -``note_name``: The name of the note to lookup
            -``resource_type``: A object of the type StorageResourceType
            determining what type of resource we look to check for existance

        -Returns:
            callback is called with True/False or None in case of an error
        """
        resource_name = ''
        if resource_type == StorageResourceType.NOTE_IMG:
            resource_name = StorageServer.__NOTE_IMG_FILE_NAME
        elif resource_type == StorageResourceType.NOTE_MANIFEST:
            resource_name = StorageServer.__NOTE_FILE_NAME

        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            path = '/'.join(['', collection_name, note_name, resource_name])
            result = yield gen.Task(DropboxHelper.does_file_exist, storage, path)
            callback(result)
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
        if storage is not None:
            result = yield gen.Task(DropboxHelper.get_folders, db_client=storage, parent_name="/",
                                    user_id=user_id)
            callback(result)
        else:
            callback([])

    @staticmethod
    @gen.engine
    def does_collection_exist(user_id, collection_name, callback):
        """
        determines whether collection_name exists in the user with user_id
        account

        Returns:
            - A boolean
        """
        col_list = yield gen.Task(StorageServer.list_collections, user_id)
        callback(collection_name in col_list)

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

            #Make the file a closure so that it will be enclosed in the callback
            file_closure = file
            if file_closure is not None:
                #If the collection does not exist the add_file call
                #automatically creates
                parent_path = '/' + collection_name
                result_code = yield gen.Task(DropboxHelper.add_file, storage, parent_path,
                                             file, file_name=StorageServer.__COLLECTION_FILE_NAME)
            else:
                result_code = yield gen.Task(DropboxHelper.create_folder, storage, collection_name)

            if result_code != StorageResponse.OK:
                StorageServer.__log.info('StorageServer - Received %s from dropbox' % str(result_code))

            callback(result_code)
        else:
            StorageServer.__log.info('StorageServer - Could not retrieve user storage for user %s' % user_id)
            callback(StorageResponse.SERVER_EXCEPTION)

    @staticmethod
    @gen.engine
    def save_collection_manifest(user_id, collection_name, manifest_file, callback):
        """
        Saves a collection manifest containing the description of the collection

        Args:
            - ``user_id``: user id corresponding to the user
            - ``collection_name``: The name of the collection to save the manifest.
            We assume that this name has been validate prior to calling
            - `manifest_file`: The file to save as manifest

        Returns:
            -A storageResponse status code that represents the status of the
            server will be passed to the callback
        """

        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            file_closure = manifest_file
            if file_closure is not None:

                parent_path = '/' + collection_name
                result_code = yield gen.Task(DropboxHelper.add_file, storage, parent_path,
                                             file_closure, file_name=StorageServer.__COLLECTION_FILE_NAME)
                if result_code != StorageResponse.OK:
                    StorageServer.__log.info(
                        'StorageServer - received error %s for user %s from dropbox' % (str(result_code), user_id))

                callback(result_code)
            else:
                StorageServer.__log.info('StorageServer - no file specified for manifest for user %s' % user_id)
                callback(StorageResponse.SERVER_EXCEPTION)
        else:
            StorageServer.__log.info('StorageServer - Could not retrieve user storage for user %s' % user_id)
            callback(StorageResponse.SERVER_EXCEPTION)

    @staticmethod
    @gen.engine
    def get_collection_manifest(user_id, collection_name, callback):

        """
        Returns the manifest for the collection

        Args:
            - ``user_id``: user id corresponding to the user
            - ``collection_name``: The name of the collection for which the
            manifest will be retrieved .

        Returns:
            - A file or a file like object containing the manifest or None if the
            image does not exist or there was a problem retrieving it
        """
        manifest_path = "/%s/%s" % (collection_name, StorageServer.__COLLECTION_FILE_NAME)
        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            response = yield gen.Task(DropboxHelper.get_file, storage, manifest_path)

            if response is None:
                StorageServer.__log.info('StorageServer - could not retrieve manifest file for user %s' % user_id)

            callback(response)
        else:
            StorageServer.__log.info('StorageServer - Could not retrieve user storage for user %s' % user_id)
            callback(None)

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

            if result_code != StorageResponse.OK:
                StorageServer.__log.info(
                    'StorageServer - received error %s for user %s from dropbox' % (str(result_code), user_id))
            callback(result_code)
        else:
            StorageServer.__log.info('StorageServer - Could not retrieve user storage for user %s' % user_id)
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

            if result_code != StorageResponse.OK:
                StorageServer.__log.info(
                    'StorageServer - received error %s for user %s from dropbox' % (str(result_code), user_id))

            callback(result_code)
        else:
            StorageServer.__log.info('StorageServer - Could not retrieve user storage for user %s' % user_id)
            callback(StorageResponse.SERVER_EXCEPTION)

    @staticmethod
    @gen.engine
    def get_thumbnail(user_id, collection_name, callback):
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
        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            response = yield gen.Task(DropboxHelper.get_file, storage, thumbnail_path)

            if response is None:
                StorageServer.__log.info('StorageServer - could not retreive thumbnail file for user %s' % user_id)

            callback(response)
        else:
            StorageServer.__log.info('StorageServer - Could not retrieve user storage for user %s' % user_id)
            callback(None)

    @staticmethod
    @gen.engine
    def add_thumbnail(user_id, collection_name, file, callback):
        """
        Adds a thumbnail image to the collection
        If the collection name does not exists it gets created

        Args:
            - ``user_id``: user id corresponding to the user
            - ``collection_name``: The name of the collection for which the
            thumbnails will be added

        Returns:

            -An StorageResponse indicating the result of the operation
        """

        thumbnail_path = "/%s" % collection_name
        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            file_closure = file
            response = yield gen.Task(DropboxHelper.add_file, storage, thumbnail_path,
                                      file_closure, file_name=StorageServer.__THUMBNAIL_FILENAME)

            if response != StorageResponse.OK:
                StorageServer.__log.info(
                    'StorageServer - received error %s for user %s from dropbox' % (str(response), user_id))

            callback(response)
        else:
            StorageServer.__log.info('StorageServer - Could not retrieve user storage for user %s' % user_id)
            callback(StorageResponse.SERVER_EXCEPTION)

    @staticmethod
    @gen.engine
    def get_categories(user_id, callback):
        """
        Retrieves the categories XML file for the user that categorizes the collections
        If no such file exists we create an empty categories file and save it then
        send it back to the user

        Returns:
            -An file like object containing the contents of the categories file
        """
        categories_path = '/' + StorageServer.__CATEGORIES_FILENAME
        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            response = yield gen.Task(DropboxHelper.get_file, storage, categories_path)
            if response is None:
                callback(None, StorageResponse.NOT_FOUND)
                #If file is not found create it
            callback(response, StorageResponse.OK)
        else:
            StorageServer.__log.info('StorageServer - Could not retrieve user storage for user %s' % user_id)
            callback(None, StorageResponse.SERVER_EXCEPTION)

    @staticmethod
    @gen.engine
    def save_categories(user_id, categories_file, callback):
        """
        Save a category file for the user with user_id

        Returns:
            - An StorageResponse code indicating the result of the operation
        """
        collections_path = '/'
        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            file_closure = categories_file
            if categories_file is None:
                StorageServer.__log.info('StorageServer - categories file empty for user %s' % user_id)
                callback(StorageResponse.SERVER_EXCEPTION)
            else:
                response = yield gen.Task(DropboxHelper.add_file, storage, collections_path,
                                          file_closure, file_name=StorageServer.__CATEGORIES_FILENAME)

                if response != StorageResponse.OK:
                    StorageServer.__log.info(
                        'StorageServer - received error %s for user %s from dropbox' % (str(response), user_id))

                callback(response)
        else:
            StorageServer.__log.info('StorageServer - Could not retrieve user storage for user %s' % user_id)
            callback(StorageResponse.SERVER_EXCEPTION)


    @staticmethod
    @gen.engine
    def remove_categories(user_id, callback):
        """
        Removes a category file.
        Theoretically this won't get used in production. Its only here to allow for
        clean up of tests
        """
        categories_path = '/' + StorageServer.__CATEGORIES_FILENAME
        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            result_code = yield gen.Task(DropboxHelper.delete_folder, storage, categories_path)

            if result_code != StorageResponse.OK:
                StorageServer.__log.info(
                    'StorageServer - received error %s for user %s from dropbox' % (str(result_code), user_id))
            callback(result_code)
        else:
            StorageServer.__log.info('StorageServer - Could not retrieve user storage for user %s' % user_id)
            callback(StorageResponse.SERVER_EXCEPTION)

    @staticmethod
    @gen.engine
    def add_note_to_collection(user_id, collection_name, note_name,
                               note_file, callback):
        """
        Adds a note with note_name to the collection.
        If note_file is presented it will put the note_file in the folder
        with the name note_name

        Args:
            -``user_id``: Id of the user making the request
            -``collection_name``: Name of the collection that the note
            will be placed inside of
            -``note_name``: Name of the note to be put in the collection
            -``note_file``: Optional, the file to be place under XooML2.xml
             inside the note. If it is None the note directory will be empty

        Returns:
            -The status code of the response will be passed to the callback
        """

        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            file_closure = note_file
            parent_path = '/'.join(['', collection_name, note_name])
            if file_closure is not None:
                result_code = yield gen.Task(DropboxHelper.add_file, storage, parent_path,
                                             note_file, file_name=StorageServer.__NOTE_FILE_NAME)
            else:
                result_code = yield gen.Task(DropboxHelper.create_folder, storage, parent_path)

            if result_code != StorageResponse.OK:
                StorageServer.__log.info(
                    'StorageServer - received error %s for user %s from dropbox' % (str(result_code), user_id))

            callback(result_code)
        else:
            StorageServer.__log.info('StorageServer - Could not retrieve user storage for user %s' % user_id)
            callback(StorageResponse.SERVER_EXCEPTION)

    @staticmethod
    @gen.engine
    def get_note_from_collection(user_id, collection_name, note_name, callback):
        """
        Retrurns the note Xooml for the specified note in the specified collection

        Args:
            -``user_id``: The Id of the user for which the note is retrieved
            -``collection_name``: The name of the collection inside which the note is
            -``note_name``: The name of the note for which to retrieve the xooml

        Returns:
            - A file or a file like object containing the image or None if the
            image does not exists; is passed to the callback.
        """

        note_path = '/'.join(['', collection_name, note_name, StorageServer.__NOTE_FILE_NAME])
        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            response = yield gen.Task(DropboxHelper.get_file, storage, note_path)
            if response is None:
                StorageServer.__log.info('StorageServer - Could not retrieve file for collection %s note %s user %s' % (
                    collection_name, note_name, user_id))
            callback(response)
        else:
            StorageServer.__log.info('StorageServer - Could not retrieve user storage for user %s' % user_id)
            callback(None)

    @staticmethod
    @gen.engine
    def add_image_to_note(user_id, collection_name, note_name, img_file, callback):
        """
        adds an image to a note. Every note can have at most one image.
        If an image already exists it will be replaced

            Args:
                -``user_id``: The user id of the user who is adding the image
                -``collection_name``: The name of the collection under which
                the note is located
                -``note_name``: The name of the note that should contain the image
                -``img_file``: A file or a file like structure that contains the image bytes

            Returns:
                - The status of the operation will be passed to the callback
        """
        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            file_closure = img_file
            parent_path = '/'.join(['', collection_name, note_name])
            if file_closure is None:
                StorageServer.__log.info('StorageServer - required file for image is missing for user %s' % user_id)
                callback(StorageResponse.BAD_REQUEST)
            else:

                #because the format of the image is not known we use jpg but
                #the consumer should decide what format it is from it img view
                #hopefully this decision is made by an image viewer and not the
                #client itself
                result_code = yield gen.Task(DropboxHelper.add_file, storage, parent_path,
                                             file_closure, file_name=StorageServer.__NOTE_IMG_FILE_NAME)

                if result_code != StorageResponse.OK:
                    StorageServer.__log.info(
                        'StorageServer - received error %s for user %s from dropbox' % (str(result_code), user_id))

                callback(result_code)
        else:
            StorageServer.__log.info('StorageServer - Could not retrieve user storage for user %s' % user_id)
            callback(StorageResponse.SERVER_EXCEPTION)

    @staticmethod
    @gen.engine
    def get_note_image(user_id, collection_name, note_name, callback):
        """
        Gets the image of the note for specified note

            Args:
                -``user_id``: The id of the user for which the note image is retrieved
                -``collection_name``: The name of the collection in which the note is situated
                -``Note_name``: The name of the note in which the image is placed

            Returns:
                - A file like object that contains the bytes of the img or None
                in case no img exists for that note
        """

        note_path = '/'.join(['', collection_name, note_name, StorageServer.__NOTE_IMG_FILE_NAME])
        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            response = yield gen.Task(DropboxHelper.get_file, storage, note_path)
            if response is None:
                StorageServer.__log.info(
                    'StorageServer - Could not retrieve img file for collection %s note %s user %s' % (
                        collection_name, note_name, user_id))
            callback(response)
        else:
            StorageServer.__log.info('StorageServer - Could not retrieve user storage for user %s' % user_id)
            callback(None)

    @staticmethod
    @gen.engine
    def remove_note(user_id, collection_name, note_name, callback):
        """
        Removes a note from a collection

        Args:
            - ``user_id``: user id corresponding to the user
            - ``collection_name``: The name of the collection
            It is assumed that this name has been validated prior to calling
            this function
            -``note_name``: The name of the note to be deleted

        Returns:
            - A StorageResponse status code that represents the status of the operation
            """

        path = '/' + collection_name + '/' + note_name
        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        if storage is not None:
            result_code = yield gen.Task(DropboxHelper.delete_folder, storage, path)

            if result_code != StorageResponse.OK:
                StorageServer.__log.info(
                    'StorageServer - received error %s for user %s from dropbox' % (str(result_code), user_id))

            callback(result_code)
        else:
            StorageServer.__log.info('StorageServer - Could not retrieve user storage for user %s' % user_id)
            callback(StorageResponse.SERVER_EXCEPTION)

    @staticmethod
    @gen.engine
    def list_all_notes(user_id, collection_name, callback):
        """
        List all the notes in the given collection

        Args:
            -``user_id``: the id of the user for which the notes will be listed
            -``collection_name``: The name of the collection which contains the notes

        Returns:
            - A list containing the name of all the notes available in the
            collection will be passed to the callback method
        """

        storage = yield gen.Task(StorageServer.__get_storage, user_id)
        path = '/' + collection_name + '/'
        if storage is not None:
            result = yield gen.Task(DropboxHelper.get_folders,
                                    db_client=storage, parent_name=path, user_id=user_id)
            callback(result)
        else:
            callback([])

    @staticmethod
    @gen.engine
    def copy_collection_between_accounts(src_user_id,
                                         dest_user_id,
                                         src_collection_name,
                                         dest_collection_name,
                                         callback):
        """
        Copies src collection from the src account to the dest collection in
        dest user accout. This assumes that input has been sanitised before,
        src collection exists in the src user and dest collection does not
        exist in the dest user account.

        Args:
            -``src_user_id``: The id for the user that hold the src collection
            -``dest_user_id``: The id for the user that will receive the src collection
            -``src_collection_name``: The name of the collection to be copied
            from src user account
            -``dest_collection_name``: The name of the collection that the src
            collection will be copied as

        Returns:
            - The response code of the operation will be passed to the callback
        """

        src_storage = yield gen.Task(StorageServer.__get_storage,
                                     src_user_id)
        dest_storage = yield gen.Task(StorageServer.__get_storage,
                                      dest_user_id)
        if src_storage is not None and dest_storage is not None:
            response_code = yield gen.Task(DropboxHelper.copy_folder_between_accounts,
                                           src_storage,
                                           dest_storage,
                                           '/' + src_collection_name,
                                           '/' + dest_collection_name)
            if response_code != StorageResponse.OK:
                StorageServer.__log.info('StorageServer - received error %s for user %s  and %s from dropbox' % (
                    str(response_code), src_user_id, dest_user_id))

            callback(response_code)
        else:
            StorageServer.__log.info(
                'StorageServer - Could not retrieve user storage for user %s and %s' % (src_user_id, dest_user_id))
            callback(StorageResponse.SERVER_EXCEPTION)

