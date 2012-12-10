import json
import uuid
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Cache.MindcloudCache import MindcloudCache

__author__ = 'afathali'

class MindcloudCacheTests(AsyncTestCase):

    cache = MindcloudCache()

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_set_user_info(self):
        user_id = str(uuid.uuid4())
        user_key = str(uuid.uuid4())
        user_secret = str(uuid.uuid4())
        account_info = \
            json.dumps({'key':user_key, 'secret':user_secret})
        self.cache.set_user_info(user_id, account_info, callback=self.stop)
        self.wait()
        self.cache.get_user_info(user_id, callback=self.stop)
        account_json = self.wait()
        json_obj = json.loads(account_json)
        self.assertEqual(user_key, json_obj['key'])
        self.assertEqual(user_secret, json_obj['secret'])

    def test_get_user_info_non_existing(self):
        user_id = str(uuid.uuid4())
        self.cache.get_user_info(user_id, callback=self.stop)
        account_json = self.wait()
        self.assertTrue(account_json is None)

    def test_get_user_info(self):
        user_id = str(uuid.uuid4())
        user_key = str(uuid.uuid4())
        user_secret = str(uuid.uuid4())
        account_info =\
        json.dumps({'key':user_key, 'secret':user_secret})
        self.cache.set_user_info(user_id, account_info, callback=self.stop)
        self.wait()
        self.cache.get_user_info(user_id, callback=self.stop)
        account_json = self.wait()
        json_obj = json.loads(account_json)
        self.assertEqual(user_key, json_obj['key'])
        self.assertEqual(user_secret, json_obj['secret'])
        self.cache.get_user_info(user_id, callback=self.stop)
        account_json = self.wait()
        json_obj = json.loads(account_json)
        self.assertEqual(user_key, json_obj['key'])
        self.assertEqual(user_secret, json_obj['secret'])




