from tornado.httputil import HTTPHeaders
from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from Tests.ApiTets.HTTPHelper import HTTPHelper
from Tests.TestingProperties import TestingProperties
from TornadoMain import Application

__author__ = 'afathali'

class CategoriesTests(AsyncHTTPTestCase):

    account_id = TestingProperties.account_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def get_app(self):
        application = Application()
        return application

    def test_add_categories(self):
        categories_file = open('../test_resources/categories.xml')
        url = '/' + self.account_id + '/Categories'
        headers, post_data = HTTPHelper.create_multipart_request_with_single_file('file', categories_file)
        response = self.fetch(path=url, headers=headers, method='POST',
            body=post_data)
        self.assertEqual(200, response.code)

    def test_get_categories(self):
        #whether the category exists or it doesn't in which case we create it
        #since we are testing only the path from the handler to the storageServer
        #this assumption doesn't ruin the test
        url = '/' + self.account_id + '/Categories'
        response = self.fetch(path=url, method='GET')
        self.assertTrue(response is not None)

