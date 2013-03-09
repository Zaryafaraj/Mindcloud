from threading import Timer
from Logging import Log
from tornado import gen
from tornado.httpclient import AsyncHTTPClient
from Properties import MindcloudProperties
from Properties.MindcloudProperties import Properties
from Sharing.SharingController import SharingController
from Sharing.SharingSpaceController import SharingSpaceController

__author__ = 'afathali'

class SharingSpaceStorage():


    __instance = None

    __log = Log.log()

    #There is a cleanup service running every hour to remove idle
    #sharing spaces
    #In each __sweep the cleanup service removes and deletes
    #all the sharing space in candidates. Then it nominates every sharing
    #space as a candidate.
    # Every time that the get sharing space is called it means that particular
    # sharing space is not idle, so it gets removed from the candidates
    # until the next hour in which the cleanup service nominates it again

    SWEEP_PERIOD = MindcloudProperties.Properties.sharing_space_cleanup_sweep_period

    def __init__(self):
        self.__remove_candidates = {}
        self.__sharing_spaces = {}
        print self.SWEEP_PERIOD
        self.timer = Timer(self.SWEEP_PERIOD, self.__sweep)
        self.timer.start()

    @classmethod
    def get_instance(cls):
        if not cls.__instance:
            cls.__instance = SharingSpaceStorage()

        return  cls.__instance

    def get_sharing_space_count(self):
        """
        Returns the number of sharing spaces this storage holds
        """
        return len(self.__sharing_spaces)

    def get_remove_candidate_count(self):
        """
        For testing purposes gives the number of items that
        are candidates for removal
        """
        return len(self.__remove_candidates)

    def start_cleanup_service(self):
        self.timer = Timer(self.SWEEP_PERIOD, self.__sweep)
        self.timer.start()

    def stop_cleanup_service(self):
        self.timer.cancel()

    def reset_cleanup_timer(self):
        self.timer.cancel()
        self.timer = Timer(self.SWEEP_PERIOD, self.__sweep)
        self.timer.start()

    def clear(self):
        self.__remove_candidates.clear()
        self.__sharing_spaces.clear()

    def __sweep(self):
        """
        the function called by the cleanup service
        """
        #print 'candid: ' + str(len(self.__remove_candidates))
        self.__log.info('cleanup service - Sweep started')
        for sharing_secret in self.__remove_candidates:
            #cleanup all the listeners
            candidate = self.__remove_candidates[sharing_secret]
            #In case a lot of actions are waiting to be executed
            #and are clogged in the space, don't clean it up give it
            #a chance for another sweeping period
            if not candidate.is_being_processed():
                self.__log.info('cleanup service - cleaning candidate for %s' % sharing_secret)
                candidate.cleanup()
                #notify the load balancer of the cleanup
                http = AsyncHTTPClient()
                load_balancer = Properties.load_balancer_url
                url = '/'.join([load_balancer, 'SharingFactory',sharing_secret])
                http.fetch(url, method='DELETE', callback=None)
                #yield gen.Task(http.fetch, url, method = 'DELETE')
                #remove if from stored sharing spaces
                del(self.__sharing_spaces[sharing_secret])
            else:
                candidate.give_opprotunity_to_be_processed()
                self.__log.info('cleanup service - skipping cleaning candidate for %s is being processed' % sharing_secret)


        #now nominate every one
        self.__remove_candidates.clear()
        for sharing_secret in self.__sharing_spaces:
            self.__remove_candidates[sharing_secret] = \
                self.__sharing_spaces[sharing_secret]
        self.__log.info('cleanup service - Sweep finished')
        self.timer = Timer(self.SWEEP_PERIOD, self.__sweep)
        self.timer.start()


    def get_sharing_space(self, sharing_secret):
        if sharing_secret in self.__sharing_spaces:
            try:
                sharing_space = self.__sharing_spaces[sharing_secret]
                if sharing_secret in self.__remove_candidates:
                    del(self.__remove_candidates[sharing_secret])
                return sharing_space
            except KeyError:
                #The only reason that this exception might occur is that
                #between the first if and then the retrieval of the object
                #the cleanup service removes the object. In this case, we
                #need to create a new sharing space.
                #I don't think this is a very likely scenario because
                #the cleanup service looks for is being used flag of the
                #sharing space
                sharing_space = SharingSpaceController()
                self.__sharing_spaces[sharing_secret] = sharing_space
                return sharing_space

        else:
            sharing_space = SharingSpaceController()
            self.__sharing_spaces[sharing_secret] = sharing_space
            return sharing_space

    @gen.engine
    def validate_secret(self, sharing_secret, callback):

        sharing_record =\
        yield gen.Task(SharingController.get_sharing_record_by_secret, sharing_secret)

        if sharing_record is None:
            callback(False)
        else:
            callback(True)

