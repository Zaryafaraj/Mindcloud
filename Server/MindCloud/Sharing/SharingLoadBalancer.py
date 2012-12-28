from Logging import Log
import heapq
from tornado import gen
from Cache.MindcloudCache import MindcloudCache
from Properties.MindcloudProperties import Properties
from Sharing.SharingController import SharingController

__author__ = 'afathali'


class SharingLoadBalancer():

    __instance = None

    __log = Log.log()

    def __init__(self):

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

    @classmethod
    def get_instance(cls):
        if not cls.__instance:
            cls.__instance = SharingLoadBalancer()
        return cls.__instance

    @gen.engine
    def get_sharing_space_info(self, sharing_secret, callback):

        #if it exists in the already available shared spaces; then return it
        if sharing_secret is in self.sharing_spaces:
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
                yield gen.Task(MindcloudCache.set_sharing_space_server, sharing_secret, server)

                #return the server address to the client and tell it that its
                #cached in memcached now
                answer = {'server' : self.sharing_spaces[sharing_secret],
                        'cached' : 'True'}
                callback(answer)


    def remove_sharing_space_info(self, sharing_secret):
        pass
