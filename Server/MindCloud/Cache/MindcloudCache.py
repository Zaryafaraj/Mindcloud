from tornado import gen

__author__ = 'afathali'
import Properties.MindcloudProperties as properties
import tornadoasyncmemcache as memcache

cache = memcache.ClientPool(properties.Properties.memcached_servers,
                            properties.Properties.memcached_max_clients)

class MindcloudCache():

    def set_user_info(self, user_id, account_info_json, callback=None):
        """
        caches the user info .

        -Args:
            -``user_id``: The id of the user. This is the cache key
            -``account_info``: A json stucture consisting of (key, secret)
            for the user_id
        """

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

        cache.get(user_id, callback=callback)






