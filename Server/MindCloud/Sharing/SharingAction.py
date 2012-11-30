from abc import ABCMeta, abstractmethod
from tornado import gen


class SharingAction:
    __metaclass__ = ABCMeta

    @abstractmethod
    @gen.engine
    def execute(self, callback):
        pass

    @abstractmethod
    def get_user_id(self):
        pass

    @abstractmethod
    def get_associated_file(self):
        pass

    @abstractmethod
    def get_action_type(self):
        pass

