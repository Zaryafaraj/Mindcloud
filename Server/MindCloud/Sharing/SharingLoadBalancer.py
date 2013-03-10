from Logging import Log
import heapq
from threading import Timer
from tornado import gen
from tornado.httpclient import HTTPClient
from Cache.MindcloudCache import MindcloudCache
from Properties import MindcloudProperties
from Properties.MindcloudProperties import Properties
from Sharing.SharingController import SharingController

__author__ = 'afathali'


class SharingLoadBalancer():

    __instance = None

    __log = Log.log()

    HEALTHCHECK_PERIOD = MindcloudProperties.Properties.load_balancer_healtcheck_period

    def __init__(self):
        """
        Singletone don't use this except for testing purposes
        """
        #public for testing purposes don't use for logic
        self.servers = Properties.sharing_space_servers
        #We use the heap to store servers prioritized on their load
        self.__heap = []
        for server in self.servers:
            heapq.heappush(self.__heap, (0, server))

        if not len(self.__heap):
            self.__log.info('SharingLoadBalancer - no sharing servers available')
        # A mapping between sharing_secret and servers
        #public for testing purposes don't use for logic
        self.sharing_spaces = {}
        self.timer = Timer(self.HEALTHCHECK_PERIOD, self.__healthcheck)
        self.timer.start()

    #since this is done in another thread do it synchronisly
    @gen.engine
    def __healthcheck(self):
        for server in self.servers:
            url = '/'.join([server,'HealthCheck'])
            self.__log.info('HealthCheck for : ' + server)
            http = HTTPClient()
            try:
                response = http.fetch(url,
                    connect_timeout= 5, request_timeout=5)
                if response.code != 200:
                    self.__log.info('HealthCheck failed, removing server for : ' + server)
                    self.remove_servers([server])
                http.close()
            except Exception:
                self.__log.info('HealthCheck failed, removing server for : ' + server)
                http.close()
                self.remove_servers([server])

        self.timer = Timer(self.HEALTHCHECK_PERIOD, self.__healthcheck)
        self.timer.start()

    @classmethod
    def get_instance(cls):
        if not cls.__instance:
            cls.__instance = SharingLoadBalancer()
        return cls.__instance

    def refresh_servers(self):
        self.servers = Properties.sharing_space_servers

    def add_servers(self, server_names):
        for server in server_names:
            heapq.heappush(self.__heap, (0, server))
            if server not in self.servers:
                self.servers.append(server)

    @gen.engine
    def remove_servers(self, server_names):
        to_delete_sharing_spaces = []
        for sharing_secret in self.sharing_spaces:
            if self.sharing_spaces[sharing_secret] in server_names:
                to_delete_sharing_spaces.append(sharing_secret)

        for sharing_secret in to_delete_sharing_spaces:
            self.remove_server_for_sharing_secret(sharing_secret)

        for server_name in server_names:
            self.remove_server_from_heap(server_name)
            if server_name in self.servers:
                self.servers.remove(server_name)



    @gen.engine
    def get_sharing_space_info(self, sharing_secret, callback):

        #if it exists in the already available shared spaces; then return it
        if sharing_secret in self.sharing_spaces:
            self.__log.info('LoadBalancer - Got server from cache: ' + self.sharing_spaces[sharing_secret])
            answer = {'server' : self.sharing_spaces[sharing_secret],
                      'cached' : 'True'}
            callback(answer)

        else:
            #if not get the sharing record and find the number of collaborators
            self.__log.info('SharingLoadBalancer - assigning servers to the sharing space %s' % sharing_secret)
            sharing_record =\
                yield gen.Task(SharingController.get_sharing_record_by_secret,
                    sharing_secret)
            if sharing_record is None:
                self.__log.info('SharingLoadBalancer - invalid sharing secret %s' % sharing_secret)
                callback(None)
            elif not len(self.__heap):
                self.__log.info('SharingLoadBalancer - no servers available')
                callback(None)

            else:
                subscribers = sharing_record.get_subscribers()
                subcriber_len = len(subscribers)

                #pop the server with smallest load and add the collaborators
                #to its weight.
                item = heapq.heappop(self.__heap)
                server = item[1]
                weight = item[0]
                weight += subcriber_len
                heapq.heappush(self.__heap, (weight, server))

                #now map the sharing_secret to the server address and put it in the map
                self.sharing_spaces[sharing_secret] = server

                #cache the server address so the client can later retrieve it
                cache = MindcloudCache()
                yield gen.Task(cache.set_sharing_space_server, sharing_secret, server)

                #return the server address to the client and tell it that its
                #cached in memcached now
                answer = {'server' : self.sharing_spaces[sharing_secret],
                        'cached' : 'True'}
                callback(answer)

    def is_sharing_space_cached(self, sharing_secret):
        return sharing_secret in self.sharing_spaces

    def remove_server_from_heap(self, server_name):
        self.__log.info('SharingLoadBalancer - purging cache for server %s' %  server_name)
        index_list = [self.__heap.index(item)
                      for item in self.__heap if item[1] == server_name]
        index_len = len(index_list)
        if not index_len:
            self.__log.info('SharingLoadBalancer - no server for address %s' % server_name)
        elif index_len > 1:
            self.__log.info('SharingLoadBalancer - more than one server for addres %s' % server_name)
        else:
            index = index_list[0]
            self.__heap[index] = self.__heap[-1]
            self.__heap.pop()
            heapq.heapify(self.__heap)
            #remove it from the sharing_spaces
            self.__log.info('SharingLoadBalancer - sharing server removed :' + server_name)

    def remove_server_for_sharing_secret(self, sharing_secret):
        if sharing_secret not in self.sharing_spaces:
            self.__log.info('SharingLoadBalancer - no cached server for sharing space for secret %s' % sharing_secret)
        else:
            del self.sharing_spaces[sharing_secret]

    @gen.engine
    def remove_sharing_space_info(self, sharing_secret, callback):

        if sharing_secret not in self.sharing_spaces:
            self.__log.info('SharingLoadBalancer - no cached server for sharing space for secret %s' % sharing_secret)
            callback()
        else:
            server_name = self.sharing_spaces[sharing_secret]
            self.__log.info('SharingLoadBalancer - purging cache for sharing_secret %s and server %s' % (sharing_secret, server_name))

            #remove the load associated with the sharing space from the
            #heap
            sharing_record = yield gen.Task(SharingController.get_sharing_record_by_secret,
                sharing_secret)
            if sharing_record is None:
                self.__log.info('SharingLoadBalancer - invalid sharing secret %s' % sharing_secret)
                callback(None)
            else:
                subscribers = sharing_record.get_subscribers()
                subcriber_len = len(subscribers)
                #remove the item from heap
                #because items are of tuple (load, server_name) we need to do it like this
                index_list = [self.__heap.index(item)
                              for item in self.__heap if item[1] == server_name]
                index_len = len(index_list)
                if not index_len:
                    self.__log.info('SharingLoadBalancer - no server for sharing secret %s' % sharing_secret)
                    callback()
                elif index_len > 1:
                    self.__log.info('SharingLoadBalancer - more than one server for sharing secret %s' % sharing_secret)
                    callback()
                else:
                    index = index_list[0]
                    server_record = self.__heap[index]
                    new_server_name = server_record[1]
                    new_server_weight = server_record[0]
                    new_server_weight -= subcriber_len
                    self.__heap[index] = self.__heap[-1]
                    self.__heap.pop()
                    heapq.heapify(self.__heap)
                    heapq.heappush(self.__heap, (new_server_weight, new_server_name))

                    #remove it from the sharing_spaces
                    del self.sharing_spaces[sharing_secret]
                    #last remove it from the cache
                    cache = MindcloudCache()
                    yield gen.Task(cache.remove_sharing_space_server, sharing_secret)
                    callback()


