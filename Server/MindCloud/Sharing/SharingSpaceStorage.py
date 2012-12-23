from threading import Timer
from Properties import MindcloudProperties
from Sharing.SharingSpaceController import SharingSpaceController

__author__ = 'afathali'

class SharingSpaceStorage():


    __instance = None


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
        self.timer = Timer(self.SWEEP_PERIOD, self.__sweep)

    @classmethod
    def get_instance(cls):
        if not cls.__instance:
            cls.__instance = SharingSpaceStorage()

        return  cls.__instance

    def __sweep(self):
        """
        the function called by the cleanup service
        """
        for sharing_secret in self.__remove_candidates:
            #cleanup all the listeners
            candidate = self.__remove_candidates[sharing_secret]
            #In case a lot of actions are waiting to be executed
            #and are clogged in the space, don't clean it up give it
            #a chance for another sweeping period
            if not candidate.is_being_processed():
                candidate.cleanup()
                #remove if from stored sharing spaces
                del(self.__sharing_spaces[sharing_secret])


        #now nominate every one
        self.__remove_candidates.clear()
        for sharing_secret in self.__sharing_spaces:
            self.__remove_candidates[sharing_secret] = \
                self.__sharing_spaces[sharing_secret]


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

