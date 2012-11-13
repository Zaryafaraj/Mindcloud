import urllib
import uuid
from tornado.httputil import HTTPHeaders
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

    def _prepare_put(self, collection_name):
        params = {'collectionName':collection_name}
        boundary = '----------------------------62ae4a76207c'
        content_type = 'multipart/form-data; boundary=' + boundary
        headers = HTTPHeaders({'content-type':content_type})
        postData = "--" + boundary +\
                   "\r\nContent-Disposition: form-data; name=\"collectionName\"\r\n\r\n"
        postData += collection_name
        postData += "\r\n--" + boundary + "--"
        return headers, postData

    def _create_multipart_request(self, file):
        boundary = '----------------------------62ae4a76207c'
        content_type = 'multipart/form-data; boundary=' + boundary
        headers = HTTPHeaders({'content-type':content_type})
        postData = "--" + boundary +\
                   "\r\nContent-Disposition: form-data; name=\"file\"; filename=\"Xooml.xml\"\r\nContent-Type: application/xml\r\n\r\n"
        postData += file.read()
        postData += "\r\n--" + boundary + "--"
        return headers, postData

    def test_rename_collection(self):
        collection_name = 'collName1'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        collection_name = 'newColName'
        headers, postData = self._prepare_put(collection_name)
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
        headers, postData = self._create_multipart_request(collection_file)
        response = self.fetch(path=url, headers=headers, method='POST',
            body=postData)
        self.assertEquals(200, response.code)

        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

