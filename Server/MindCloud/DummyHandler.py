import tornado.web
from AsynchDropbox.session import AsyncDropboxSession

__author__ = 'afathali'

class DummyHandler(tornado.web.RequestHandler):

    __APP_KEY =  'h7f38af0ewivq6s'
    __APP_SECRET = 'iiq8oz2lae46mwp'
    __ACCESS_TYPE = 'app_folder'

    sess = AsyncDropboxSession(__APP_KEY, __APP_SECRET,
       __ACCESS_TYPE)

    @tornado.web.asynchronous
    def get(self, word):
        self.sess.obtain_request_token(callback=self.on_response)

    def on_response(self, url):
        self.write(url)
        self.finish()
