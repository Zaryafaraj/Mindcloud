import uuid
import time
import cStringIO
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Sharing.SharingSpaceController import SharingSpaceController
from Sharing.UpdateSharedManifestAction import UpdateSharedManifestAction
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer
from Tests.TestingProperties import TestingProperties
from Tests.UnitTests.MockFactory import MockFactory

__author__ = 'afathali'


class SharingSpaceTestcase(AsyncTestCase):

    __account_id = TestingProperties.account_id
    __subscriber_id = TestingProperties.subscriber_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def __simple_response_callback(self, status_code, body):
        print '\n'.join(['Request finished', status_code, body])

    def test_add_listeners(self):
        sharing_space = SharingSpaceController()

        user_id1 = uuid.uuid4()
        user_id2 = uuid.uuid4()
        user_id3 = uuid.uuid4()

        request1 = MockFactory.get_mock_request(user_id1,
            callback= self.__simple_response_callback)

        #add one listener for one user
        sharing_space.add_listener(user_id1, request1)
        primary_listener_count = \
            sharing_space.get_number_of_primary_listeners()
        backup_listener_count = sharing_space.\
            get_number_of_backup_listeners()
        self.assertEqual(1, primary_listener_count)
        self.assertEqual(0,backup_listener_count)

        #add another listener for the smae user
        request2 = MockFactory.get_mock_request(user_id1,
            callback= self.__simple_response_callback)
        sharing_space.add_listener(user_id1, request2)
        primary_listener_count =\
        sharing_space.get_number_of_primary_listeners()
        backup_listener_count = sharing_space.\
        get_number_of_backup_listeners()
        self.assertEqual(1, primary_listener_count)
        self.assertEqual(1,backup_listener_count)

        #add an extra listener for the same user
        request3 = MockFactory.get_mock_request(user_id1,
            callback= self.__simple_response_callback)
        sharing_space.add_listener(user_id1, request3)
        primary_listener_count =\
        sharing_space.get_number_of_primary_listeners()
        backup_listener_count = sharing_space.\
        get_number_of_backup_listeners()
        self.assertEqual(1, primary_listener_count)
        self.assertEqual(1,backup_listener_count)

        #add a listener for another user
        request4 = MockFactory.get_mock_request(user_id2,
            callback= self.__simple_response_callback)
        sharing_space.add_listener(user_id2, request4)
        primary_listener_count =\
        sharing_space.get_number_of_primary_listeners()
        backup_listener_count = sharing_space.\
        get_number_of_backup_listeners()
        self.assertEqual(2, primary_listener_count)
        self.assertEqual(1,backup_listener_count)

        #add another listener for a third user
        request5 = MockFactory.get_mock_request(user_id3,
            callback= self.__simple_response_callback)
        sharing_space.add_listener(user_id3, request5)
        primary_listener_count =\
        sharing_space.get_number_of_primary_listeners()
        backup_listener_count = sharing_space.\
        get_number_of_backup_listeners()
        self.assertEqual(3, primary_listener_count)
        self.assertEqual(1,backup_listener_count)

        #add the backup listener for the third user
        request6 = MockFactory.get_mock_request(user_id3,
            callback= self.__simple_response_callback)
        sharing_space.add_listener(user_id3, request6)
        primary_listener_count =\
        sharing_space.get_number_of_primary_listeners()
        backup_listener_count = sharing_space.\
        get_number_of_backup_listeners()
        self.assertEqual(3, primary_listener_count)
        self.assertEqual(2,backup_listener_count)
        #add an extra request for the third user
        request7 = MockFactory.get_mock_request(user_id3,
            callback= self.__simple_response_callback)
        sharing_space.add_listener(user_id3, request7)
        primary_listener_count =\
        sharing_space.get_number_of_primary_listeners()
        backup_listener_count = sharing_space.\
        get_number_of_backup_listeners()
        self.assertEqual(3, primary_listener_count)
        self.assertEqual(2,backup_listener_count)

        #check the actual requests
        user_ids = sharing_space.get_all_primary_listener_ids()
        self.assertTrue(user_id1 in user_ids)
        self.assertTrue(user_id2 in user_ids)
        self.assertTrue(user_id3 in user_ids)
        backup_user_ids = sharing_space.get_all_backup_listener_ids()
        self.assertTrue(user_id1 in backup_user_ids)
        self.assertTrue(user_id3 in backup_user_ids)

        sharing_space.clear()



    def test_remove_listeners(self):
        sharing_space = SharingSpaceController()

        user_id1 = uuid.uuid4()
        user_id2 = uuid.uuid4()
        user_id3 = uuid.uuid4()

        request1 = MockFactory.get_mock_request(user_id1,
            callback= self.__simple_response_callback)
        sharing_space.add_listener(user_id1, request1)
        request2 = MockFactory.get_mock_request(user_id1,
            callback= self.__simple_response_callback)
        sharing_space.add_listener(user_id1, request2)
        request3 = MockFactory.get_mock_request(user_id1,
            callback= self.__simple_response_callback)
        sharing_space.add_listener(user_id1, request3)
        request4 = MockFactory.get_mock_request(user_id2,
            callback= self.__simple_response_callback)
        sharing_space.add_listener(user_id2, request4)
        request5 = MockFactory.get_mock_request(user_id3,
            callback= self.__simple_response_callback)
        sharing_space.add_listener(user_id3, request5)
        request6 = MockFactory.get_mock_request(user_id3,
            callback= self.__simple_response_callback)
        sharing_space.add_listener(user_id3, request6)
        request7 = MockFactory.get_mock_request(user_id3,
            callback= self.__simple_response_callback)
        sharing_space.add_listener(user_id3, request7)

        sharing_space.remove_listener(user_id1)
        backup_listener_count = sharing_space.\
        get_number_of_backup_listeners()
        primary_listener_count = sharing_space.\
        get_number_of_primary_listeners()
        all_primary_listeners = sharing_space.\
            get_all_primary_listener_ids()
        all_backup_listeners = sharing_space.\
            get_all_backup_listener_ids()

        self.assertEqual(2, primary_listener_count)
        self.assertEqual(1,backup_listener_count)
        self.assertTrue(user_id1 not in all_primary_listeners)
        self.assertTrue(user_id1 not in all_backup_listeners)

        sharing_space.remove_listener(user_id2)
        backup_listener_count = sharing_space.\
        get_number_of_backup_listeners()
        primary_listener_count = sharing_space.\
        get_number_of_primary_listeners()
        all_primary_listeners = sharing_space.\
        get_all_primary_listener_ids()
        all_backup_listeners = sharing_space.\
        get_all_backup_listener_ids()

        self.assertEqual(1, primary_listener_count)
        self.assertEqual(1,backup_listener_count)
        self.assertTrue(user_id2 not in all_primary_listeners)
        self.assertTrue(user_id2 not in all_backup_listeners)

        sharing_space.remove_listener(user_id3)
        backup_listener_count = sharing_space.\
        get_number_of_backup_listeners()
        primary_listener_count = sharing_space.\
        get_number_of_primary_listeners()
        all_primary_listeners = sharing_space.\
        get_all_primary_listener_ids()
        all_backup_listeners = sharing_space.\
        get_all_backup_listener_ids()

        self.assertEqual(0, primary_listener_count)
        self.assertEqual(0,backup_listener_count)
        self.assertTrue(user_id3 not in all_primary_listeners)
        self.assertTrue(user_id3 not in all_backup_listeners)

        #try to remove again
        sharing_space.remove_listener(user_id3)
        backup_listener_count = sharing_space.\
        get_number_of_backup_listeners()
        primary_listener_count = sharing_space.\
        get_number_of_primary_listeners()
        all_primary_listeners = sharing_space.\
        get_all_primary_listener_ids()
        all_backup_listeners = sharing_space.\
        get_all_backup_listener_ids()

        self.assertEqual(0, primary_listener_count)
        self.assertEqual(0,backup_listener_count)
        self.assertTrue(user_id3 not in all_primary_listeners)
        self.assertTrue(user_id3 not in all_backup_listeners)

        sharing_space.clear()

    def test_remove_non_existing_listener(self):
        sharing_space = SharingSpaceController()

        sharing_space.remove_listener('dummy_user')
        backup_listeners = sharing_space.get_number_of_backup_listeners()
        primary_listeners = sharing_space.get_number_of_primary_listeners()
        self.assertEqual(0, primary_listeners)
        self.assertEqual(0,backup_listeners)

        sharing_space.clear()

    def __create_collection(self, account_id, collection_name):

        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id= account_id,
            collection_name=collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)


    def __get_collection_manifest_content(self, account_id, collection_name):
        StorageServer.get_collection_manifest(account_id,
            collection_name, callback=self.stop)
        response = self.wait()
        return response.read()

    def test_add_action_single_user_no_listener_update_manifest(self):
        sharing_space = SharingSpaceController()

        collection_name = 'col1'
        self.__create_collection(self.__account_id, collection_name)


        manifest_file = open('../test_resources/sharing_manifest1.xml')
        expected_manifest_body = manifest_file.read()
        manifest_file_like = cStringIO.StringIO(expected_manifest_body)
        update_manifest_action = UpdateSharedManifestAction(self.__account_id,
            collection_name, manifest_file_like)
        sharing_space.add_action(update_manifest_action)

        #just a dummy operation while results become eventually consistent
        manifest_body = self.__get_collection_manifest_content(self.__account_id,
            collection_name)

        #the actual operation
        manifest_body = self.__get_collection_manifest_content(self.__account_id,
            collection_name)
        self.assertEqual(expected_manifest_body, manifest_body)




        pass
    def test_add_action_single_user_no_listener_update_note(self):
        pass
    def test_add_action_single_user_no_listener_create_note(self):
        pass
    def test_add_action_single_user_no_listener_update_note_image(self):
        pass
    def test_add_action_single_user_no_listener_create_note_image(self):
        pass

    #def test_backup_placement_strategy_backup_recorded(self):
    #    pass

    #def test_backup_placement_strategy_backup_empty(self):
    #    pass


