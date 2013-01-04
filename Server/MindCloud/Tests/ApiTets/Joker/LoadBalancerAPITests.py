import json
import random
import urllib
from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from Properties.MindcloudProperties import Properties
from Storage.StorageResponse import StorageResponse
from Tests.ApiTets.HTTPHelper import HTTPHelper
from Tests.TestingProperties import TestingProperties
from TornadoMain import Application

__author__ = 'afathali'


class LoadBalancerTests(AsyncHTTPTestCase):

    account_id = TestingProperties.account_id
    subscriber_id = TestingProperties.subscriber_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def get_app(self):
        application = Application()
        return application

    def __create_shared_collection(self, owner_id, subscriber_list, collection_name):

        params = {'collectionName':collection_name}
        url = '/' + owner_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))

        url += "/" + collection_name + '/Share'
        response = self.fetch(path=url, method='POST', body="")
        json_obj = json.loads(response.body)
        sharing_secret = json_obj['sharing_secret']
        self.assertEqual(200, response.code)

        subscriber_collection_names = {}
        for subscriber_id in subscriber_list:
            subscription_url = '/'.join(['', subscriber_id,
                                         'Collections','ShareSpaces', 'Subscribe'])
            headers, postData =\
            HTTPHelper.create_multipart_request_with_parameters\
                ({'sharing_secret': sharing_secret})
            response = self.fetch(path=subscription_url, method='POST',
                headers=headers, body=postData)
            self.assertEqual(200, response.code)
            json_obj = json.loads(response.body)
            subscriber_collection_name = json_obj['collection_name']
            subscriber_collection_names[subscriber_id] = subscriber_collection_name

        return sharing_secret, subscriber_collection_names

    def __cleanup(self, owner_id, collection_name, subscriber_list):

        url='/'.join(['', owner_id,'Collections', collection_name,'Share'])
        self.fetch(path=url, method='DELETE')
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')
        for subscribe_id in subscriber_list:
            subscriber_colllection = subscriber_list[subscribe_id]
            url = '/'.join(['',subscribe_id, 'Collections', subscriber_colllection])
            self.fetch(path=url, method='DELETE')

    def test_get_sharing_server_fresh(self):

        collection_name = 'share_api_col_name' + str(random.randint(0,100))
        owner_id = self.account_id
        subscribers = [self.subscriber_id]

        sharing_secret, subscriber_list =\
        self.__create_shared_collection(owner_id, subscribers,
            collection_name)

        url = '/'.join(['', 'SharingFactory', sharing_secret])
        response = self.fetch(path=url, method='GET')
        self.assertEqual(StorageResponse.OK, response.code)
        json_obj = json.loads(response.body)
        server_name = json_obj['server']
        self.assertTrue(server_name in Properties.sharing_space_servers)

        self.__cleanup(owner_id,collection_name, subscriber_list)

    def test_get_sharing_server_existing(self):

        collection_name = 'share_api_col_name' + str(random.randint(0,100))
        owner_id = self.account_id
        subscribers = [self.subscriber_id]

        sharing_secret, subscriber_list =\
        self.__create_shared_collection(owner_id, subscribers,
            collection_name)

        url = '/'.join(['', 'SharingFactory', sharing_secret])
        response = self.fetch(path=url, method='GET')
        self.assertEqual(StorageResponse.OK, response.code)
        json_obj = json.loads(response.body)
        server_name = json_obj['server']
        self.assertTrue(server_name in Properties.sharing_space_servers)

        response = self.fetch(path=url, method='GET')
        self.assertEqual(StorageResponse.OK, response.code)
        json_obj = json.loads(response.body)
        server_name = json_obj['server']
        self.assertTrue(server_name in Properties.sharing_space_servers)

        self.__cleanup(owner_id,collection_name, subscriber_list)

    def test_get_sharing_space_invalid_sharing_secret(self):


        url = '/'.join(['', 'SharingFactory', 'YYYYXXXX'])
        response = self.fetch(path=url, method='GET')
        self.assertEqual(StorageResponse.NOT_FOUND, response.code)

    def test_delete_server(self):

        collection_name = 'share_api_col_name' + str(random.randint(0,100))
        owner_id = self.account_id
        subscribers = [self.subscriber_id]

        sharing_secret, subscriber_list =\
        self.__create_shared_collection(owner_id, subscribers,
            collection_name)

        url = '/'.join(['', 'SharingFactory', sharing_secret])
        response = self.fetch(path=url, method='GET')
        self.assertEqual(StorageResponse.OK, response.code)
        json_obj = json.loads(response.body)
        server_name = json_obj['server']
        self.assertTrue(server_name in Properties.sharing_space_servers)

        response = self.fetch(path=url, method='DELETE')
        self.assertEqual(StorageResponse.OK, response.code)

        self.__cleanup(owner_id,collection_name, subscriber_list)

    def test_delete_server_invalid_sharing_secret(self):

        url = '/'.join(['', 'SharingFactory', 'YYYYXXXX'])
        response = self.fetch(path=url, method='DELETE')
        #expected
        self.assertEqual(StorageResponse.OK, response.code)

    def test_delete_server_non_existing(self):

        collection_name = 'share_api_col_name' + str(random.randint(0,100))
        owner_id = self.account_id
        subscribers = [self.subscriber_id]

        sharing_secret, subscriber_list =\
        self.__create_shared_collection(owner_id, subscribers,
            collection_name)

        url = '/'.join(['', 'SharingFactory', sharing_secret])
        response = self.fetch(path=url, method='DELETE')
        #expected
        self.assertEqual(StorageResponse.OK, response.code)

        self.__cleanup(owner_id, collection_name, subscriber_list)

    def test_delete_already_deleted_server(self):

        collection_name = 'share_api_col_name' + str(random.randint(0,100))
        owner_id = self.account_id
        subscribers = [self.subscriber_id]

        sharing_secret, subscriber_list =\
        self.__create_shared_collection(owner_id, subscribers,
            collection_name)

        url = '/'.join(['', 'SharingFactory', sharing_secret])
        response = self.fetch(path=url, method='GET')
        self.assertEqual(StorageResponse.OK, response.code)
        json_obj = json.loads(response.body)
        server_name = json_obj['server']
        self.assertTrue(server_name in Properties.sharing_space_servers)

        response = self.fetch(path=url, method='DELETE')
        self.assertEqual(StorageResponse.OK, response.code)

        response = self.fetch(path=url, method='DELETE')
        self.assertEqual(StorageResponse.OK, response.code)

        self.__cleanup(owner_id,collection_name, subscriber_list)

    def test_delete_then_get_server(self):

        collection_name = 'share_api_col_name' + str(random.randint(0,100))
        owner_id = self.account_id
        subscribers = [self.subscriber_id]

        sharing_secret, subscriber_list =\
        self.__create_shared_collection(owner_id, subscribers,
            collection_name)

        url = '/'.join(['', 'SharingFactory', sharing_secret])
        response = self.fetch(path=url, method='GET')
        self.assertEqual(StorageResponse.OK, response.code)
        json_obj = json.loads(response.body)
        server_name1 = json_obj['server']
        self.assertTrue(server_name1 in Properties.sharing_space_servers)

        response = self.fetch(path=url, method='DELETE')
        self.assertEqual(StorageResponse.OK, response.code)

        response = self.fetch(path=url, method='GET')
        self.assertEqual(StorageResponse.OK, response.code)
        json_obj = json.loads(response.body)
        server_name2 = json_obj['server']
        self.assertTrue(server_name2 in Properties.sharing_space_servers)
        self.assertEqual(server_name1, server_name2)

        self.__cleanup(owner_id,collection_name, subscriber_list)
