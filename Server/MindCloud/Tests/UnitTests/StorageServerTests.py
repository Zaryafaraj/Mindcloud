import uuid
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

__author__ = 'afathali'

class StorageServerTests(AsyncTestCase):

    __account_id = '04B08CB7-17D5-493A-8ED1-E086FDC1327E'

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_list_collections_valid_account(self):
        StorageServer.list_collections(self.__account_id, callback=self.stop)
        collections = self.wait()
        print collections
        self.assertTrue(len(collections) > 0)

    def test_list_collection_invalid_account(self):
        StorageServer.list_collections('dummy_user', callback=self.stop)
        collections = self.wait()
        self.assertTrue(len(collections) == 0)

    def test_add_collection_with_no_file(self):
        collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

    def test_add_collection_with_file(self):
        collection_name = str(uuid.uuid1())
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

    def test_remove_collection_with_no_file(self):
        collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

