import asyncmongo

__author__ = 'afathali'

class DatabaseFactory:

    #TODO replace these with properties file
    #MongoDB configs
    __host = 'localhost'
    __port = 27017
    __database_name = 'mindcloud'
    __accounts_collection_name = 'accounts'

    @staticmethod
    def __get_accounts_db():
        if not hasattr(DatabaseFactory, '__accounts_db'):
            DatabaseFactory.__accounts_db =\
            asyncmongo.Client(pool_id='accounts_pool', host = DatabaseFactory.__host,
                port= DatabaseFactory.__port, maxcached=10, maxconnections=100,
                dbname=DatabaseFactory.__database_name)
        return DatabaseFactory.__accounts_db

    @staticmethod
    def get_accounts_collection():

        db = DatabaseFactory.__get_accounts_db()
        collection_connection = db.connection(collectionname=DatabaseFactory.__accounts_collection_name)
        return collection_connection



