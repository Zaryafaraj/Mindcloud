import tornado.web
from Properties.MindcloudProperties import Properties
from Sharing.SharingSpaceStorage import SharingSpaceStorage

__author__ = 'afathali'


class LoadBalancerHealthCheckHandler(tornado.web.RequestHandler):

    def get(self, args=None):
        self.write('You Complete Me ***')
        servers = Properties.sharing_space_servers
        self.write('Sharing Servers : ' + str(servers) + '***')
        self.finish()
