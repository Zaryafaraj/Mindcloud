from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
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

