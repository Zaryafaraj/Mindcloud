from unittest import TestCase
from MindCloud.Accounts import Accounts

__author__ = 'afathali'

class TestAccounts(TestCase):

    user_id = 'EC77E567-2924-4C9E-BECA-36D25EA76431'

    def test_does_account_exist(self):
        does_exist = Accounts.does_account_exist(self.user_id)
        self.assertTrue(does_exist is not None)

    def test_does_account_exist_invalid_user(self):
        does_exist = Accounts.does_account_exist('dummy')
        self.assertTrue(does_exist is None)

    def test_get_account(self):
        account_info = Accounts.get_account(self.user_id)
        #Account contains both key/secret
        self.assertEqual(2, len(account_info))

    def test_get_account_invalid_user(self):
        account_info = Accounts.get_account('dummy')
        self.assertTrue(account_info is None)

    def __get_dummy_account_info(self):

        class dummyInfo:
            pass

        dummy_info = dummyInfo()
        dummy_info.key = 'key'
        dummy_info.secret = 'secret'
        return dummy_info

    def test_add_account(self):
        user_id = 'test'
        dummyInfo = self.__get_dummy_account_info()
        Accounts.add_account(user_id, dummyInfo)
        does_exist = Accounts.does_account_exist(user_id)
        self.assertTrue(does_exist is not None)

        #clean up
        Accounts.delete_account(user_id)

    def test_delete_account(self):
        user_id = 'test'
        dummyInfo = self.__get_dummy_account_info()
        Accounts.add_account(user_id, dummyInfo)
        Accounts.delete_account(user_id)
        does_exist = Accounts.does_account_exist('dummy')
        self.assertTrue(does_exist is None)

        def test_delete_non_existing_account(self):
            #Nothing should happen
            Accounts.delete_account('dummy')


