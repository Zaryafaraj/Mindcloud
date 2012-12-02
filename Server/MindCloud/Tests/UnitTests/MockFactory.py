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


