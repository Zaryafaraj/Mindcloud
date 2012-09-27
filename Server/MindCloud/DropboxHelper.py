__author__ = 'afathali'

from dropbox import session, client

class DropboxHelper:

    __APP_KEY =  'h7f38af0ewivq6s'
    __APP_SECRET = 'iiq8oz2lae46mwp'
    __ACCESS_TYPE = 'app_folder'

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


