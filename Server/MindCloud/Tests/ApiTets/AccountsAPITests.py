import json
import urllib
import uuid
from tornado.testing import AsyncHTTPTestCase
from tornado.ioloop import IOLoop
from TornadoMain import Application

__author__ = 'afathali'

class AccountsTests(AsyncHTTPTestCase):

    account_id = '04B08CB7-17D5-493A-8ED1-E086FDC1327E'

    def get_new_ioloop(self):
        return IOLoop.instance()

    def get_app(self):
        application = Application()
        return application

    def test_get_collections(self):
        response = self.fetch('/'+self.account_id + '/Collections/')
        response_json = json.loads(response.body)
        self.assertEqual(200,response.code)
        self.assertTrue(len(response_json) > 0)

    def test_add_collection_no_file(self):
        collection_name = str(uuid.uuid1())
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections/'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
