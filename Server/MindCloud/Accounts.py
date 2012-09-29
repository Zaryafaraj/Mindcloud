"""
Developed for Mindcloud
"""
__author__ = 'afathali'

import pymongo

class Accounts:
    """
    Handles the persistent storage for accounts metadata that is stored in mindclouds mongoDB
    Right now we don't require sign ins . Anybody with a unique GUID can use the system.
    If its the first time that the user with that GUID is contacting the server he is asked
    to authenticate.
    After authnetication, the user and his authentication credentials are stored in the DB
    for later use.
    """

    #TODO replace these with properties file
    #MongoDB configs
    host = 'localhost'
    port = 27017
    database_name = 'mindcloud'
    collection_name = 'accounts'
    account_key = 'account_id'
    ticket_key = 'ticket'

    conn = pymongo.Connection(host, port)

    @staticmethod
    def __get_collection():
        """
        Retrive the accounts collection from mongo

        Returns:
            - A mongoDB collection corellating with the accounts
        """

        db = Accounts.conn[Accounts.database_name]
        return db[Accounts.collection_name]

    @staticmethod
    def does_account_exist(account_id):
        """
        Has a user has previsouly used mindcloud

        Args:
            -``account_id``: The unique GUID that the client sends with his calls

        Returns:
            - A collection if the account exists and None if it doesn't.
             We don't return true or false to minimize calls to Mongo
             in cases where we need to have a does exist / get
        """
        collection = Accounts.__get_collection()
        account = {Accounts.account_key: account_id}
        did_find = collection.find_one(account)
        return did_find

    @staticmethod
    def get_account(account_id):
        """
        Retrieves the user account credentials associated with account_id

        Args:
            -``account_id``: The unique GUID that the client sends with his calls

        Returns:
            - A tuple containing (key, secret). This key and secret pair has been
            authorized by the user in an Oauth manner and mindcloud has access
            to the account of the user associated with these

        """

        accountInfo = Accounts.does_account_exist(account_id)
        if accountInfo is not None:
            del accountInfo['_id']
        return accountInfo

    @staticmethod
    def add_account(account_id, account_info):
        """
        Stores the user and its credentials in the DB

        Args:
            -``account_id``: The unique GUID that the client sends with his calls
            -``account_info``: An object containing to fields: account key and account secret.
            Any object will do.
        """

        #we store an accountInfo as a pair of key and secret
        account_tuple = (account_info.key, account_info.secret)
        account = {Accounts.account_key: account_id,
                   Accounts.ticket_key: account_tuple}
        collection = Accounts.__get_collection()
        collection.insert(account)

    @staticmethod
    def delete_account(account_id):
        """
        Remove the account associated with account_id from mongo

        Args:
            -``account_id``: The unique GUID that the client sends with his calls
        """
        collection = Accounts.__get_collection()
        account = {Accounts.account_key: account_id}
        collection.remove(account)

if __name__ == '__main__':

    accountId = 'dummy_id'
    print 'Testing for ' + accountId
    does_exist = Accounts.does_account_exist(accountId) is not None
    print "does exist ? " + str(does_exist)
    dummy_account_info = ('token', 'secret')
    print 'adding'
    Accounts.add_account(accountId, dummy_account_info)
    does_exist = Accounts.does_account_exist(accountId) is not None
    print 'does exist ? ' + str(does_exist)
    account_info = Accounts.get_account(accountId)
    print account_info
    print 'deleting'
    Accounts.delete_account(accountId)
    print 'done'
