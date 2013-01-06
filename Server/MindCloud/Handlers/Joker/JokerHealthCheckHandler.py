import tornado.web
from Properties.MindcloudProperties import Properties
from Sharing.SharingSpaceStorage import SharingSpaceStorage

__author__ = 'afathali'


class JokerHealthCheckHandler(tornado.web.RequestHandler):

    def get(self, args=None):
        self.write('Why So Serious ? ***')
        self.write('Load Balancer : ' + Properties.load_balancer_url +'***')
        sharing_space_count = \
            SharingSpaceStorage.get_instance().get_sharing_space_count()
        self.write('Number of Sharing Spaces on Server: ' + str(sharing_space_count))
        self.finish()
