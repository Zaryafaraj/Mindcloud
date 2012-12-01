from Sharing.UpdateSharedManifestAction import UpdateSharedManifestAction
from Tests.TestingProperties import TestingProperties

__author__ = 'afathali'

from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

class SharingActionTestCase(AsyncTestCase):

    __account_id = TestingProperties.account_id
    __subscriber_id = TestingProperties.subscriber_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_update_sharing_manifest(self):

        #create collection
        first_collection_name = 'shareable_collection'
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=first_collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #update manifest
        file = open('../test_resources/XooML2.xml')
        update_manifest_action = UpdateSharedManifestAction(self.__account_id,first_collection_name, file)
        update_manifest_action.execute(callback=self.stop)
        self.assertEqual(StorageResponse.OK, response)

        #cleanup
        #StorageServer.remove_collection(self.__account_id, first_collection_name,
        #    callback=self.stop)


    def test_update_sharing_manifest_non_existing_manifest(self):
        pass
    def test_update_sharing_manifest_repeatedly(self):
        pass
    def test_update_sharing_manifest_shared_collection(self):
        pass
    def test_update_sharing_manifest_from_two_users(self):
        pass
    def test_update_sharing_note(self):
        pass
    def test_update_note_non_existing_note(self):
        pass
    def test_update_note_repeatedly(self):
        pass
    def test_update_note_shared_collection(self):
        pass
    def test_update_note_from_two_users(self):
        pass
    def test_update_note_img(self):
        pass
    def test_update_note_img_non_existing_img(self):
        pass
    def test_update_note_img_repetedly(self):
        pass
    def test_update_note_img_shared_collection(self):
        pass
    def test_update_note_from_two_users(self):
        pass
