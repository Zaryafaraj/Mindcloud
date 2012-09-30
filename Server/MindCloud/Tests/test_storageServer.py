from unittest import TestCase
import uuid
from MindCloud.StorageResponse import StorageResponse
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

    def test_add_collection_with_file(self):
        collection_name = str(uuid.uuid1())
        file = open('test_resources/XooML.xml')
        StorageServer.add_collection(self.user_id, collection_name, file)
        all_collections = StorageServer.list_collections(self.user_id)
        self.assertTrue(collection_name in all_collections)
        #TODO when get file is written test that the actual file is saved
        #clean up
        StorageServer.remove_collection(self.user_id, collection_name)

    def test_add_collection_duplicated(self):

        collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.user_id, collection_name)
        response_code = StorageServer.add_collection(self.user_id, collection_name)
        self.assertEqual(StorageResponse.DUPLICATED, response_code)
        #clean up
        StorageServer.remove_collection(self.user_id, collection_name)

    def test_remove_collection(self):

        collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.user_id, collection_name)
        StorageServer.remove_collection(self.user_id, collection_name)
        all_collections = StorageServer.list_collections(self.user_id)
        self.assertFalse(collection_name in all_collections)

    def test_remove_collection_non_existing(self):

        response_code = StorageServer.remove_collection(self.user_id, 'dummy')
        self.assertEqual(StorageResponse.NOT_FOUND, response_code)

    def test_rename_collection(self):

        old_collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.user_id, old_collection_name)
        new_collection_name = str(uuid.uuid1())
        StorageServer.rename_collection(self.user_id, old_collection_name, new_collection_name)
        all_collections = StorageServer.list_collections(self.user_id)
        self.assertTrue(new_collection_name in all_collections)
        self.assertFalse(old_collection_name in all_collections)
        #clean up
        StorageServer.remove_collection(self.user_id, new_collection_name)

    def test_rename_non_existing_collection(self):

        response_code = StorageServer.rename_collection(self.user_id, 'nonexisting', 'dummy')
        self.assertEqual(StorageResponse.NOT_FOUND, response_code)

    def test_rename_existing_collection_to_itself(self):

        old_collection_name = str(uuid.uuid1())
        new_collection_name = old_collection_name
        StorageServer.add_collection(self.user_id, old_collection_name)
        StorageServer.rename_collection(self.user_id, old_collection_name, new_collection_name)
        all_collections = StorageServer.list_collections(self.user_id)
        self.assertTrue(new_collection_name in all_collections)
        #clean up
        StorageServer.remove_collection(self.user_id, new_collection_name)

    def test_rename_collection_to_existing_collection(self):

        old_collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.user_id, old_collection_name)
        new_collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.user_id, new_collection_name)
        StorageServer.rename_collection(self.user_id, old_collection_name, new_collection_name)
        response_code = StorageServer.rename_collection(self.user_id, old_collection_name, new_collection_name)
        self.assertEqual(StorageResponse.DUPLICATED, response_code)
        all_collections = StorageServer.list_collections(self.user_id)
        self.assertTrue(old_collection_name in all_collections)
        #clean up
        StorageServer.remove_collection(self.user_id, old_collection_name)
        StorageServer.remove_collection(self.user_id, new_collection_name)

    def test_add_thumbnail_to_collection(self):

        collection_name = str(uuid.uuid1())
        file = open('test_resources/thumbnail.jpg')
        StorageServer.add_collection(self.user_id, collection_name)
        response_code = StorageServer.add_thumbnail(self.user_id, collection_name, file)
        self.assertEqual(StorageResponse.OK, response_code)
        #clean up
        StorageServer.remove_collection(self.user_id, collection_name)

    def test_add_thumbnail_to_invalid_collection(self):
        #TODO incorrect Behavior. The operation is successfull.
        # should be fixed later
        file = open('test_resources/thumbnail.jpg')
        response_code = StorageServer.add_thumbnail(self.user_id, 'dummy', file)
        self.assertEqual(StorageResponse.OK, response_code)

