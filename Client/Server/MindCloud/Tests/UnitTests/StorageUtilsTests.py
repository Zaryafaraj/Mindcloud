import uuid
from tornado import gen
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Storage.StorageUtils import StorageUtils
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer
from Tests.TestingProperties import TestingProperties

__author__ = 'afathali'

class StorageServerTest(AsyncTestCase):

    __account_id = TestingProperties.account_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_find_best_collection_name_with_unique_collection_name(self):

        collection_name = str(uuid.uuid1())
        StorageUtils.find_best_collection_name_for_user(
            collection_name,
            self.__account_id,
            callback = self.stop)
        new_name = self.wait()
        self.assertEqual(collection_name, new_name)

    def test_find_best_collection_name_with_one_existing_collection(self):
        collection_name = 'name'
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageUtils.find_best_collection_name_for_user(
            collection_name,
            self.__account_id,
            callback = self.stop)
        new_name = self.wait()
        expected_new_name = collection_name + StorageUtils.SHARING_POSTFIX
        self.assertEqual(expected_new_name, new_name)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()

    def test_find_best_collection_name_with_two_existing_collections(self):
        collection_name = 'name'
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        second_collection_name = collection_name + StorageUtils.SHARING_POSTFIX
        StorageServer.add_collection(self.__account_id, second_collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageUtils.find_best_collection_name_for_user(
            collection_name,
            self.__account_id,
            callback = self.stop)
        new_name = self.wait()
        expected_new_name = collection_name + \
                            StorageUtils.SHARING_POSTFIX + '1'

        self.assertEqual(expected_new_name, new_name)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, second_collection_name,
            callback=self.stop)
        self.wait()

    def test_find_best_collection_name_with_multiple_existing_collections(self):
        collection_name = 'name'
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        second_collection_name = collection_name + StorageUtils.SHARING_POSTFIX
        StorageServer.add_collection(self.__account_id, second_collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        third_collection_name = second_collection_name + "1"
        StorageServer.add_collection(self.__account_id, third_collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageUtils.find_best_collection_name_for_user(
            collection_name,
            self.__account_id,
            callback = self.stop)
        new_name = self.wait()
        expected_new_name = collection_name +\
                            StorageUtils.SHARING_POSTFIX + '2'

        self.assertEqual(expected_new_name, new_name)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, second_collection_name,
            callback=self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, third_collection_name,
            callback=self.stop)
        self.wait()

