from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Sharing.SharingController import SharingController
from Sharing.SharingRecord import SharingRecord

__author__ = 'afathali'

class SharingControllerTestCase(AsyncTestCase):

    __account_id = '04B08CB7-17D5-493A-8ED1-E086FDC1327E'

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_save_sharing_record(self):
        SharingController.create_sharing_record(self.__account_id, 'test_collection', callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)

    def test_get_sharing_record(self):
        SharingController.create_sharing_record(self.__account_id, 'test_collection', callback = self.stop)
        sharing_secret = self.wait()
        self.assertTrue(sharing_secret is not None)
        SharingController.get_sharing_info(sharing_secret, callback = self.stop)
        sharing_record = self.wait()
        print sharing_record.toDictionary()
        actual_sharing_secret = sharing_record.toDictionary()[SharingRecord.SECRET_KEY]
        self.assertEqual(sharing_secret, actual_sharing_secret)

