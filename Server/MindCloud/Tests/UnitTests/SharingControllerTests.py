from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Sharing.SharingController import SharingController
from Sharing.SharingRecord import SharingRecord
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

__author__ = 'afathali'

class SharingControllerTestCase(AsyncTestCase):

    __account_id = '04B08CB7-17D5-493A-8ED1-E086FDC1327E'
    __subscriber_id = 'E82FD595-AD5E-4D91-B73D-3A7C3A3FEDCE'

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_save_sharing_record(self):
        SharingController.create_sharing_record(self.__account_id, 'test_collection', callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)
        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()

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
        SharingController.create_sharing_record(self.__account_id, 'test_collection', callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()
        SharingController.get_sharing_record_by_secret(sharing_secret, callback = self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)

    def test_remove_sharing_record_by_owner_info(self):
        collection_name = 'test_collection_name'
        SharingController.create_sharing_record(self.__account_id,
            collection_name, callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)
        SharingController.remove_sharing_record_by_owner_info(self.__account_id,
            collection_name, callback=self.stop)
        self.wait()
        #verify
        SharingController.get_sharing_record_by_secret(sharing_secret, callback = self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)

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
        sharing_secret = self.wait()
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
        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback =self.stop)
        self.wait()
        StorageServer.remove_collection(self.__account_id, first_collection_name,
            callback=self.stop)
        self.wait()
        StorageServer.remove_collection(self.__subscriber_id, subscribers_collection_name,
            callback=self.stop)
        self.wait()


