import urllib
import uuid
from tornado.httputil import HTTPHeaders
from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from Tests.ApiTets.HTTPHelper import HTTPHelper
from Tests.TestingProperties import TestingProperties
from TornadoMain import Application

__author__ = 'afathali'

class ThumbnailsTests(AsyncHTTPTestCase):

    account_id = TestingProperties.account_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def get_app(self):
        application = Application()
        return application

    def test_set_thumbnail(self):
        collection_name = 'collName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        thumbnail = open('../../test_resources/thumbnail.jpg')
        url += '/' + collection_name + '/Thumbnail'
        headers, post_data = HTTPHelper.create_multipart_request_with_single_file('file', thumbnail)
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
        thumbnail = open('../../test_resources/thumbnail.jpg')
        url += '/' + collection_name + '/Thumbnail'
        headers, post_data = HTTPHelper.create_multipart_request_with_single_file('file', thumbnail)
        response = self.fetch(path=url, headers=headers, method='POST',
            body=post_data)
        self.assertEqual(200, response.code)
        response = self.fetch(path=url, method='GET')
        self.assertEqual(200, response.code)
        #cleanu
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')



