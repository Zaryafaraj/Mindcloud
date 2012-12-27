import json
from tornado import gen
import tornado.web

__author__ = 'afathali'

class SharingLoadBalancerHandler(tornado.web.RequestHandler):

    @tornado.web.asynchronous
    @gen.engine
    def get(self, sharing_secret):
        load_balancer = SharingLoadBalancer.get_instance()
        sharing_server_info_dict = load_balancer.get_sharing_space_info(sharing_secret)
        if sharing_server_info_dict is None:
            self.set_status(404)
            self.finish()
        else :
            self.set_status(200)
            json_str = json.dumps(sharing_server_info_dict)
            self.write(json_str)
            self.finish()



