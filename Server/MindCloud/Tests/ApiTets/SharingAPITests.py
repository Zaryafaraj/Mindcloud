import json
import urllib
from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from TornadoMain import Application

__author__ = 'afathali'

class SharingTests(AsyncHTTPTestCase):

    account_id = '04B08CB7-17D5-493A-8ED1-E086FDC1327E'

    def get_new_ioloop(self):
        return IOLoop.instance()

    def get_app(self):
        application = Application()
        return application


    def test_create_sharing_space(self):

        #initialize
        collection_name = 'colName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)

        url += "/" + collection_name + '/Share'
        response = self.fetch(path=url, method='POST', body="")
        self.assertEqual(200, response.code)

        #cleanup
        self.fetch(path=url, method='DELETE')
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_create_sharing_space_without_collection(self):

        #initialize
        collection_name = 'colName'
        url = '/'+self.account_id + '/Collections'
        url += "/" + collection_name + '/Share'
        response = self.fetch(path=url, method='POST', body="")
        self.assertEqual(404, response.code)

    def test_get_sharing_space(self):

        #initialize
        collection_name = 'colName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url += "/" + collection_name + '/Share'
        response = self.fetch(path=url, method='POST', body="")
        self.assertEqual(200, response.code)

        response = self.fetch(path=url, method='GET')
        self.assertEqual(200, response.code)
        json_obj = json.loads(response.body)
        actual_collection_name = json_obj['collection_name']
        self.assertEqual(collection_name, actual_collection_name)

        #cleanup
        self.fetch(path=url, method='DELETE')
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_get_non_existing_sharing_space(self):

        collection_name = 'dummy'
        url = '/'+self.account_id + '/Collections'
        url += "/" + collection_name + '/Share'

        response = self.fetch(path=url, method='GET')
        self.assertEqual(404, response.code)


    def test_get_non_existing_sharing_space_existing_collection(self):        #initialize

        collection_name = 'colName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url += "/" + collection_name + '/Share'
        response = self.fetch(path=url, method='GET')
        self.assertEqual(404, response.code)

        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_remove_sharing_record(self):
        #initialize
        collection_name = 'colName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url += "/" + collection_name + '/Share'
        response = self.fetch(path=url, method='POST', body="")
        self.assertEqual(200, response.code)

        response = self.fetch(path=url, method='DELETE')
        self.assertEqual(200, response.code)

        response = self.fetch(path=url, method='GET')
        self.assertEqual(404, response.code)

        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_remove_non_existing_sharing_record(self):
        collection_name = 'colName'
        url = '/'+self.account_id + '/Collections'
        url += "/" + collection_name + '/Share'

        response = self.fetch(path=url, method='DELETE')
        #I am accepting this faulty behavior in favor of
        #better performance
        self.assertEqual(200, response.code)

    def test_remove_non_existing_sharing_record_with_existing_collection(self):

        collection_name = 'colName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url += "/" + collection_name + '/Share'
        response = self.fetch(path=url, method='DELETE')
        #I am accepting this faulty behavior in favor of
        #better performance
        self.assertEqual(200, response.code)

