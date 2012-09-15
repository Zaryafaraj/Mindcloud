"""
The main torndao application runner
"""
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.httpclient

from CollectionHandler import CollectionHandler
from AccountHandler import AccountHandler
from AuthorizationHandler import AuthorizationHandler

class Application(tornado.web.Application):
    """
    The Webserver instance
    """

    def __init__(self):

        handlers = [
            (r"/Collections/(\w+)", CollectionHandler),
            (r"/Collections/", AccountHandler),
            #FIXME is this restful ?
            (r"/Authorize/(\w+)", AuthorizationHandler)
        ]
        tornado.web.Application.__init__(self, handlers)

if __name__ == "__main__":

    tornado.options.parse_command_line()
    app = Application()
    server = tornado.httpserver.HTTPServer(app)
    server.listen(8000)
    tornado.ioloop.IOLoop.instance().start()

