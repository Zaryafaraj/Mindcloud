__author__ = 'afathali'

from dropbox import session

class DropboxHelper:

    __APP_KEY =  'h7f38af0ewivq6s'
    __APP_SECRET = 'iiq8oz2lae46mwp'
    __ACCESS_TYPE = 'app_folder'

    @staticmethod
    def create_session():
        sess = session.DropboxSession(DropboxHelper.__APP_KEY,
            DropboxHelper.__APP_SECRET, DropboxHelper.__ACCESS_TYPE)
        return sess



