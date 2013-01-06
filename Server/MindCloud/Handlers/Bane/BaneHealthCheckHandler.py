__author__ = 'afathali'
import tornado.web
from Properties.MindcloudProperties import Properties
from Sharing.SharingSpaceStorage import SharingSpaceStorage


class BaneHealthCheckHandler(tornado.web.RequestHandler):

    def get(self, args=None):
        self.write('Deshi Basara ***')
        self.write('Load Balancer : ' + Properties.load_balancer_url +'***')
        self.finish()
