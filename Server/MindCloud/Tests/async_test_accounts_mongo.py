from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from MindCloud.Accounts import Accounts

__author__ = 'afathali'


class MongoAccountTestCase(AsyncTestCase):

    __account_id = '04B08CB7-17D5-493A-8ED1-E086FDC1327E'

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_does_account_exist_true(self):
        Accounts.get_account(self.__account_id, callback=self.stop)
        account = self.wait()
        self.assertTrue(account is not None)

    def test_does_account_exist_false(self):
        Accounts.get_account('dummy', callback=self.stop)
        account = self.wait()
        self.assertTrue(account is None)

