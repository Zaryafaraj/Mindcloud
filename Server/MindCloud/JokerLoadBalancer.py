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
            #Joker
            (r"/SharingFactory/([0-9A-Za-z]{8})", SharingLoadBalancerHandler),
        ]
        tornado.web.Application.__init__(self, handlers)

if __name__ == "__main__":

    tornado.options.parse_command_line()
    app = Application()
    server = tornado.httpserver.HTTPServer(app)
    server.listen(8003)
    tornado.ioloop.IOLoop.instance().start()

