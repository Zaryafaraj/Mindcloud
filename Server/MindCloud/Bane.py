"""
The main torndao application runner
"""
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.httpclient
from Handlers.Bane.CategoriesHandler import CategoriesHandler

from Handlers.Bane.CollectionHandler import CollectionHandler
from Handlers.Bane.CollectionImageHandler import CollectionImageHandler
from Handlers.Bane.AccountHandler import AccountHandler
from Handlers.Bane.AuthorizationHandler import AuthorizationHandler
from Handlers.Bane.CollectionNotesHandler import CollectionNotesHandler
from Handlers.Bane.NoteHandler import NoteHandler
from Handlers.Bane.NoteImageHandler import NoteImageHandler
from Handlers.Bane.SharingSubscriptionHandler import SharingSubscriptionHandler
from Handlers.Bane.SharingHandler import SharingHandler
from Handlers.Bane.SubscriptionHandler import SubscriptionHandler
from Handlers.Joker.SharingLoadBalancerHandler import SharingLoadBalancer, SharingLoadBalancerHandler
from Handlers.Joker.SharingSpaceActionHandler import SharingSpaceActionHandler
from Handlers.Joker.SharingSpaceListenerHandler import SharingSpaceListenerHandler

class Application(tornado.web.Application):
    """
    The Webserver instance
    """

    def __init__(self):

        handlers = [
            #Bane
            (r"/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})/Collections/([\w+\-*%*\d*]+)", CollectionHandler),
            (r"/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})/Collections/([\w+\-*%*\d*]+)/Share", SharingHandler),
            (r"/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})/Collections/ShareSpaces/Subscribe", SharingSubscriptionHandler),
            (r"/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})/Collections/([\w+\-*%*\d*]+)/Subscribe", SubscriptionHandler),
            (r"/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})/Collections/([\w+\-*%*\d*]+)/Notes", CollectionNotesHandler),
            (r"/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})/Collections/([\w+\-*%*\d*]+)/Notes/([\w+\-*%*\d*]+)", NoteHandler),
            (r"/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})/Collections/([\w+\-*%*\d*]+)/Notes/([\w+\-*%*\d*]+)/Image", NoteImageHandler),
            (r"/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})/Collections/([\w+\-*%*\d*]+)/Thumbnail", CollectionImageHandler),
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

