__author__ = 'afathali'
import Properties.MindcloudProperties as properties
import tornadoasyncmemcache as memcache

cache = memcache.ClientPool(properties.Properties.memcached_servers,
                            properties.Properties.memcached_max_clients)

class MindcloudCache():

    #we cast everything to str to make sure that unicode objects are not used to
    #access the cache

    def __create_cache_key(self, user_id, collection_name):
        return str(user_id + collection_name)

    def set_user_info(self, user_id, account_info_json, callback=None):
        """
        caches the user info .

        -Args:
            -``user_id``: The id of the user. This is the cache key
            -``account_info``: A json stucture consisting of (key, secret)
            for the user_id
        """
        if user_id is not None and account_info_json is not None:
            assert isinstance(user_id,str) or isinstance(user_id, unicode)
            assert isinstance(account_info_json,str) or isinstance(account_info_json, unicode)

            user_id = str(user_id)
            account_info_json = str(account_info_json)

            cache.set(user_id, account_info_json, callback=callback)

    def get_user_info(self, user_id, callback):
        """
        Tries to retrieve the user info for user_id from the cache


        -Args:
            -``user_id``: the key for the cache entry the id of the user
            -``callback``: The function to call with the account_info
            account_info contains a json for (key, secret).

        -Returns:
            -callback is called with the json for (key, secret) in case of
            a cache hit or None in case of a cache miss

        """


        if user_id is not None:
            assert isinstance(user_id,str) or isinstance(user_id, unicode)

            user_id = str(user_id)
            cache.get(user_id, callback=callback)

    def set_subscriber_info(self, user_id, collection_name, sharing_secret, callback=None):
        """
        Caches the subscriber sharing secret based on its primary key

        -Args:
            -``user_id``: The id of the subscriber
            -``colleciton_name``: The name of the collection which is shared
            -``sharing_secret``: A string representing the sharing secret for the subscriber
            and collection name
        """

        if user_id is not None and collection_name is not None and sharing_secret is not None:
            assert isinstance(user_id,str) or isinstance(user_id, unicode)
            assert isinstance(collection_name, str) or isinstance(collection_name, unicode)
            assert isinstance(sharing_secret, str) or isinstance(sharing_secret, unicode)

            cache_key = str(self.__create_cache_key(user_id, collection_name))
            sharing_secret = str(sharing_secret)

            cache.set(cache_key, sharing_secret, callback=callback)

    def get_subscriber_info(self, user_id, collection_name, callback):
        """
        Retrives the sharing secret associated with the user_id and
        collection_name from the cache.

        -Returns:
            -The sharing secret associated with this or None is passed to callback
        """

        if user_id is not None and collection_name is not None:
            assert isinstance(user_id,str) or isinstance(user_id, unicode)
            assert isinstance(collection_name, str) or isinstance(collection_name, unicode)

            cache_key = self.__create_cache_key(user_id, collection_name)
            cache.get(cache_key, callback=callback)

    def remove_subscriber_info(self, user_id, collection_name, callback):
        """
        Removes the sharing secret associate with the user_id and collection_name from
        the cache.

        """
        if user_id is not None and collection_name is not None:
            assert isinstance(user_id,str) or isinstance(user_id, unicode)
            assert isinstance(collection_name, str) or isinstance(collection_name, unicode)

            cache_key = self.__create_cache_key(user_id, collection_name)
            cache.delete(cache_key, callback=callback)

    def set_sharing_record(self, sharing_secret, sharing_record_json, callback):
        """
        Caches a sharing record keyed on the sharing secret.
        The sharing_record that is passed in should be in json
        """

        if sharing_secret is not None and sharing_record_json is not None:
            assert isinstance(sharing_secret, str) or isinstance(sharing_secret,unicode)
            assert isinstance(sharing_record_json, str) or isinstance(sharing_record_json, unicode)

            sharing_secret = str(sharing_secret)
            sharing_record_json = str(sharing_record_json)

            cache.set(sharing_secret, sharing_record_json, callback = callback)

    def get_sharing_record(self, sharing_secret, callback):
        """
        Retrives the sharing record for the sharing secret from cache.
        If a cache miss then None is passed to callback
        """

        if sharing_secret is not None:
            assert isinstance(sharing_secret, str) or isinstance(sharing_secret, unicode)

            sharing_secret = str(sharing_secret)
            cache.get(sharing_secret, callback=callback)

    def remove_sharing_record(self, sharing_secret, callback):
        """
        Removes the sharing record based on the sharing secret
        """
        assert isinstance(sharing_secret, str) or isinstance(sharing_secret, unicode)

        sharing_secret = str(sharing_secret)
        cache.delete(sharing_secret, callback=callback)







