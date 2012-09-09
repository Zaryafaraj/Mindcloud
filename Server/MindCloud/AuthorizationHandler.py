import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from DropboxHelper import DropboxHelper
class AuthorizationHandler(tornado.web.RequestHandler):

    def get(self):
        #FIXME what is the cost of making this object ? Is it better to use a static function
        dropbox_helper = DropboxHelper()
        url = dropbox_helper.getAuthorizationURL()
        self.write(url)
        print "get"

if __name__ == "__main__":
    print 'hi'
