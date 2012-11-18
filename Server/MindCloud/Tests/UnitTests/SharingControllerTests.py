from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Sharing.SharingController import SharingController
from Sharing.SharingRecord import SharingRecord

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
        SharingController.remove_sharing_record(sharing_secret, callback =self.stop)
        self.wait()

    def test_get_sharing_record(self):
        SharingController.create_sharing_record(self.__account_id, 'test_collection', callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)
        SharingController.get_sharing_record(sharing_secret, callback = self.stop)
        sharing_record = self.wait()
        actual_sharing_secret = sharing_record.toDictionary()[SharingRecord.SECRET_KEY]
        self.assertEqual(sharing_secret, actual_sharing_secret)
        #cleanup
        SharingController.remove_sharing_record(sharing_secret, callback =self.stop)
        self.wait()

    def test_get_non_existing_sharing_record(self):
        SharingController.get_sharing_record('invalidsecret', callback = self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)

    def test_remove_sharing_record(self):
        SharingController.create_sharing_record(self.__account_id, 'test_collection', callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)
        SharingController.remove_sharing_record(sharing_secret, callback =self.stop)
        self.wait()
        SharingController.get_sharing_record(sharing_secret, callback = self.stop)
        sharing_record = self.wait()
        self.assertTrue(sharing_record is None)

    def test_update_sharing_record(self):

        #create
        SharingController.create_sharing_record(self.__account_id, 'test_collection', callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)

        #retrieve sharing record
        SharingController.get_sharing_record(sharing_secret, callback = self.stop)
        sharing_record = self.wait()
        actual_sharing_secret = sharing_record.get_sharing_secret()
        self.assertEqual(sharing_secret, actual_sharing_secret)

        #update the sharing record
        new_collection_name = 'new_name'
        sharing_record.set_collection_name(new_collection_name)
        SharingController.update_sharing_record(sharing_record, callback=self.stop)
        self.wait()

        #verify
        SharingController.get_sharing_record(sharing_secret, callback = self.stop)
        sharing_record = self.wait()
        actual_sharing_secret = sharing_record.get_sharing_secret()
        self.assertEqual(sharing_secret, actual_sharing_secret)
        actual_collection_name = sharing_record.get_owner_collection_name()
        self.assertEqual(new_collection_name, actual_collection_name)

        #cleanup
        SharingController.remove_sharing_record(sharing_secret, callback =self.stop)
        self.wait()



