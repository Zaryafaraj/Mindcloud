import json
from tornado import gen
import tornado.web
from Logging import Log
from Sharing.SharingLoadBalancer import SharingLoadBalancer

__author__ = 'afathali'

class SharingLoadBalancerHandler(tornado.web.RequestHandler):

    __log = Log.log()

    @tornado.web.asynchronous
    @gen.engine
    def get(self, sharing_secret):
        load_balancer = SharingLoadBalancer.get_instance()
        sharing_server_info_dict = load_balancer.get_sharing_space_info(sharing_secret)
        if sharing_server_info_dict is None:
            self.set_status(404)
            self.finish()
        else :
            self.__log.info('SharingLoadBalancer - Querying sharing space %s from load balancer' % sharing_secret)

            self.set_status(200)
            json_str = json.dumps(sharing_server_info_dict)
            self.write(json_str)
            self.finish()

    def delete(self, sharing_secret):

        self.__log.info('SharingLoadBalancer - removing sharing space %s from load balancer info' % sharing_secret)
        load_balancer = SharingLoadBalancer.get_instance()
        load_balancer.remove_sharing_space_info(sharing_secret)
        self.set_status(200)
        self.finish()





