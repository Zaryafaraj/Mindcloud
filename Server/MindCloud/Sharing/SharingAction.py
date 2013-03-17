from abc import ABCMeta, abstractmethod
from tornado import gen


class SharingAction:
    __metaclass__ = ABCMeta

    @abstractmethod
    @gen.engine
    def execute(self, callback=None, delegate=None, retry_counter=0):
        """
        Executes the action with its current configuration.
        When the action is finished the actionFinishedExecuting of the
        delegate object is called, additionally if a callback fucntion is passed in
        that function is also called by the response code.

        This allows both for an Object Oriented message communication and a callback based
        one.

        Note that only one of the callback and delegate may be passed in. In case both are
        passed in the delegate will be used

        -Args:
            -``delegate``: A SharingActionDelegate object that responds when
            the action is finished executing
            -``callback``: A function that will be called by the response of the action
        """
        pass

    @abstractmethod
    def get_user_id(self):
        pass

    @abstractmethod
    def get_collection_name(self):
        pass

    @abstractmethod
    def get_associated_file(self):
        pass

    @abstractmethod
    def get_action_type(self):
        pass

    @abstractmethod
    def get_action_resource_name(self):
        """
        Returns the name of the resource affected by this action
        """
        pass

    @abstractmethod
    def clone_for_user_and_collection(self, user_id, collection_name):
        """
        Clones this action for another user with user_id and a collection
        with collection_name

        returns a new sharing action of the same type customized for the user
        with user_id and collection_name
        """

    @abstractmethod
    @gen.engine
    def was_successful(self, callback=None):
        """
        Checks the dropbox to see if the action was successful or not

        Returns true or false to the callback
        """

