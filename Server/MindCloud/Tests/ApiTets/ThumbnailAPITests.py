import urllib
import uuid
from tornado.httputil import HTTPHeaders
from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from TornadoMain import Application

__author__ = 'afathali'

class ThumbnailsTests(AsyncHTTPTestCase):

    account_id = '04B08CB7-17D5-493A-8ED1-E086FDC1327E'

    def get_new_ioloop(self):
        return IOLoop.instance()

    def get_app(self):
        application = Application()
        return application

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

    def __create_multipart_request(self, file):
        boundary = '----------------------------62ae4a76207c'
        content_type = 'multipart/form-data; boundary=' + boundary
        headers = HTTPHeaders({'content-type':content_type})
        postData = "--" + boundary +\
                   "\r\nContent-Disposition: form-data; name=\"file\"; filename=\"thumbnail.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
        postData += file.read()
        postData += "\r\n--" + boundary + "--"
        return headers, postData

    def test_set_thumbnail(self):
        collection_name = 'collName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        thumbnail = open('../test_resources/thumbnail.jpg')
        url += '/' + collection_name + '/Thumbnail'
        headers, post_data = self._create_multipart_request('ali',thumbnail)
        response = self.fetch(path=url, headers=headers, method='POST',
            body=post_data)
        self.assertEqual(200, response.code)
        #cleanu
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_get_thumbnail(self):
        collection_name = 'collName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        thumbnail = open('../test_resources/thumbnail.jpg')
        url += '/' + collection_name + '/Thumbnail'
        headers, post_data = self._create_multipart_request('ali',thumbnail)
        response = self.fetch(path=url, headers=headers, method='POST',
            body=post_data)
        self.assertEqual(200, response.code)
        response = self.fetch(path=url, method='GET')
        self.assertEqual(200, response.code)
        #cleanu
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')



