"""
The main torndao application runner
"""
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.httpclient
from Handlers.CategoriesHandler import CategoriesHandler

from Handlers.CollectionHandler import CollectionHandler
from Handlers.CollectionImageHandler import CollectionImageHandler
from Handlers.AccountHandler import AccountHandler
from Handlers.AuthorizationHandler import AuthorizationHandler

class Application(tornado.web.Application):
    """
    The Webserver instance
    """

    def __init__(self):

        handlers = [
            (r"/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})/Collections/([\w+%*\d*]+)", CollectionHandler),
            (r"/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})/Collections/([\w+%*\d*]+)/Notes", NotesHandler),
            (r"/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})/Collections/([\w+%*\d*]+)/Thumbnail", CollectionImageHandler),
            (r"/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})/Collections", AccountHandler),
            (r"/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})/Categories", CategoriesHandler),
            (r"/Authorize/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})", AuthorizationHandler)
        ]
        tornado.web.Application.__init__(self, handlers)

if __name__ == "__main__":

    tornado.options.parse_command_line()
    app = Application()
    server = tornado.httpserver.HTTPServer(app)
    server.listen(8000)
    tornado.ioloop.IOLoop.instance().start()

