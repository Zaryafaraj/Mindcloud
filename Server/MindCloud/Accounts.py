"""
handles consistent storage for accounts
"""
__author__ = 'afathali'
import pymongo

class Accounts:
    #TODO replace these with properties file
    host = 'localhost'
    port = 27017
    database_name = 'mindcloud'
    collection_name = 'accounts'
    account_key = 'account_id'
    ticket_key = 'ticket'

    conn = pymongo.Connection(host, port)

    @staticmethod
    def get_collection():
        db = Accounts.conn[Accounts.database_name]
        return db[Accounts.collection_name]

    @staticmethod
    def does_account_exist(account_id):
        collection = Accounts.get_collection()
        account = {Accounts.account_key: account_id}
        did_find = collection.find_one(account)
        return did_find

    @staticmethod
    def get_account(account_id):
        account_info = Accounts.does_account_exist(account_id)
        del account_info['_id']
        return account_info

    @staticmethod
    def add_account(account_id, accountInfo):
        #we store an accountInfo as a pair of key and secret
        accountTuple = (accountInfo.key,accountInfo.secret)
        account = {Accounts.account_key: account_id,
                   Accounts.ticket_key: accountTuple}
        collection = Accounts.get_collection()
        collection.insert(account)

    @staticmethod
    def delete_account(account_id):
        collection = Accounts.get_collection()
        account = {Accounts.account_key: account_id}
        collection.remove(account)

if __name__ == '__main__':

    account_id = 'dummy_id'
    print 'Testing for ' + account_id
    does_exist = Accounts.does_account_exist(account_id) is not None
    print "does exist ? " + str(does_exist)
    dummy_account_info = ('token', 'secret')
    print 'adding'
    Accounts.add_account(account_id, dummy_account_info)
    does_exist = Accounts.does_account_exist(account_id) is not None
    print 'does exist ? ' + str(does_exist)
    account_info = Accounts.get_account(account_id)
    print account_info
    print 'deleting'
    Accounts.delete_account(account_id)
    print 'done'
