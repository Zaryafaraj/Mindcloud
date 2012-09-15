import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web


class AccountHandler(tornado.web.RequestHandler):

    def get(self):
        self.write('all the collections')
        print "get"

if __name__ == "__main__":
    print 'hi'
