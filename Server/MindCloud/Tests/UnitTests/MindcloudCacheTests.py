import json
import uuid
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Cache.MindcloudCache import MindcloudCache
from Sharing.SharingRecord import SharingRecord

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

    def test_set_subscriber_info(self):
        user_id = str(uuid.uuid4())
        collection_name = 'name'
        sharing_secret = str(uuid.uuid4())
        self.cache.set_subscriber_info(user_id, collection_name, sharing_secret,
            callback=self.stop)
        self.wait()
        self.cache.get_subscriber_info(user_id, collection_name,
            callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertEqual(sharing_secret, actual_sharing_secret)

    def test_get_subscriber_info(self):
        user_id = str(uuid.uuid4())
        collection_name = 'name'
        sharing_secret = str(uuid.uuid4())
        self.cache.set_subscriber_info(user_id, collection_name, sharing_secret,
            callback=self.stop)
        self.wait()
        self.cache.get_subscriber_info(user_id, collection_name,
            callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertEqual(sharing_secret, actual_sharing_secret)
        self.cache.get_subscriber_info(user_id, collection_name,
            callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertEqual(sharing_secret, actual_sharing_secret)
        new_sharing_secret = 'new secret'
        self.cache.set_subscriber_info(user_id, collection_name, new_sharing_secret,
            callback=self.stop)
        self.wait()
        self.cache.get_subscriber_info(user_id, collection_name,
            callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertEqual(new_sharing_secret, actual_sharing_secret)

    def test_get_subscriber_info_non_existing(self):

        self.cache.get_subscriber_info('dummy', 'dummy2',
            callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertTrue(actual_sharing_secret is None)

    def test_remove_subscriber(self):

        user_id = str(uuid.uuid4())
        collection_name = 'name'
        sharing_secret = str(uuid.uuid4())
        self.cache.set_subscriber_info(user_id, collection_name, sharing_secret,
            callback=self.stop)
        self.wait()
        self.cache.remove_subscriber_info(user_id, collection_name,
            callback =self.stop)
        self.wait()
        self.cache.get_subscriber_info(user_id, collection_name,
            callback=self.stop)
        actual_sharing_secret = self.wait()
        self.assertTrue(actual_sharing_secret is None)

    def test_set_sharing_record(self):

        sharing_secret = str(uuid.uuid4())
        sharing_record = SharingRecord(sharing_secret, 'owner',
            'collections', ['a', 'b'])
        sharing_record_json = json.dumps(sharing_record.toDictionary())
        self.cache.set_sharing_record(sharing_secret, sharing_record_json,
            callback=self.stop)
        self.wait()
        self.cache.get_sharing_record(sharing_secret, callback=self.stop)
        actual_sharing_record_str = self.wait()
        actual_sharing_record = SharingRecord.fromJson(actual_sharing_record_str)
        self.assertEqual(sharing_secret,
            actual_sharing_record.get_sharing_secret())

    def test_get_sharing_record(self):

        sharing_secret = str(uuid.uuid4())
        sharing_record = SharingRecord(sharing_secret, 'owner',
            'collections', ['a', 'b'])
        sharing_record_json = json.dumps(sharing_record.toDictionary())
        self.cache.set_sharing_record(sharing_secret, sharing_record_json,
            callback=self.stop)
        self.wait()
        self.cache.get_sharing_record(sharing_secret, callback=self.stop)
        actual_sharing_record_str = self.wait()
        actual_sharing_record = SharingRecord.fromJson(actual_sharing_record_str)
        self.assertEqual(sharing_secret,
            actual_sharing_record.get_sharing_secret())
        self.cache.get_sharing_record(sharing_secret, callback=self.stop)
        actual_sharing_record_str = self.wait()
        actual_sharing_record = SharingRecord.fromJson(actual_sharing_record_str)
        self.assertEqual(sharing_secret,
            actual_sharing_record.get_sharing_secret())

    def test_get_sharing_record_non_existing(self):
        self.cache.get_sharing_record('dummy1', callback=self.stop)
        actual_sharing_record_str = self.wait()
        self.assertTrue(actual_sharing_record_str is None)

    def test_remove_sharing_record(self):

        sharing_secret = str(uuid.uuid4())
        sharing_record = SharingRecord(sharing_secret, 'owner',
            'collections', ['a', 'b'])
        sharing_record_json = json.dumps(sharing_record.toDictionary())
        self.cache.set_sharing_record(sharing_secret, sharing_record_json,
            callback=self.stop)
        self.wait()
        self.cache.remove_sharing_record(sharing_record.sharing_secret,
            callback=self.stop)
        self.wait()

        self.cache.get_sharing_record(sharing_secret, callback=self.stop)
        actual_sharing_record_str = self.wait()
        self.assertTrue(actual_sharing_record_str is None)

