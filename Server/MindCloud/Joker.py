"""
The main torndao application runner
"""
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.httpclient
from AutoConfig import Announcer
from Handlers.Joker.JokerHealthCheckHandler import JokerHealthCheckHandler
from Handlers.Joker.SharingSpaceActionHandler import SharingSpaceActionHandler
from Handlers.Joker.SharingSpaceListenerHandler import SharingSpaceListenerHandler
from Properties import MindcloudProperties

class Application(tornado.web.Application):
    """
    The Webserver instance
    """

    def __init__(self):

        handlers = [
            (r"/SharingSpace/([0-9A-Za-z]{8})/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})/([\w+\-*%*\d*]+)/([\w+\-*%*\d*]+)/(\w+)", SharingSpaceActionHandler),
            (r"/SharingSpace/([0-9A-Za-z]{8})/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})/([\w+\-*%*\d*]+)/(\w+)", SharingSpaceActionHandler),
            (r"/SharingSpace/([0-9A-Za-z]{8})", SharingSpaceActionHandler),
            (r"/SharingSpace/([0-9A-Za-z]{8})/Listen/([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})", SharingSpaceListenerHandler),
            (r"/HealthCheck", JokerHealthCheckHandler)
        ]
        tornado.web.Application.__init__(self, handlers)

if __name__ == "__main__":

    tornado.options.parse_command_line()
    app = Application()
    server = tornado.httpserver.HTTPServer(app)
    port = 8006
    myAddress = MindcloudProperties.Properties.my_ip_address
    server.listen(port)
    Announcer.i_am_alive(myAddress, port, MindcloudProperties.Properties.load_balancer_url)
    tornado.ioloop.IOLoop.instance().start()

