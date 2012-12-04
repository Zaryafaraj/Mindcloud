import uuid
import time
import cStringIO
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Sharing.SharingSpaceController import SharingSpaceController
from Sharing.UpdateSharedManifestAction import UpdateSharedManifestAction
from Sharing.UpdateSharedNoteAction import UpdateSharedNoteAction
from Sharing.UpdateSharedNoteImageAction import UpdateSharedNoteImageAction
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

    def __busy_wait(self, collection_name, iteration):
        for x in range(1, iteration):
            #just a dummy operation while results become eventually consistent
            #because we don't wait for the action to be performed we need this and
            #because everything is single threaded we need to keep the IOLoop running
            self.__get_collection_manifest_content(self.__account_id,
                collection_name)

    def __remove_collection(self, user_id, collection_name):

        StorageServer.remove_collection(user_id, collection_name,
            callback=self.stop)
        self.wait()

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

        self.__busy_wait(collection_name, 3)

        #verify
        manifest_body = self.__get_collection_manifest_content(self.__account_id,
            collection_name)
        self.assertEqual(expected_manifest_body, manifest_body)

        #cleanup
        self.__remove_collection(self.__account_id, collection_name)

    def __create_note(self, user_id, collection_name, note_name, note_file):

        StorageServer.add_note_to_collection(user_id,
            collection_name, note_name, note_file, callback = self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

    def __get_note_content(self, user_id, collection_name, note_name):
        StorageServer.get_note_from_collection(user_id,
            collection_name, note_name, callback=self.stop)
        response = self.wait()
        return response.read()

    def test_add_action_single_user_no_listener_update_note(self):
        sharing_space = SharingSpaceController()

        collection_name = 'col'
        self.__create_collection(self.__account_id, collection_name)
        note_name = 'note'
        note_file = open('../test_resources/note.xml')
        self.__create_note(self.__account_id, collection_name, note_name, note_file)

        note_file = open('../test_resources/sharing_note1.xml')
        expected_note_body = note_file.read()
        note_file_like = cStringIO.StringIO(expected_note_body)
        update_note_action = UpdateSharedNoteAction(self.__account_id, collection_name,
            note_name, note_file_like)
        sharing_space.add_action(update_note_action)

        self.__busy_wait(collection_name, 3)

        #verify
        note_content = self.__get_note_content(self.__account_id, collection_name,
            note_name)
        self.assertEqual(expected_note_body, note_content)

        #cleanup
        self.__remove_collection(self.__account_id, collection_name)

    def test_add_action_single_user_no_listener_create_note(self):

        sharing_space = SharingSpaceController()

        collection_name = 'col'
        self.__create_collection(self.__account_id, collection_name)


        note_name = 'dummyNote'
        note_file = open('../test_resources/sharing_note1.xml')
        expected_note_body = note_file.read()
        note_file_like = cStringIO.StringIO(expected_note_body)
        update_note_action = UpdateSharedNoteAction(self.__account_id, collection_name,
            note_name, note_file_like)
        sharing_space.add_action(update_note_action)

        self.__busy_wait(collection_name,3)

        #verify
        note_content = self.__get_note_content(self.__account_id, collection_name,
            note_name)
        self.assertEqual(expected_note_body, note_content)

        #cleanup
        self.__remove_collection(self.__account_id, collection_name)

    def __create_note_image(self, user_id, collection_name, note_name,
                            note_img):

        StorageServer.add_image_to_note(user_id, collection_name,
            note_name, note_img, callback= self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

    def __get_img_content(self, user_id, collection_name, note_name):
        StorageServer.get_note_image(user_id, collection_name,
            note_name, callback=self.stop)
        response = self.wait()
        self.assertTrue(response is not None)
        return response.read()


    def test_add_action_single_user_no_listener_update_note_image(self):
        sharing_space = SharingSpaceController()

        collection_name = 'col'
        self.__create_collection(self.__account_id, collection_name)
        note_name = 'note'
        note_file = open('../test_resources/note.xml')
        self.__create_note(self.__account_id, collection_name, note_name,
            note_file)
        note_img = open('../test_resources/note_img.jpg')
        expected_img_body = note_img.read()
        img_file_like = cStringIO.StringIO(expected_img_body)
        self.__create_note_image(self.__account_id, collection_name,
            note_name, img_file_like)

        sharing_note_img = open('../test_resources/sharing_note_img1.jpg')

        update_note_img_action = UpdateSharedNoteImageAction(self.__account_id,
            collection_name, note_name, sharing_note_img)
        sharing_space.add_action(update_note_img_action)

        #because we have an image busy wait more
        self.__busy_wait(collection_name, 5)

        #verify
        self.__get_img_content(self.__account_id,
            collection_name, note_name)
        #we can't really compare anything other than the operation is done
        #images get compressed and decompressed
        #self.assertEqual(len(expected_img_body), len(img_content))

        #cleanup
        self.__remove_collection(self.__account_id, collection_name)

    def test_add_action_single_user_no_listener_create_note_image(self):

        sharing_space = SharingSpaceController()

        collection_name = 'col'
        self.__create_collection(self.__account_id, collection_name)
        note_name = 'note'
        note_file = open('../test_resources/note.xml')
        self.__create_note(self.__account_id, collection_name, note_name,
            note_file)

        sharing_note_img = open('../test_resources/sharing_note_img1.jpg')

        update_note_img_action = UpdateSharedNoteImageAction(self.__account_id,
            collection_name, note_name, sharing_note_img)
        sharing_space.add_action(update_note_img_action)

        self.__busy_wait(collection_name, 5)

        #verify
        self.__get_img_content(self.__account_id,
            collection_name, note_name)

        #cleanup
        self.__remove_collection(self.__account_id, collection_name)

    def test_add_multiple_actions_two_users_no_listener(self):
        sharing_space = SharingSpaceController()
        collection_name1 = 'sharing_col1'
        collection_name2 = 'sharing_col2'
        self.__create_collection(self.__account_id, collection_name1)
        self.__create_collection(self.__subscriber_id, collection_name2)

        action_list = []
        sharing_template_file = open('../test_resources/sharing_template1.xml')
        sharing_template_str = sharing_template_file.read()
        manifest_str_list = MockFactory.get_list_of_different_strings(3,
            sharing_template_str)
        counter = 0
        for manifest_str in manifest_str_list:
            manifest_file1 = cStringIO.StringIO(manifest_str)
            manifest_file2 = cStringIO.StringIO(manifest_str)
            name = str(counter)
            counter += 1
            action1 = UpdateSharedManifestAction(self.__account_id,
                collection_name1, manifest_file1)
            action1.name = 'user1-manifest-' + name
            action2 = UpdateSharedManifestAction(self.__subscriber_id,
                collection_name2, manifest_file2)
            action2.name = 'user2-manifest-' + name
            action_list.append(action1)
            action_list.append(action2)

        #add some notes and images
        note_str_list = MockFactory.get_list_of_different_strings(3,
            sharing_template_str)
        file_name_counter = 0
        note_names = []
        for note_str in note_str_list :
            note_name = 'note' + str(file_name_counter)
            file_name_counter += 1
            note_names.append(note_name)
            file_obj1 = cStringIO.StringIO(note_str)
            file_obj2 = cStringIO.StringIO(note_str)
            action1 = UpdateSharedNoteAction(self.__account_id,
                collection_name1, note_name, file_obj1)
            action1.name = 'user1-update-note-' + note_name
            action2 = UpdateSharedNoteAction(self.__subscriber_id,
                collection_name2, note_name, file_obj2)
            action2.name = 'user2-update-note-' + note_name
            action_list.append(action1)
            action_list.append(action2)
            img_file1 = open('../test_resources/sharing_note_img1.jpg')
            img_file2 = open('../test_resources/sharing_note_img2.jpg')
            action3 = UpdateSharedNoteImageAction(self.__account_id,
            collection_name1, note_name, img_file1)
            action3.name = 'user1-update-img-' + note_name
            action4 = UpdateSharedNoteImageAction(self.__subscriber_id,
                collection_name2, note_name, img_file2)
            action4.name = 'user2-update-img-' + note_name
            action_list.append(action3)
            action_list.append(action4)

        for action in action_list:
            sharing_space.add_action(action)

        #busy wait for a long time
        self.__busy_wait(collection_name1, 30)

        #verify
        collection1_manifest_content = \
            self.__get_collection_manifest_content(self.__account_id,
                collection_name1)
        collection2_manifest_content = self.__get_collection_manifest_content(self.__subscriber_id,
            collection_name2)
        self.assertEquals(collection1_manifest_content, collection2_manifest_content)
        expected_content = manifest_str_list[-1]
        self.assertEquals(expected_content, collection1_manifest_content)

        #now verify the notes
        counter = 0
        for note_name in note_names:
            note_content1 = self.__get_note_content(self.__account_id,
                collection_name1, note_name)
            note_content2 = self.__get_note_content(self.__subscriber_id,
                collection_name2, note_name)
            self.assertEqual(note_content1, note_content2)
            expected_note_content = note_str_list[counter]
            counter += 1
            self.assertEqual(expected_note_content, note_content1)

    #cleanup




    def test_add_multiple_actions_two_users_no_listener_low_load(self):
        pass
    def test_add_multiple_actions_two_users_no_listener_medium_load(self):
        pass
    def test_add_multiple_actions_two_users_no_listener_heavy_load(self):
        pass

    #def test_backup_placement_strategy_backup_recorded(self):
    #    pass

    #def test_backup_placement_strategy_backup_empty(self):
    #    pass


