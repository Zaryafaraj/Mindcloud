"""
Developed for Mindcloud
"""
from tornado import gen

__author__ = 'afathali'

import asyncmongo

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

    @staticmethod
    def get_db():
        if not hasattr(Accounts, '_db'):
            Accounts._db=asyncmongo.Client(pool_id='accounts_pool', host=Accounts.host, port= Accounts.port,
            maxcached=10, maxconnections=100, dbname=Accounts.database_name)
        return Accounts._db

    @staticmethod
    def __get_collection():
        """
        Retrive the accounts collection from mongo

        Returns:
            - A mongoDB collection corellating with the accounts
        """
        db = Accounts.get_db()
        collection_connection = db.connection(collectionname=Accounts.collection_name)
        return collection_connection

    @staticmethod
    @gen.engine
    def get_account(account_id, callback):
        """
        Retrieves the user account credentials associated with account_id

        Args:
            -``account_id``: The unique GUID that the client sends with his calls

        Returns:
            - If account_id exists:
            A dictionary containing:
             {ticket: (key, secret), account_id: account_id}.
            The key and secret pair has been authorized by the user in an Oauth manner
            and mindcloud has access to the account  of the user associated with these.

            None if the account does not exist

        """

        collection = Accounts.__get_collection()
        account = {Accounts.account_key: account_id}
        account = yield gen.Task(collection.find_one,account)
        #Weird return type from the asyncMongo lib
        if not len(account[0][0]):
            account_info = None
            #TODO log something here later
        else:
            account_info = account[0][0]
            #remove the mongoID from the answer
            del(account_info['_id'])

        callback(account_info)

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
