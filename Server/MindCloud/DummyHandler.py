import tornado.web
from MindCloud.AsynchDropbox.session import AsyncDropboxSession

__author__ = 'afathali'

class DummyHandler(tornado.web.RequestHandler):

    __APP_KEY =  'h7f38af0ewivq6s'
    __APP_SECRET = 'iiq8oz2lae46mwp'
    __ACCESS_TYPE = 'app_folder'

    @tornado.web.asynchronous
    def get(self, word):
        self.write("hi")
        sess = AsyncDropboxSession(self.__APP_KEY, self.__APP_SECRET,
            self.__ACCESS_TYPE)
        sess.obtain_request_token(callback=self.on_response)

    def on_response(self, url):
        self.write(url)
        self.finish()
