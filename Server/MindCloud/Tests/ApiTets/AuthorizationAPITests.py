from tornado.testing import AsyncHTTPTestCase
from TornadoMain import Application
from tornado.ioloop import IOLoop

__author__ = 'afathali'

class AuthorizationTests(AsyncHTTPTestCase):

    #this is a pre authorized accountId
    account_id = '37912505-10e7-11e2-a09c-c82a1425c93b'

    def get_new_ioloop(self):
        return IOLoop.instance()

    def get_app(self):
        application = Application()
        return application

    def test_first_request(self):
        response = self.fetch('/Authorize/' + self.account_id)
        self.assertEqual(200, response.code)
        #clean up

    def test_authenticate(self):
        #TODO fix this test
        #Right now I don't have a good method to test this.
        #To verify behavior I am forced to use the client
        """
        response = self.fetch('/Authorize/' + self.account_id)
        #Because of a bug in tornado we have to always pass a body
        response = self.fetch('/Authorize/' + self.account_id, method="POST", body='hi')
        self.assertEqual(200, response.code)
        #clean up
        """

