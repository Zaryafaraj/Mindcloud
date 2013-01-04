import json
import uuid
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Properties.MindcloudProperties import Properties
from Sharing.SharingController import SharingController
from Sharing.SharingLoadBalancer import SharingLoadBalancer
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer
from Tests.TestingProperties import TestingProperties

__author__ = 'afathali'

class LoadBalancerTestCase(AsyncTestCase):

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

    def test_get_sharing_space_info_new(self):

        servers = {'a', 'b', 'c'}
        Properties.sharing_space_servers = servers
        collection_name = str(uuid.uuid4())
        subscriber_list = [self.__subscriber_id, self.__second_subscriber_id]
        sharing_secret, subscribers_collections = \
            self.__create_sharing_record(subscriber_list, collection_name)
        load_balancer = SharingLoadBalancer.get_instance()
        load_balancer.get_sharing_space_info(sharing_secret, callback=self.stop)
        server_info = self.wait()
        server_adrs = server_info['server']
        self.assertTrue(server_adrs in servers)

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

    def test_get_sharing_space_info_existing(self):

        servers = ['a', 'b', 'c']
        Properties.sharing_space_servers = servers
        collection_name = str(uuid.uuid4())
        subscriber_list = [self.__subscriber_id, self.__second_subscriber_id]
        sharing_secret, subscribers_collections =\
        self.__create_sharing_record(subscriber_list, collection_name)
        load_balancer = SharingLoadBalancer.get_instance()
        load_balancer.get_sharing_space_info(sharing_secret, callback=self.stop)
        server_info = self.wait()
        server_adrs = server_info['server']
        self.assertTrue(server_adrs in servers)

        load_balancer.get_sharing_space_info(sharing_secret, callback=self.stop)
        second_server_info = self.wait()
        second_server_adrs = second_server_info['server']
        self.assertEqual(server_adrs, second_server_adrs)

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

    def test_get_sharing_space_info_invalid_secret(self):

        load_balancer = SharingLoadBalancer.get_instance()
        sharing_secret = 'doodoo'
        load_balancer.get_sharing_space_info(sharing_secret, callback=self.stop)
        second_server_info = self.wait()
        self.assertTrue(second_server_info is None)

    def test_remove_sharing_space_info(self):

        servers = ['a', 'b', 'c']
        Properties.sharing_space_servers = servers
        collection_name = str(uuid.uuid4())
        subscriber_list = [self.__subscriber_id, self.__second_subscriber_id]
        sharing_secret, subscribers_collections =\
        self.__create_sharing_record(subscriber_list, collection_name)
        load_balancer = SharingLoadBalancer.get_instance()
        load_balancer.get_sharing_space_info(sharing_secret, callback=self.stop)
        server_info = self.wait()
        server_adrs = server_info['server']
        self.assertTrue(server_adrs in servers)

        load_balancer.remove_sharing_space_info(sharing_secret,
            callback=self.stop)
        self.wait()

        is_cached = load_balancer.is_sharing_space_cached(sharing_secret)
        self.assertTrue(not is_cached)
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

    def test_remove_sharing_space_info_invalid_sharing_secret(self):

        load_balancer = SharingLoadBalancer.get_instance()
        sharing_secret = 'seeeecret'
        load_balancer.remove_sharing_space_info(sharing_secret,
            callback=self.stop)
        self.wait()
        #nothing should happen and no exception should be thrown

    def test_remove_already_removed_sharing_space_info(self):

        servers = ['a', 'b', 'c']
        Properties.sharing_space_servers = servers
        collection_name = str(uuid.uuid4())
        subscriber_list = [self.__subscriber_id, self.__second_subscriber_id]
        sharing_secret, subscribers_collections =\
        self.__create_sharing_record(subscriber_list, collection_name)
        load_balancer = SharingLoadBalancer.get_instance()
        load_balancer.get_sharing_space_info(sharing_secret, callback=self.stop)
        server_info = self.wait()
        server_adrs = server_info['server']
        self.assertTrue(server_adrs in servers)

        load_balancer.remove_sharing_space_info(sharing_secret,
            callback=self.stop)
        self.wait()

        is_cached = load_balancer.is_sharing_space_cached(sharing_secret)
        self.assertTrue(not is_cached)

        load_balancer.remove_sharing_space_info(sharing_secret,
            callback=self.stop)
        self.wait()

        is_cached = load_balancer.is_sharing_space_cached(sharing_secret)
        self.assertTrue(not is_cached)

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

    def test_load_balancing_increasing_load(self):

        servers = ['a', 'b', 'c']
        Properties.sharing_space_servers = servers
        collection_name1 = str(uuid.uuid4())
        subscriber_list1 = [self.__subscriber_id, self.__second_subscriber_id]
        sharing_secret1, subscribers_collections1 =\
        self.__create_sharing_record(subscriber_list1, collection_name1)
        load_balancer = SharingLoadBalancer()
        load_balancer.get_sharing_space_info(sharing_secret1, callback=self.stop)
        server_info1 = self.wait()
        server_adrs1 = server_info1['server']
        print server_adrs1
        self.assertTrue(server_adrs1 in servers)

        collection_name2 = str(uuid.uuid4())
        subscriber_list2 = [self.__subscriber_id]
        sharing_secret2, subscribers_collections2 =\
        self.__create_sharing_record(subscriber_list2, collection_name2)
        load_balancer.get_sharing_space_info(sharing_secret2, callback=self.stop)
        server_info2 = self.wait()
        server_adrs2 = server_info2['server']
        self.assertTrue(server_adrs2 in servers)
        print server_adrs2
        self.assertNotEqual(server_adrs2, server_adrs1)


        collection_name3 = str(uuid.uuid4())
        subscriber_list3 = [self.__subscriber_id, self.__second_subscriber_id]
        sharing_secret3, subscribers_collections3 =\
        self.__create_sharing_record(subscriber_list3, collection_name3)
        load_balancer.get_sharing_space_info(sharing_secret3, callback=self.stop)
        server_info3 = self.wait()
        server_adrs3 = server_info3['server']
        print server_adrs3
        self.assertTrue(server_adrs3 in servers)
        self.assertNotEqual(server_adrs3, server_adrs1)
        self.assertNotEqual(server_adrs3, server_adrs2)


        collection_name4 = str(uuid.uuid4())
        subscriber_list4 = [self.__subscriber_id, self.__second_subscriber_id]
        sharing_secret4, subscribers_collections4 =\
        self.__create_sharing_record(subscriber_list4, collection_name4)
        load_balancer.get_sharing_space_info(sharing_secret4, callback=self.stop)
        server_info4 = self.wait()
        server_adrs4 = server_info4['server']
        print server_adrs4
        self.assertTrue(server_adrs4 in servers)
        self.assertEqual(server_adrs4, server_adrs2)

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret1, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, collection_name1,
            callback=self.stop)
        for subscriber_id in subscribers_collections1:
            subscriber_collection = subscribers_collections1[subscriber_id]
            StorageServer.remove_collection(subscriber_id, subscriber_collection,
                callback=self.stop)
            self.wait()

        SharingController.remove_sharing_record_by_secret(sharing_secret2, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, collection_name2,
            callback=self.stop)
        for subscriber_id in subscribers_collections2:
            subscriber_collection = subscribers_collections2[subscriber_id]
            StorageServer.remove_collection(subscriber_id, subscriber_collection,
                callback=self.stop)
            self.wait()

        SharingController.remove_sharing_record_by_secret(sharing_secret3, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, collection_name3,
            callback=self.stop)
        for subscriber_id in subscribers_collections3:
            subscriber_collection = subscribers_collections3[subscriber_id]
            StorageServer.remove_collection(subscriber_id, subscriber_collection,
                callback=self.stop)
            self.wait()

        SharingController.remove_sharing_record_by_secret(sharing_secret4, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, collection_name4,
            callback=self.stop)
        for subscriber_id in subscribers_collections4:
            subscriber_collection = subscribers_collections4[subscriber_id]
            StorageServer.remove_collection(subscriber_id, subscriber_collection,
                callback=self.stop)
            self.wait()


    def test_load_balancing_increasing_decreasing_load(self):

        servers = ['a', 'b', 'c']
        Properties.sharing_space_servers = servers
        collection_name1 = str(uuid.uuid4())
        subscriber_list1 = [self.__subscriber_id, self.__second_subscriber_id]
        sharing_secret1, subscribers_collections1 =\
        self.__create_sharing_record(subscriber_list1, collection_name1)
        load_balancer = SharingLoadBalancer()
        load_balancer.get_sharing_space_info(sharing_secret1, callback=self.stop)
        server_info1 = self.wait()
        server_adrs1 = server_info1['server']
        print server_adrs1
        self.assertTrue(server_adrs1 in servers)

        collection_name2 = str(uuid.uuid4())
        subscriber_list2 = [self.__subscriber_id]
        sharing_secret2, subscribers_collections2 =\
        self.__create_sharing_record(subscriber_list2, collection_name2)
        load_balancer.get_sharing_space_info(sharing_secret2, callback=self.stop)
        server_info2 = self.wait()
        server_adrs2 = server_info2['server']
        print server_adrs2
        self.assertTrue(server_adrs2 in servers)
        self.assertNotEqual(server_adrs2, server_adrs1)


        collection_name3 = str(uuid.uuid4())
        subscriber_list3 = [self.__subscriber_id, self.__second_subscriber_id]
        sharing_secret3, subscribers_collections3 =\
        self.__create_sharing_record(subscriber_list3, collection_name3)
        load_balancer.get_sharing_space_info(sharing_secret3, callback=self.stop)
        server_info3 = self.wait()
        server_adrs3 = server_info3['server']
        print server_adrs3
        self.assertTrue(server_adrs3 in servers)
        self.assertNotEqual(server_adrs3, server_adrs1)
        self.assertNotEqual(server_adrs3, server_adrs2)


        load_balancer.remove_sharing_space_info(sharing_secret1, callback=self.stop)
        self.wait()

        collection_name4 = str(uuid.uuid4())
        subscriber_list4 = [self.__subscriber_id, self.__second_subscriber_id]
        sharing_secret4, subscribers_collections4 =\
        self.__create_sharing_record(subscriber_list4, collection_name4)
        load_balancer.get_sharing_space_info(sharing_secret4, callback=self.stop)
        server_info4 = self.wait()
        server_adrs4 = server_info4['server']
        print server_adrs4
        self.assertTrue(server_adrs4 in servers)
        self.assertEqual(server_adrs4, server_adrs1)


        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret1, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, collection_name1,
            callback=self.stop)
        for subscriber_id in subscribers_collections1:
            subscriber_collection = subscribers_collections1[subscriber_id]
            StorageServer.remove_collection(subscriber_id, subscriber_collection,
                callback=self.stop)
            self.wait()

        SharingController.remove_sharing_record_by_secret(sharing_secret2, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, collection_name2,
            callback=self.stop)
        for subscriber_id in subscribers_collections2:
            subscriber_collection = subscribers_collections2[subscriber_id]
            StorageServer.remove_collection(subscriber_id, subscriber_collection,
                callback=self.stop)
            self.wait()

        SharingController.remove_sharing_record_by_secret(sharing_secret3, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, collection_name3,
            callback=self.stop)
        for subscriber_id in subscribers_collections3:
            subscriber_collection = subscribers_collections3[subscriber_id]
            StorageServer.remove_collection(subscriber_id, subscriber_collection,
                callback=self.stop)
            self.wait()

        SharingController.remove_sharing_record_by_secret(sharing_secret4, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, collection_name4,
            callback=self.stop)
        for subscriber_id in subscribers_collections4:
            subscriber_collection = subscribers_collections4[subscriber_id]
            StorageServer.remove_collection(subscriber_id, subscriber_collection,
                callback=self.stop)
            self.wait()
