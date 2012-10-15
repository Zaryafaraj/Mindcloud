import urllib
import uuid
from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from TornadoMain import Application

__author__ = 'afathali'

class CollectnTests(AsyncHTTPTestCase):

    account_id = '04B08CB7-17D5-493A-8ED1-E086FDC1327E'

    def get_new_ioloop(self):
        return IOLoop.instance()

    def get_app(self):
        application = Application()
        return application

    def test_delete_collection(self):
        collection_name = 'collName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        response = self.fetch(path=url, method='DELETE')
        self.assertEquals(200, response.code)
