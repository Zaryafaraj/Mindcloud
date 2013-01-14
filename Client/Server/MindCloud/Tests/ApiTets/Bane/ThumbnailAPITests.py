import json
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
    subscriber_id = TestingProperties.subscriber_id

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

    def test_set_shared_thumbnail(self):

        #initialize
        collection_name = 'fcolName-shared-update_thumbnail'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url += "/" + collection_name + '/Share'
        response = self.fetch(path=url, method='POST', body="")
        json_obj = json.loads(response.body)
        sharing_secret = json_obj['sharing_secret']
        self.assertEqual(200, response.code)

        #subscribe
        subscription_url = '/'.join(['', self.subscriber_id,
                                     'Collections','ShareSpaces', 'Subscribe'])
        headers, postData =\
        HTTPHelper.create_multipart_request_with_parameters\
            ({'sharing_secret': sharing_secret})
        response = self.fetch(path=subscription_url, method='POST',
            headers=headers, body=postData)
        self.assertEqual(200, response.code)
        json_obj = json.loads(response.body)
        subscriber_collection_name = json_obj['collection_name']


        thumbnail = open('../../test_resources/thumbnail.jpg')
        url = '/'+self.account_id + '/Collections/' + collection_name + '/Thumbnail'
        headers, post_data = HTTPHelper.create_multipart_request_with_single_file('file', thumbnail)
        response = self.fetch(path=url, headers=headers, method='POST',
            body=post_data)
        self.assertEqual(200, response.code)

        try:
            self.wait(timeout=10)
        except Exception:
            pass

        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')
        url = '/'.join(['',self.subscriber_id, 'Collections', subscriber_collection_name])
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



