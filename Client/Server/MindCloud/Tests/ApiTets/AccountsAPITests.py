import json
import urllib
import uuid
from tornado.httputil import HTTPHeaders
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
        response = self.fetch('/'+self.account_id + '/Collections')
        response_json = json.loads(response.body)
        self.assertEqual(200,response.code)
        self.assertTrue(len(response_json) > 0)

    def test_add_collection_no_file(self):
        collection_name = 'colName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)

    def _create_multipart_request(self, collection_name, file):
        boundary = '----------------------------62ae4a76207c'
        content_type = 'multipart/form-data; boundary=' + boundary
        headers = HTTPHeaders({'content-type':content_type})
        postData = "--" + boundary +\
                   "\r\nContent-Disposition: form-data; name=\"file\"; filename=\"Xooml.xml\"\r\nContent-Type: application/xml\r\n\r\n"
        postData += file.read()
        postData += "\r\n--" + boundary +\
                    "\r\nContent-Disposition: form-data; name=\"collectionName\"\r\n\r\n"
        postData += collection_name
        postData += "\r\n--" + boundary + "--"
        return headers, postData

    def test_add_collections_with_file(self):
        collection_name = 'a'
        file = open('../test_resources/XooML.xml')
        headers, postData = self._create_multipart_request(collection_name, file)
        url = '/'+self.account_id + '/Collections'
        file.close()
        response = self.fetch(path=url, headers=headers, method='POST', body=postData)
        self.assertEqual(200, response.code)
        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

