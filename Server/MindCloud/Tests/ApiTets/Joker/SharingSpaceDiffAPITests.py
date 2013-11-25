import json
import random
import urllib
from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from Sharing.SharingSpaceStorage import SharingSpaceStorage
from Tests.ApiTets.HTTPHelper import HTTPHelper
from Tests.TestingProperties import TestingProperties
from TornadoMain import Application

__author__ = 'afathali'


#noinspection PyBroadException
class SharingSpaceDiffAPITests(AsyncHTTPTestCase):

    account_id = TestingProperties.account_id
    subscriber_id = TestingProperties.subscriber_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def get_app(self):
        application = Application()
        return application

    def __create_shared_collection(self, owner_id, subscriber_list, collection_name):

        params = {'collectionName': collection_name}
        url = '/' + owner_id + '/Collections'
        self.fetch(path=url, method='POST', body=urllib.urlencode(params))

        url += "/" + collection_name + '/Share'
        response = self.fetch(path=url, method='POST', body="")
        json_obj = json.loads(response.body)
        sharing_secret = json_obj['sharing_secret']
        self.assertEqual(200, response.code)

        subscriber_collection_names = {}
        for subscriber_id in subscriber_list:
            subscription_url = '/'.join(['', subscriber_id,
                                         'Collections', 'ShareSpaces', 'Subscribe'])
            headers, post_data = \
                HTTPHelper.create_multipart_request_with_parameters({'sharing_secret': sharing_secret})
            response = self.fetch(path=subscription_url, method='POST',
                                  headers=headers, body=post_data)
            self.assertEqual(200, response.code)
            json_obj = json.loads(response.body)
            subscriber_collection_name = json_obj['collection_name']
            subscriber_collection_names[subscriber_id] = subscriber_collection_name

        return sharing_secret, subscriber_collection_names

    def __wait(self, duration):
        try:
            self.wait(timeout=duration)
        except Exception:
            pass

    def __cleanup(self, owner_id, collection_name, subscriber_list):

        url = '/'.join(['', owner_id, 'Collections', collection_name, 'Share'])
        self.fetch(path=url, method='DELETE')
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')
        for subscribe_id in subscriber_list:
            subscriber_collection = subscriber_list[subscribe_id]
            url = '/'.join(['', subscribe_id, 'Collections', subscriber_collection])
            self.fetch(path=url, method='DELETE')

    def test_send_diff_file(self):

        collection_name = 'share_api_col_name' + str(random.randint(0, 100))
        owner_id = self.account_id
        subscribers = [self.subscriber_id]

        sharing_secret, subscriber_list = \
            self.__create_shared_collection(owner_id, subscribers,
                                            collection_name)

        diff_file = open('../../test_resources/screen.drw')
        params = {'user_id': owner_id,
                  'collection_name': collection_name,
                  'resource_path': 'screen.draw'}
        header, post_body = HTTPHelper.create_multipart_request_with_file_and_params(params,
                                                                                     'file', diff_file)
        diff_file_url = '/'.join(['', 'SharingSpace', sharing_secret, 'B64Diff'])

        response = self.fetch(path=diff_file_url, method='POST',
                              headers=header, body=post_body)

        self.__wait(5)
        self.assertEqual(200, response.code)

        self.__cleanup(owner_id, collection_name, subscriber_list)
        SharingSpaceStorage.get_instance().stop_cleanup_service()

    def test_send_diff_file_missing_arguments(self):

        collection_name = 'share_api_col_name' + str(random.randint(0, 100))
        owner_id = self.account_id
        subscribers = [self.subscriber_id]

        sharing_secret, subscriber_list = \
            self.__create_shared_collection(owner_id, subscribers,
                                            collection_name)

        diff_file = open('../../test_resources/screen.drw')
        params = {}
        header, post_body = HTTPHelper.create_multipart_request_with_file_and_params(params,
                                                                                     'file', diff_file)
        diff_file_url = '/'.join(['', 'SharingSpace', sharing_secret, 'B64Diff'])

        response = self.fetch(path=diff_file_url, method='POST',
                              headers=header, body=post_body)

        self.__wait(5)
        self.assertEqual(400, response.code)

        self.__cleanup(owner_id, collection_name, subscriber_list)
        SharingSpaceStorage.get_instance().stop_cleanup_service()

    def test_send_missing_file_invalid_sharing_secret(self):

        diff_file = open('../../test_resources/screen.drw')
        params = {}
        header, post_body = HTTPHelper.create_multipart_request_with_file_and_params(params,
                                                                                     'file', diff_file)
        diff_file_url = '/'.join(['', 'SharingSpace', 'SSSSSSSS', 'B64Diff'])

        response = self.fetch(path=diff_file_url, method='POST',
                              headers=header, body=post_body)

        self.__wait(5)
        self.assertEqual(400, response.code)
