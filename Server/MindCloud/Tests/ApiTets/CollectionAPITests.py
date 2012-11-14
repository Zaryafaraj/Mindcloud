import urllib
import uuid
from tornado.httputil import HTTPHeaders
from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from Tests.ApiTets.HTTPHelper import HTTPHelper
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


    def test_rename_collection(self):
        collection_name = 'collName1'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        collection_name = 'newColName'
        params = {'collectionName':collection_name}
        headers, postData = HTTPHelper.create_multipart_request_with_parameters(params)
        response = self.fetch(path=url, headers=headers, method='PUT', body=postData)
        self.assertEquals(200, response.code)
        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_save_manifest(self):
        collection_name = 'collName1'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        collection_file = open('../test_resources/collection.xml')
        headers, postData = HTTPHelper.create_multipart_request_with_single_file('file', collection_file)
        response = self.fetch(path=url, headers=headers, method='POST',
            body=postData)
        self.assertEquals(200, response.code)

        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_save_manifest_no_file(self):
        collection_name = 'collName1'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        response = self.fetch(path=url, method='POST', body='')
        self.assertEquals(400, response.code)

        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_get_manifest(self):
        collection_name = 'collName1'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        collection_file = open('../test_resources/collection.xml')
        headers, postData = HTTPHelper.create_multipart_request_with_single_file('file', collection_file)
        response = self.fetch(path=url, headers=headers, method='POST',
            body=postData)
        self.assertEquals(200, response.code)

        response = self.fetch(path=url, method= 'GET')
        self.assertEquals(200, response.code)

        print url
        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_get_manifest_non_existing(self):
        url = '/'.join(['', self.account_id, 'Collections', 'dummy'])
        response = self.fetch(path=url, method= 'GET')
        self.assertEquals(404, response.code)

