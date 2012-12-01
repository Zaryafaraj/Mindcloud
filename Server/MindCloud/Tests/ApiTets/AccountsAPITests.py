import json
import urllib
import uuid
from tornado.httputil import HTTPHeaders
from tornado.testing import AsyncHTTPTestCase
from tornado.ioloop import IOLoop
from Tests.ApiTets.HTTPHelper import HTTPHelper
from Tests.TestingProperties import TestingProperties
from TornadoMain import Application

__author__ = 'afathali'

class AccountsTests(AsyncHTTPTestCase):

    account_id = TestingProperties.account_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def get_app(self):
        application = Application()
        return application

    def test_get_collections(self):

        collection_name = 'colName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)

        response = self.fetch('/'+self.account_id + '/Collections')
        response_json = json.loads(response.body)
        self.assertEqual(200,response.code)
        self.assertTrue(len(response_json) > 0)

        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_add_collection_no_file(self):
        collection_name = 'colName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)

        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_add_collections_with_file(self):
        collection_name = 'a'
        file = open('../test_resources/XooML.xml')
        params = {'collectionName' : collection_name}
        headers, postData = HTTPHelper.create_multipart_request_with_file_and_params\
            (params, 'file', file)
        url = '/'+self.account_id + '/Collections'
        file.close()
        response = self.fetch(path=url, headers=headers, method='POST', body=postData)
        self.assertEqual(200, response.code)
        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

