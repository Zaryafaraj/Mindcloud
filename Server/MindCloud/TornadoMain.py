import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.httpclient

from CollectionHandler import CollectionHandler
from AccountHandler import AccountHandler

class Application(tornado.web.Application):

    def __init__(self):
        handlers = [
            (r"/Collections/(\w+)", CollectionHandler),
            (r"/Collections/", AccountHandler)
        ]
        tornado.web.Application.__init__(self, handlers)

if __name__ == "__main__":
    tornado.options.parse_command_line()

    app = Application()
    server = tornado.httpserver.HTTPServer(app)
    server.listen(8000)
    tornado.ioloop.IOLoop.instance().start()

