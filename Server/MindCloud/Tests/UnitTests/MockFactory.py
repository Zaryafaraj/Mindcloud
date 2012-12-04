import cStringIO
from twisted.test.test_sslverify import counter

__author__ = 'afathali'

class MockFactory():

    @staticmethod
    def get_mock_request(user_id, callback):
        """
        Creates a mock Tornado request with user_id and the
        callback to be called when request.finish() is called

        - Args:
            ``callback``: A function with two arguments that will be
            called when the request.finish() is called. The status_code
            of the request and its body is passed to the callback
        """

        class MockRequest():

            __user_id = None
            __callback = None
            __status_code= None
            __body = None

            def __init__(self, user_id, callback):
                self.__user_id = user_id
                self.__callback = callback

            def set_status(self, status):
                self.__status_code = status

            def write(self, body):
                self.__body = body

            def finish(self):
               callback(self.__status_code, self.__body)

        return MockRequest(user_id, callback)

    @staticmethod
    def get_list_of_different_strings(count, template_str):
        """
        Creates and returns a list of strings from the template str

        Args:
            -``count``: The number of strings to return in the list
            -``template_str``: A string to make the content of the list out of

        Returns:
            - A list containing count number of string structures and
        """

        return [template_str + str(counter) for counter in range(count)]


