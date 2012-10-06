__author__ = 'afathali'
import tornado.web
from dropbox import session

class DummyHandlerSynch(tornado.web.RequestHandler):

    __APP_KEY =  'h7f38af0ewivq6s'
    __APP_SECRET = 'iiq8oz2lae46mwp'
    __ACCESS_TYPE = 'app_folder'

    sess = session.DropboxSession(__APP_KEY, __APP_SECRET, __ACCESS_TYPE)

    def get(self, word):
        token = self.sess.obtain_request_token()
        url = self.sess.build_authorize_url(token)
        self.write(url)

