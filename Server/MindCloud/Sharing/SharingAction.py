from abc import ABCMeta, abstractmethod
from tornado import gen


class SharingAction:
    __metaclass__ = ABCMeta

    @abstractmethod
    @gen.engine
    def execute(self, callback):
        pass

