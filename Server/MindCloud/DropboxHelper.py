__author__ = 'afathali'

from dropbox import session, client, rest
from StorageResponse import StorageResponse

class DropboxHelper:

    __APP_KEY =  'h7f38af0ewivq6s'
    __APP_SECRET = 'iiq8oz2lae46mwp'
    __ACCESS_TYPE = 'app_folder'

    CONTENT_KEY = 'contents'
    PATH_KEY = 'path'
    IS_DIR = 'is_dir'

    @staticmethod
    def create_session():
        sess = session.DropboxSession(DropboxHelper.__APP_KEY,
            DropboxHelper.__APP_SECRET, DropboxHelper.__ACCESS_TYPE)
        return sess

    @staticmethod
    def create_client(key, secret):

        sess = DropboxHelper.create_session()
        sess.set_token(key, secret)
        db_client = client.DropboxClient(sess)
        return db_client

    @staticmethod
    def get_folders(db_client, parent_name, user_id = 'unknown'):

        try:
            metadata = db_client.metadata(parent_name)
            contents = metadata[DropboxHelper.CONTENT_KEY]
            #Pythonic Zen master \m/
            #Filter the name of the folders from the root metadata
            result = [content[DropboxHelper.PATH_KEY].replace("/","")
                      for content in contents if content[DropboxHelper.IS_DIR] == True]
            return result

        except rest.ErrorResponse as exception:
            print "user: " + user_id + ": " + exception.status + ": " + exception.error_msg
            return []

    @staticmethod
    def create_folder(db_client, folder_name, parent_folder = '/'):
        try:
            db_client.file_create_folder("/".join([parent_folder,folder_name]))
            return StorageResponse.OK

        except rest.ErrorResponse as exception:
        #if the folder already exists notify the user
            if exception.status == 403:
                return StorageResponse.DUPLICATED
            else:
                print exception.status + ": " + exception.error_msg
                return StorageResponse.SERVER_EXCEPTION

