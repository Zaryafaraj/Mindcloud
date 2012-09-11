# Include the Dropbox SDK libraries
from dropbox import client, rest, session
from dropbox.rest import ErrorResponse


class DropboxHelper:


    def __init__(self):
        #TODO remove these they should be in another class or in a file
        self.APP_KEY =  'h7f38af0ewivq6s'
        self.APP_SECRET = 'iiq8oz2lae46mwp'
        self.ACCESS_TYPE = 'app_folder'
        self.__sess = session.DropboxSession(self.APP_KEY, self.APP_SECRET, self.ACCESS_TYPE)
        self.sessionReady = False

    def getAuthorizationURL(self):
        """
        Gets a url to be presented to the first time user to allow access to his dropbox
        """
        self.request_token = self.__sess.obtain_request_token()
        #Save for later use
        return self.request_token

    def createAccessToken(self, request_token=None):
        if (not request_token):
            request_token = self.request_token
        access_token = self.__sess.obtain_access_token(request_token)
        self.sessionReady = True
        return access_token

    def setSessionAccessToken(self, access_token):
        if(not access_token):
            self.__sess.token = access_token
            self.sessionReady = True

    def getSession(self):
        if(self.sessionReady):
            return self.__sess
        return None

