import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web

class CollectionHandler(tornado.web.RequestHandler):
    def get(self):
        self.write('Go To Sleep')
