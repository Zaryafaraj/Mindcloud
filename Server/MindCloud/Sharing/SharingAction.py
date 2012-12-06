from abc import ABCMeta, abstractmethod
from tornado import gen


class SharingAction:
    __metaclass__ = ABCMeta

    @abstractmethod
    @gen.engine
    def execute(self, delegate=None):
        """
        Executes the action with its current configuration.
        When the action is finished the actionFinishedExecuting of the
        delegate object is called.

        -Args:
            -``delegate``: A SharingActionDelegate object that responds when
            the action is finished executing
        """
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

