from unittest import TestCase
import uuid
from MindCloud.StorageServer import StorageServer

__author__ = 'afathali'


class TestStorageServer(TestCase):

    #Test user
    user_id = 'EC77E567-2924-4C9E-BECA-36D25EA76431'

    def test_list_collections(self):
        all_collections = StorageServer.list_collections(self.user_id)
        self.assertGreater(len(all_collections),0)

    def test_list_collections_with_invalid_user(self):

        all_collections = StorageServer.list_collections('dummy')
        self.assertEqual(0, len(all_collections))

    def test_add_collection(self):

        collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.user_id, collection_name)
        all_collections = StorageServer.list_collections(self.user_id)
        self.assertTrue(collection_name in all_collections)
        #clean up
        StorageServer.remove_collection(self.user_id, collection_name)

    def test_remove_collection(self):

        collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.user_id, collection_name)
        StorageServer.remove_collection(self.user_id, collection_name)
        all_collections = StorageServer.list_collections(self.user_id)
        self.assertFalse(collection_name in all_collections)

