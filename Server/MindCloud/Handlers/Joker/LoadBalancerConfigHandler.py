import json
from tornado import gen
from Logging import Log
from Sharing.SharingLoadBalancer import SharingLoadBalancer

__author__ = 'afathali'
import tornado.web
from Sharing.SharingSpaceStorage import SharingSpaceStorage
from Properties.MindcloudProperties import Properties


class LoadBalancerConfigHandler(tornado.web.RequestHandler):

    __log = Log.log()

    @tornado.web.asynchronous
    @gen.engine
    def post(self, args=None):

        self.__log.info("LoadBalancerConfig - Adding Servers")

        try:
            operation = self.get_argument('operation', default='')
            server = self.get_argument('address', default='')
            server_addresses = [server]
            if len(operation) == 0 or len(server) == 0:
                servers_str = self.get_argument('servers')
                servers_json_obj = json.loads(servers_str)
                operation = str(servers_json_obj['operation'])
                server_addresses = servers_json_obj['addresses']

            server_list = []
            if operation == 'add_servers':
                for server in server_addresses:
                    if server not in Properties.sharing_space_servers:
                        server_list.append(str(server))

                if len(server_list) > 0:
                    for server_address in server_list:
                        Properties.sharing_space_servers.append(server_address)

                    load_balancer = SharingLoadBalancer.get_instance()
                    load_balancer.add_servers(server_list)

                self.__log.info("LoadBalancerConfig - added servers " + str(server_list))
                print Properties.sharing_space_servers
                self.set_status(200)
                self.finish()

            elif operation == 'remove_servers':
                for server in server_addresses:
                    if str(server) in Properties.sharing_space_servers:
                        server_list.append(str(server))

                if len(server_list) > 0:
                    for server_address in server_list:
                        Properties.sharing_space_servers.remove(server_address)

                    load_balancer = SharingLoadBalancer.get_instance()
                    load_balancer.remove_servers(server_list)


                self.__log.info("LoadBalancerConfig - removed servers " + str(server_list))
                print Properties.sharing_space_servers
                self.set_status(200)
                self.finish()
        except Exception:

            self.set_status(400)
            self.finish()
