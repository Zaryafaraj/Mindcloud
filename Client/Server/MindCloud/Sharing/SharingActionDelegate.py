from abc import ABCMeta, abstractmethod

__author__ = 'afathali'

class SharingActionDelegate:
    __metaclass__ = ABCMeta

    @abstractmethod
    def actionFinishedExecuting(self, action, response):
        """
        This delegate method should be called when an action finishes
        executing

        -Args:
            -``action``: A sharing action object that finished executing
            -``response``: an http response for the result executing the
            action
        """
        pass
