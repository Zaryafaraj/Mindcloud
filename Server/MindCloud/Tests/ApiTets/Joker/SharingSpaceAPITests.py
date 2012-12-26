import json
import random
import urllib
from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from Sharing.SharingEvent import SharingEvent
from Sharing.SharingSpaceStorage import SharingSpaceStorage
from Tests.ApiTets.HTTPHelper import HTTPHelper
from Tests.TestingProperties import TestingProperties
from TornadoMain import Application

__author__ = 'afathali'

class SharingSpaceTests(AsyncHTTPTestCase):

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

    def __make_update_not_action(self, user_id, collection_name, note_name):

        details = {'user_id' : user_id,
                   'collection_name' : collection_name,
                   'note_name' : note_name}
        dict = {SharingEvent.UPDATE_NOTE : details}
        json_str = json.dumps(dict)
        return json_str

    def __cleanup(self, owner_id, collection_name, subscriber_list):

        url='/'.join([owner_id,'Collections', collection_name,'Share'])
        self.fetch(path=url, method='DELETE')
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')
        for subscribe_id in subscriber_list:
            subscriber_colllection = subscriber_list[subscribe_id]
            url = '/'.join(['',subscribe_id, 'Collections', subscriber_colllection])
            self.fetch(path=url, method='DELETE')

    def __wait(self, duration):
        try:
            self.wait(timeout=duration)
        except Exception:
            pass
    def test_add_action(self):
        collection_name = 'share_api_col_name' + str(random.randint(0,100))
        owner_id = self.account_id
        subscribers = [self.subscriber_id]

        sharing_secret, subscriber_list =\
            self.__create_shared_collection(owner_id, subscribers,
                collection_name)

        note_name = 'note' + str(random.randint(0,100))
        json_str = self.__make_update_not_action(self.subscriber_id,
            collection_name, note_name)

        note_file = open('../../test_resources/XooML.xml')
        header, post_body = HTTPHelper.create_multipart_request_with_file_and_params({'action' : json_str},
            'file', note_file)

        sharing_space_url = '/'.join(['', 'SharingSpace', sharing_secret])
        response = self.fetch(path=sharing_space_url, method = 'POST',
            headers=header, body=post_body)

        self.__wait(10)
        self.assertEqual(200, response.code)

        self.__cleanup(owner_id, collection_name, subscriber_list)
        SharingSpaceStorage.get_instance().stop_cleanup_service()

    def test_add_action_invalid_sharing_secret(self):
        pass
    def test_add_action_bad_json(self):
        pass
    def test_add_action_missing_file(self):
        pass
    def test_add_listner(self):
        pass
    def test_add_listener_invalid_sharing_secret(self):
        pass
    def test_add_listener_missing_parameter(self):
        pass
    def test_delete_listener(self):
        pass
    def test_delete_listener_invalid_sharing_secret(self):
        pass
    def test_delete_listener_already_deleted_listener(self):
        pass
    def test_delete_listener_missing_parameter(self):
        pass
    def test_get_temp_img_thumbnail(self):
        pass
    def test_get_temp_img_note_img(self):
        pass
    def test_get_temp_img_invalid_secret(self):
        pass
    def test_get_temp_img_missing_secret(self):
        pass
    def test_get_temp_img_missing_parameters(self):
        pass
