"""
Developed for Mindcloud
"""
from tornado import gen
from Storage.DatabaseFactory import DatabaseFactory

__author__ = 'afathali'

class Accounts:
    """
    Handles the persistent storage for accounts metadata that is stored in mindclouds mongoDB
    Right now we don't require sign ins . Anybody with a unique GUID can use the system.
    If its the first time that the user with that GUID is contacting the server he is asked
    to authenticate.
    After authnetication, the user and his authentication credentials are stored in the DB
    for later use.
    """

    account_key = 'account_id'
    ticket_key = 'ticket'

    @staticmethod
    def __get_collection():
        return DatabaseFactory.get_accounts_collection()

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
    @gen.engine
    def add_account(account_id, account_info, callback):
        """
        Stores the user and its credentials in the DB

        Args:
            -``account_id``: The unique GUID that the client sends with his calls
            -``account_info``: An object containing two fields: account key and account secret.
            Any object will do.
            -``callback``: callback function to call when account is added
        """
        collection = Accounts.__get_collection()
        #we store an accountInfo as a pair of key and secret
        account_tuple = (account_info.key, account_info.secret)
        account = {Accounts.account_key: account_id,
                   Accounts.ticket_key: account_tuple}
        yield gen.Task(collection.insert, account)
        callback()

    @staticmethod
    @gen.engine
    def delete_account(account_id, callback):
        """
        Remove the account associated with account_id from mongo

        Args:
            -``account_id``: The unique GUID that the client sends with his calls
        """
        collection = Accounts.__get_collection()
        account = {Accounts.account_key: account_id}
        yield gen.Task(collection.remove, account)
        callback()
