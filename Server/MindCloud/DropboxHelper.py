# Include the Dropbox SDK libraries
from dropbox import client, rest, session

class DropboxHelper:

    APP_KEY =  'h7f38af0ewivq6s'
    APP_SECRET = 'iiq8oz2lae46mwp'

    ACCESS_TYPE = 'app_folder'
    sess = session.DropboxSession(APP_KEY, APP_SECRET, ACCESS_TYPE)

    def getAuthorizationURL(self):
        request_token = self.sess.obtain_request_token()
        authorization_url = self.sess.build_authorize_url(request_token)
        return authorization_url
