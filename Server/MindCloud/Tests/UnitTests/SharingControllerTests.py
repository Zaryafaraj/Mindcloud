import random
import uuid
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Sharing.SharingController import SharingController
from Sharing.SharingRecord import SharingRecord
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer
from Tests.TestingProperties import TestingProperties

__author__ = 'afathali'

class SharingControllerTestCase(AsyncTestCase):

    __account_id = TestingProperties.account_id
    __subscriber_id = TestingProperties.subscriber_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_save_sharing_record(self):
        collection_name = 'test_collection'
        SharingController.create_sharing_record(self.__account_id, collection_name, callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)

        #verify subscriber collection
        SharingController.get_sharing_secret_from_subscriber_info(self.__account_id,
            collection_name,
            callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertEqual(sharing_secret, actual_sharing_secret)

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()

    def test_add_subscriber_to_subscriber_collection(self):

        collection_name = 'dummy_collection'
        sharing_secret = 'secret'
        SharingController.add_subscriber(self.__account_id,
                                        collection_name,
                                        sharing_secret,
                                        callback=self.stop)
        self.wait()

        SharingController.get_sharing_secret_from_subscriber_info(self.__account_id,
                                                                collection_name,
                                                                callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertEqual(sharing_secret, actual_sharing_secret)

        #cleanup
        SharingController.remove_subscriber(self.__account_id,
                                            collection_name,
                                            callback=self.stop)
        self.wait()

    def test_get_sharing_record_from_subscriber_info(self):

        collection_name = "col_name"
        SharingController.create_sharing_record(self.__account_id, collection_name,
            callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)

        SharingController.get_sharing_record_from_subscriber_info(self.__account_id,
            collection_name,callback=self.stop)
        sharing_record = self.wait()
        actual_sharing_secret = sharing_record.get_sharing_secret()
        self.assertEqual(sharing_secret, actual_sharing_secret)

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()

    def test_get_sharing_record_from_subscriber_info_non_existing_shared_space(self):

        SharingController.get_sharing_record_from_subscriber_info(self.__account_id,
            'dummy',callback=self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)

    def test_get_sharing_record_from_subscriber_info_non_existing_subscriber(self):
        collection_name = "col_name"
        SharingController.create_sharing_record(self.__account_id, collection_name,
            callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)

        SharingController.get_sharing_record_from_subscriber_info('dummy_account',
            collection_name,callback=self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()

    def test_remove_subscriber_from_subscriber_collection(self):

        collection_name = 'dummy_collection'
        sharing_secret = 'secret'
        SharingController.add_subscriber(self.__account_id,
            collection_name,
            sharing_secret,
            callback=self.stop)
        self.wait()

        SharingController.get_sharing_secret_from_subscriber_info(self.__account_id,
            collection_name,
            callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertEqual(sharing_secret, actual_sharing_secret)

        SharingController.remove_subscriber(self.__account_id,
            collection_name,
            callback=self.stop)
        self.wait()

        SharingController.get_sharing_secret_from_subscriber_info(self.__account_id,
            collection_name,
            callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertTrue(actual_sharing_secret is None)

    def test_remove_all_subscribers(self):

        collection_name = 'shareable_collection'
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=collection_name, callback=self.stop, file= file)
        response = self.wait()

        self.assertEqual(StorageResponse.OK, response)

        SharingController.create_sharing_record(self.__account_id,
            collection_name, callback=self.stop)
        sharing_secret = self.wait()

        SharingController.subscribe_to_sharing_space(self.__subscriber_id,
            sharing_secret, callback= self.stop)
        collection_name2 = self.wait(timeout=500)


        SharingController.remove_all_subscribers(sharing_secret, callback=self.stop)
        self.wait(timeout=10000)

        #busy wait for the results of remove all subscribers to become consistent
        try:
            self.wait(timeout=5)
        except Exception:
            pass

        SharingController.get_sharing_secret_from_subscriber_info(self.__account_id,
            collection_name,
            callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertTrue(actual_sharing_secret is None)
        SharingController.get_sharing_secret_from_subscriber_info('second_user',
            collection_name2,
            callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertTrue(actual_sharing_secret is None)


    def test_get_sharing_record_by_sharing_secret(self):
        SharingController.create_sharing_record(self.__account_id, 'test_collection', callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)
        SharingController.get_sharing_record_by_secret(sharing_secret, callback = self.stop)
        sharing_record = self.wait()
        actual_sharing_secret = sharing_record.toDictionary()[SharingRecord.SECRET_KEY]
        self.assertEqual(sharing_secret, actual_sharing_secret)
        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()

    def test_get_sharing_record_by_owner_info(self):
        collection_name = "col_name"
        SharingController.create_sharing_record(self.__account_id, collection_name,
            callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)

        SharingController.get_sharing_record_by_owner_info(self.__account_id,
            collection_name, callback = self.stop)
        sharing_record = self.wait()
        actual_sharing_secret = sharing_record.get_sharing_secret()
        self.assertEqual(sharing_secret, actual_sharing_secret)
        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()

    def test_get_invalid_sharing_record_by_owner_info(self):
        SharingController.get_sharing_record_by_owner_info(self.__account_id,
            'dummy', callback = self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)

    def test_get_non_existing_sharing_record(self):
        SharingController.get_sharing_record_by_secret('invalidsecret', callback = self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)

    def test_remove_sharing_record_by_sharing_secret(self):

        collection_name = 'test_collection'
        SharingController.create_sharing_record(self.__account_id, collection_name, callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()
        SharingController.get_sharing_record_by_secret(sharing_secret, callback = self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)

        #verify subscriber collection
        SharingController.get_sharing_secret_from_subscriber_info(self.__account_id,
            collection_name,
            callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertTrue(actual_sharing_secret is None)

    def test_remove_sharing_record_by_owner_info(self):
        collection_name = 'test_collection_name'
        SharingController.create_sharing_record(self.__account_id,
            collection_name, callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)
        SharingController.remove_sharing_record_by_owner_info(self.__account_id,
            collection_name, callback=self.stop)
        self.wait(timeout=10)
        #verify
        SharingController.get_sharing_record_by_secret(sharing_secret, callback = self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)
        #verify subscriber collection
        SharingController.get_sharing_secret_from_subscriber_info(self.__account_id,
            collection_name,
            callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertTrue(actual_sharing_secret is None)

    def test_add_subscriber(self):

        #create collection
        first_collection_name = 'shareable_collection'
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=first_collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #create sharing record
        SharingController.create_sharing_record(self.__account_id,
            first_collection_name, callback = self.stop)
        sharing_secret = self.wait(timeout=10000)
        self.assertTrue(sharing_secret is not None)

        #subscribe
        SharingController.subscribe_to_sharing_space(self.__subscriber_id,
                                                     sharing_secret, callback = self.stop)
        subscribers_collection_name  = self.wait()
        self.assertTrue(subscribers_collection_name is not None)

        #verify
        SharingController.get_sharing_record_by_secret(sharing_secret, callback = self.stop)
        sharing_record = self.wait()
        subscribers_list = sharing_record.get_subscribers()
        self.assertTrue([self.__subscriber_id, subscribers_collection_name] in
                        subscribers_list)
        #verify subscriber collection
        SharingController.get_sharing_secret_from_subscriber_info(self.__subscriber_id,
            subscribers_collection_name,
            callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertEqual(sharing_secret, actual_sharing_secret)
        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, first_collection_name,
            callback=self.stop)
        self.wait()
        StorageServer.remove_collection(self.__subscriber_id, subscribers_collection_name,
            callback=self.stop)
        self.wait()

    def test_reshare_already_shared_collection(self):

        #create collection
        first_collection_name = 'shareable_collection'
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=first_collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #create sharing record
        SharingController.create_sharing_record(self.__account_id,
            first_collection_name, callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)

        #duplicate create sharing record
        SharingController.create_sharing_record(self.__account_id,
            first_collection_name, callback = self.stop)
        new_sharing_secret = self.wait()
        self.assertEqual(sharing_secret, new_sharing_secret)

        #verify that only one sharing record was added
        SharingController.get_sharing_record_by_owner_info(self.__account_id,
            first_collection_name, callback=self.stop)
        sharing_record = self.wait()
        subscribers_list = sharing_record.get_subscribers()
        self.assertEqual(1, len(subscribers_list))

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, first_collection_name,
            callback=self.stop)
        self.wait()

    def test_subscribing_to_an_already_subscribed_collectoin(self):

        #create collection
        first_collection_name = 'shareable_collection'
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=first_collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #create sharing record
        SharingController.create_sharing_record(self.__account_id,
            first_collection_name, callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)

        #subscribe
        SharingController.subscribe_to_sharing_space(self.__subscriber_id,
            sharing_secret, callback = self.stop)
        subscribers_collection_name  = self.wait()
        self.assertTrue(subscribers_collection_name is not None)

        SharingController.subscribe_to_sharing_space(self.__subscriber_id,
            sharing_secret, callback = self.stop)
        duplicate_subscribers_collection_name  = self.wait()
        self.assertTrue(subscribers_collection_name is not None)
        self.assertEqual(subscribers_collection_name, duplicate_subscribers_collection_name)

        #verify
        SharingController.get_sharing_record_by_secret(sharing_secret, callback = self.stop)
        sharing_record = self.wait()
        subscribers_list = sharing_record.get_subscribers()
        self.assertEqual(2, len(subscribers_list))

        #verify subscriber collection
        SharingController.get_sharing_secret_from_subscriber_info(self.__subscriber_id,
            subscribers_collection_name,
            callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertEqual(sharing_secret, actual_sharing_secret)

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, first_collection_name,
            callback=self.stop)
        self.wait()
        StorageServer.remove_collection(self.__subscriber_id, subscribers_collection_name,
            callback=self.stop)
        self.wait()

    def test_subscriber_unsubscribing(self):

        #create collection
        first_collection_name = 'shareable_collection'
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=first_collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #create sharing record
        SharingController.create_sharing_record(self.__account_id,
            first_collection_name, callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)

        #subscribe
        SharingController.subscribe_to_sharing_space(self.__subscriber_id,
            sharing_secret, callback = self.stop)
        subscribers_collection_name  = self.wait()
        self.assertTrue(subscribers_collection_name is not None)

        #unsubscribe
        SharingController.unsubscribe_from_sharing_space(self.__subscriber_id,
            subscribers_collection_name, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #verify unsubscribe
        SharingController.get_sharing_record_by_secret(sharing_secret,
            callback = self.stop)
        sharing_record = self.wait()
        subscribers_list = sharing_record.get_subscribers()
        self.assertTrue(self.__subscriber_id not in subscribers_list)

        SharingController.get_sharing_record_from_subscriber_info(self.__subscriber_id,
        subscribers_collection_name, callback=self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, first_collection_name,
            callback=self.stop)
        self.wait()
        StorageServer.remove_collection(self.__subscriber_id, subscribers_collection_name,
            callback=self.stop)

    def test_owner_unsubscribing(self):

        #create collection
        first_collection_name = 'shareable_collection'
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=first_collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #create sharing record
        SharingController.create_sharing_record(self.__account_id,
            first_collection_name, callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)

        #subscribe
        SharingController.subscribe_to_sharing_space(self.__subscriber_id,
            sharing_secret, callback = self.stop)
        subscribers_collection_name  = self.wait()
        self.assertTrue(subscribers_collection_name is not None)

        #owner unsubscribe
        SharingController.unsubscribe_from_sharing_space(self.__account_id,
            first_collection_name, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #verify unsubscribe
        SharingController.get_sharing_record_by_secret(sharing_secret,
            callback = self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)

        SharingController.get_sharing_record_from_subscriber_info(self.__subscriber_id,
            subscribers_collection_name, callback=self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, first_collection_name,
            callback=self.stop)
        self.wait()
        StorageServer.remove_collection(self.__subscriber_id, subscribers_collection_name,
            callback=self.stop)

    def test_invalid_user_unsubscribing(self):

        #create collection
        first_collection_name = 'shareable_collection'
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=first_collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #create sharing record
        SharingController.create_sharing_record(self.__account_id,
            first_collection_name, callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)

        #subscribe
        SharingController.subscribe_to_sharing_space(self.__subscriber_id,
            sharing_secret, callback = self.stop)
        subscribers_collection_name  = self.wait()
        self.assertTrue(subscribers_collection_name is not None)

        #invalid unsubscribe
        SharingController.unsubscribe_from_sharing_space('dummy',
            first_collection_name, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.NOT_FOUND, response)

        #verify unsubscribe
        SharingController.get_sharing_record_from_subscriber_info('dummy',
            subscribers_collection_name, callback=self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, first_collection_name,
            callback=self.stop)
        self.wait()
        StorageServer.remove_collection(self.__subscriber_id, subscribers_collection_name,
            callback=self.stop)


    def test_remove_all_subscribers_detailed(self):

        #create collection
        first_collection_name = 'shareable_collection'
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=first_collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #create sharing record
        SharingController.create_sharing_record(self.__account_id,
            first_collection_name, callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)

        #subscribe
        SharingController.subscribe_to_sharing_space(self.__subscriber_id,
            sharing_secret, callback = self.stop)
        subscribers_collection_name  = self.wait()
        self.assertTrue(subscribers_collection_name is not None)

        #remove all subscribers
        SharingController.remove_all_subscribers(sharing_secret,
            callback=self.stop)
        self.wait()

        #verify removed subscribers from subscriber table
        SharingController.get_sharing_record_from_subscriber_info(self.__subscriber_id,
            subscribers_collection_name, callback=self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)
        SharingController.get_sharing_record_from_subscriber_info(self.__account_id,
           first_collection_name , callback=self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, first_collection_name,
            callback=self.stop)
        self.wait()
        StorageServer.remove_collection(self.__subscriber_id, subscribers_collection_name,
            callback=self.stop)
        self.wait()

    def test_rename_shared_collection_owner(self):

        #create collection
        first_collection_name = 'shareable_collection' + str(random.randint)
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=first_collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #create sharing record
        SharingController.create_sharing_record(self.__account_id,
            first_collection_name, callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)

        #subscribe
        SharingController.subscribe_to_sharing_space(self.__subscriber_id,
            sharing_secret, callback = self.stop)
        subscribers_collection_name  = self.wait()
        self.assertTrue(subscribers_collection_name is not None)

        #rename
        new_collection_name = 'new_name' + str(random.randint)
        SharingController.rename_shared_collection(self.__account_id, first_collection_name,
            new_collection_name, callback=self.stop)
        response_code = self.wait()
        self.assertTrue(StorageResponse.OK, response_code)

        #verify
        SharingController.get_sharing_record_by_secret(sharing_secret, callback = self.stop)
        sharing_record = self.wait()
        renamed_collection_name = sharing_record.get_owner_collection_name()
        self.assertEqual(new_collection_name, renamed_collection_name)

        #verify owner collection
        SharingController.get_sharing_secret_from_subscriber_info(self.__account_id,
            new_collection_name,
            callback=self.stop)
        renamed_sharing_secret = self.wait()
        self.assertEqual(sharing_secret, renamed_sharing_secret)

        #verify subscriber collection
        SharingController.get_sharing_record_from_subscriber_info(self.__subscriber_id,
            subscribers_collection_name,
            callback=self.stop)
        renamed_sharing_record = self.wait()
        owner_collection_name = \
            renamed_sharing_record.get_collection_name_for_subscriber(self.__account_id)
        self.assertEqual(new_collection_name, renamed_sharing_record.get_owner_collection_name())
        self.assertEqual(new_collection_name, owner_collection_name)

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, first_collection_name,
            callback=self.stop)
        self.wait()
        StorageServer.remove_collection(self.__subscriber_id, subscribers_collection_name,
            callback=self.stop)
        self.wait()

    def test_rename_invalid_shared_collection(self):

        new_collection_name = 'new_name' + str(random.randint)
        SharingController.rename_shared_collection(self.__account_id, 'looloo',
            new_collection_name, callback=self.stop)
        response_code = self.wait()
        self.assertTrue(StorageResponse.NOT_FOUND, response_code)

    def test_rename_shared_collection_subscriber(self):

        #create collection
        first_collection_name = 'shareable_collection' + str(random.randint)
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=first_collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #create sharing record
        SharingController.create_sharing_record(self.__account_id,
            first_collection_name, callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)

        #subscribe
        SharingController.subscribe_to_sharing_space(self.__subscriber_id,
            sharing_secret, callback = self.stop)
        subscribers_collection_name  = self.wait()
        self.assertTrue(subscribers_collection_name is not None)

        #rename
        new_collection_name = 'new_name' + str(random.randint)
        SharingController.rename_shared_collection(self.__subscriber_id,
            subscribers_collection_name, new_collection_name, callback=self.stop)
        response_code = self.wait()
        self.assertTrue(StorageResponse.OK, response_code)

        #verify
        SharingController.get_sharing_record_by_secret(sharing_secret, callback = self.stop)
        sharing_record = self.wait()
        renamed_collection_name = \
            sharing_record.get_collection_name_for_subscriber(self.__subscriber_id)
        self.assertEqual(new_collection_name, renamed_collection_name)
        owner_collection_name = sharing_record.get_owner_collection_name()
        self.assertEqual(first_collection_name, owner_collection_name)

        #verify subscriber collection
        SharingController.get_sharing_secret_from_subscriber_info(self.__subscriber_id,
            new_collection_name,
            callback=self.stop)
        renamed_sharing_secret = self.wait()
        self.assertEqual(sharing_secret, renamed_sharing_secret)

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, first_collection_name,
            callback=self.stop)
        self.wait()
        StorageServer.remove_collection(self.__subscriber_id, subscribers_collection_name,
            callback=self.stop)
        self.wait()

