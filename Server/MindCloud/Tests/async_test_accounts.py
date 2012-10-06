from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from MindCloud.AsynchDropbox.session import AsyncDropboxSession
__author__ = 'afathali'

class accountTestCase(AsyncTestCase):
    __APP_KEY =  'h7f38af0ewivq6s'
    __APP_SECRET = 'iiq8oz2lae46mwp'
    __ACCESS_TYPE = 'app_folder'
    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_get_request_token(self):
        sess = AsyncDropboxSession(self.__APP_KEY, self.__APP_SECRET,
            self.__ACCESS_TYPE)
        sess.obtain_request_token(callback=self.stop)
        response = self.wait()
        self.assertIn('dropbox', response)
