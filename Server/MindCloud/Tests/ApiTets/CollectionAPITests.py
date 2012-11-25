import json
import random
import urllib
import uuid
from tornado.httputil import HTTPHeaders
from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from Tests.ApiTets.HTTPHelper import HTTPHelper
from TornadoMain import Application

__author__ = 'afathali'

class CollectionTests(AsyncHTTPTestCase):

    account_id = '04B08CB7-17D5-493A-8ED1-E086FDC1327E'
    subscriber_id = 'E82FD595-AD5E-4D91-B73D-3A7C3A3FEDCE'


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

    def test_delete_shared_collection_by_subscriber(self):

        #initialize
        collection_name = 'colName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url += "/" + collection_name + '/Share'
        response = self.fetch(path=url, method='POST', body="")
        json_obj = json.loads(response.body)
        sharing_secret = json_obj['sharing_secret']
        self.assertEqual(200, response.code)

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

        #delete
        del_url = '/'.join(['',self.subscriber_id, 'Collections', subscriber_collection_name])
        response = self.fetch(path=del_url, method='DELETE')
        self.assertEquals(200, response.code)

        #verify
        response = self.fetch(path=url, method='GET')
        self.assertEqual(200, response.code)
        json_obj = json.loads(response.body)
        actual_collection_name = json_obj['collection_name']
        self.assertEqual(collection_name, actual_collection_name)
        subscribers_list = json_obj['subscribers']
        self.assertTrue([self.subscriber_id, subscriber_collection_name]
        not in subscribers_list)

        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')
        url = '/'.join(['',self.subscriber_id, 'Collections', subscriber_collection_name])
        self.fetch(path=url, method='DELETE')


    def test_delete_shared_collection_by_owner(self):

        #initialize
        collection_name = 'colName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url += "/" + collection_name + '/Share'
        response = self.fetch(path=url, method='POST', body="")
        json_obj = json.loads(response.body)
        sharing_secret = json_obj['sharing_secret']
        self.assertEqual(200, response.code)

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

        #delete
        del_url = '/'.join(['',self.account_id, 'Collections', collection_name])
        response = self.fetch(path=del_url, method='DELETE')
        self.assertEquals(200, response.code)

        #verify
        response = self.fetch(path=url, method='GET')
        self.assertEqual(404, response.code)

        #cleanup
        url = '/'.join(['',self.subscriber_id, 'Collections', subscriber_collection_name])
        self.fetch(path=url, method='DELETE')

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

    def test_rename_shared_collection_by_owner(self):

        #initialize
        collection_name = 'fcolName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url += "/" + collection_name + '/Share'
        response = self.fetch(path=url, method='POST', body="")
        json_obj = json.loads(response.body)
        sharing_secret = json_obj['sharing_secret']
        self.assertEqual(200, response.code)

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

        #rename
        rename_collection_name = 'new_name'
        rename_url = '/'.join(['',self.account_id, 'Collections', collection_name])
        params = {'collectionName':rename_collection_name}
        headers, postData = HTTPHelper.create_multipart_request_with_parameters(params)
        response = self.fetch(path=rename_url, headers=headers, method='PUT', body=postData)
        self.assertEquals(200, response.code)

        response = self.fetch(path=url, method='GET')
        self.assertEqual(404, response.code)
        url = '/'.join(['', self.account_id, 'Collections', rename_collection_name, 'Share'])
        response = self.fetch(path=url, method='GET')
        self.assertEqual(200, response.code)
        json_obj = json.loads(response.body)
        actual_collection_name = json_obj['collection_name']
        self.assertEqual(rename_collection_name, actual_collection_name)

        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', rename_collection_name])
        self.fetch(path=url, method='DELETE')
        url = '/'.join(['',self.subscriber_id, 'Collections', subscriber_collection_name])
        self.fetch(path=url, method='DELETE')

    def test_rename_shared_collection_by_subscriber(self):

        #initialize
        collection_name = 'fcolName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url += "/" + collection_name + '/Share'
        response = self.fetch(path=url, method='POST', body="")
        json_obj = json.loads(response.body)
        sharing_secret = json_obj['sharing_secret']
        self.assertEqual(200, response.code)

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

        #rename
        rename_collection_name = 'new_name'
        rename_url = '/'.join(['',self.subscriber_id, 'Collections', subscriber_collection_name])
        params = {'collectionName':rename_collection_name}
        headers, postData = HTTPHelper.create_multipart_request_with_parameters(params)
        response = self.fetch(path=rename_url, headers=headers, method='PUT', body=postData)
        self.assertEquals(200, response.code)

        response = self.fetch(path=url, method='GET')
        self.assertEqual(200, response.code)
        json_obj = json.loads(response.body)
        subscribers = json_obj['subscribers']
        self.assertTrue([self.subscriber_id, rename_collection_name] in
            subscribers)

        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')
        url = '/'.join(['',self.subscriber_id, 'Collections', rename_collection_name])
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

