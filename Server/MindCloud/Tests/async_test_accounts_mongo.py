import uuid
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from MindCloud.Accounts import Accounts

__author__ = 'afathali'


class MongoAccountTestCase(AsyncTestCase):

    __account_id = '04B08CB7-17D5-493A-8ED1-E086FDC1327E'

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_get_account_valid_account(self):
        Accounts.get_account(self.__account_id, callback=self.stop)
        account = self.wait()
        self.assertTrue(account is not None)

    def test_get_account_invalid_account(self):
        Accounts.get_account('dummy', callback=self.stop)
        account = self.wait()
        self.assertTrue(account is None)

    def test_add_account(self):
        account_id =str(uuid.uuid1())
        class dummyInfo:
            pass

        dummy_info = dummyInfo()
        dummy_info.key = str(uuid.uuid1())
        dummy_info.secret = str(uuid.uuid1())
        Accounts.add_account(account_id, dummy_info, callback=self.stop)
        did_insert = self.wait()
        Accounts.get_account(account_id, callback=self.stop)
        actual_info = self.wait()
        actual_account_id = actual_info['account_id']

        self.assertEqual(account_id, actual_account_id)

