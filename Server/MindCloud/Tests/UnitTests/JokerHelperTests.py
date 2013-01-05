import uuid
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Helpers.JokerHelper import JokerHelper
from Properties.MindcloudProperties import Properties
from Sharing.SharingController import SharingController
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer
from Tests.TestingProperties import TestingProperties

__author__ = 'afathali'

class JokerHelperTests(AsyncTestCase):

    __account_id = TestingProperties.account_id
    __subscriber_id = TestingProperties.subscriber_id
    __second_subscriber_id = TestingProperties.second_subscriber_id


    def get_new_ioloop(self):
        return IOLoop.instance()

    def __create_sharing_record(self, subscriber_list, collection_name):

        #create collection
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name= collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #create sharing record
        SharingController.create_sharing_record(self.__account_id,
            collection_name, callback = self.stop)
        sharing_secret = self.wait(timeout=10000)
        self.assertTrue(sharing_secret is not None)

        subscribers = {}
        for subscriber_id in subscriber_list:
            #subscribe
            SharingController.subscribe_to_sharing_space(subscriber_id,
                sharing_secret, callback = self.stop)
            subscribers_collection_name  = self.wait()
            self.assertTrue(subscribers_collection_name is not None)
            subscribers[subscriber_id] = subscribers_collection_name

        return sharing_secret, subscribers

    def test_get_sharing_space_server_fresh(self):

        collection_name = str(uuid.uuid4())
        subscriber_list = [self.__subscriber_id, self.__second_subscriber_id]
        sharing_secret, subscribers_collections =\
            self.__create_sharing_record(subscriber_list, collection_name)

        joker = JokerHelper.get_instance()
        joker.get_sharing_space_server(sharing_secret, callback=self.stop)
        server_adrs = self.wait(timeout=10000)
        self.assertIn(server_adrs, Properties.sharing_space_servers)


        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        for subscriber_id in subscribers_collections:
            subscriber_collection = subscribers_collections[subscriber_id]
            StorageServer.remove_collection(subscriber_id, subscriber_collection,
                callback=self.stop)
            self.wait()

    def test_get_sharing_space_server_existing(self):

        collection_name = str(uuid.uuid4())
        subscriber_list = [self.__subscriber_id, self.__second_subscriber_id]
        sharing_secret, subscribers_collections =\
        self.__create_sharing_record(subscriber_list, collection_name)

        joker = JokerHelper.get_instance()
        joker.get_sharing_space_server(sharing_secret, callback=self.stop)
        server_adrs1 = self.wait(timeout=10000)
        self.assertIn(server_adrs1, Properties.sharing_space_servers)
        print server_adrs1


        joker.get_sharing_space_server(sharing_secret, callback=self.stop)
        server_adrs2 = self.wait(timeout=10000)
        self.assertIn(server_adrs2, Properties.sharing_space_servers)
        self.assertEqual(server_adrs1, server_adrs2)
        print server_adrs2

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        for subscriber_id in subscribers_collections:
            subscriber_collection = subscribers_collections[subscriber_id]
            StorageServer.remove_collection(subscriber_id, subscriber_collection,
                callback=self.stop)
            self.wait()

    def test_get_sharing_space_invalid_secret(self):

        sharing_secret = '00000000'
        joker = JokerHelper.get_instance()
        joker.get_sharing_space_server(sharing_secret, callback=self.stop)
        server_adrs1 = self.wait(timeout=10000)
        self.assertTrue(server_adrs1 is None)

    def __wait(self, timeout):
        try:
            self.wait(timeout=timeout)
        except  Exception:
            pass
    def test_update_manifest(self):

        collection_name = str(uuid.uuid4())
        subscriber_list = [self.__subscriber_id]
        sharing_secret, subscribers_collections =\
        self.__create_sharing_record(subscriber_list, collection_name)


        joker = JokerHelper.get_instance()
        joker.get_sharing_space_server(sharing_secret, callback=self.stop)
        server_adrs = self.wait(timeout=10000)
        self.assertIn(server_adrs, Properties.sharing_space_servers)

        manifest_file = open('../test_resources/sharing_template1.xml')
        expected_manifest_body = manifest_file.read()
        joker.update_manifest(server_adrs, sharing_secret, self.__account_id,
            collection_name, manifest_file, callback=self.stop)
        response = self.wait(timeout=1000)
        self.assertEqual(StorageResponse.OK, response)

        #wait for a while
        self.__wait(10)

        #try to retrieve the file
        StorageServer.get_collection_manifest(self.__account_id, collection_name,
            callback=self.stop)
        actual_manifest_file = self.wait()
        actual_manifest_body = actual_manifest_file.read()
        self.assertEqual(actual_manifest_body, expected_manifest_body)

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        for subscriber_id in subscribers_collections:
            subscriber_collection = subscribers_collections[subscriber_id]
            StorageServer.remove_collection(subscriber_id, subscriber_collection,
                callback=self.stop)
            self.wait()
