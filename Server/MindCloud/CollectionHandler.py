"""
Mocking handlers
"""
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web


class CollectionHandler(tornado.web.RequestHandler):

    def get(self, word):
        self.write('all the collections')
        print "GET"
        print word

    def post(self, word):
        print "POST"
        print word

    def put(self, word):
        print "PUT"
        print word

    def delete(self, word):
        print "DELETE"
        print word

if __name__ == "__main__":
    print 'hi'
