import json
from random import Random
import uuid
import time
import cStringIO
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Sharing.DeleteSharedNoteAction import DeleteSharedNoteAction
from Sharing.SharingEvent import SharingEvent
from Sharing.SharingSpaceController import SharingSpaceController
from Sharing.UpdateSharedManifestAction import UpdateSharedManifestAction
from Sharing.UpdateSharedNoteAction import UpdateSharedNoteAction
from Sharing.UpdateSharedNoteImageAction import UpdateSharedNoteImageAction
from Sharing.UpdateSharedThumbnailAction import UpdateSharedThumbnailAction
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer
from Tests.TestingProperties import TestingProperties
from Tests.UnitTests.MockFactory import MockFactory

__author__ = 'afathali'


class SharingSpaceTestcase(AsyncTestCase):
    __account_id = TestingProperties.account_id
    __subscriber_id = TestingProperties.subscriber_id
    __second_subscriber_id = TestingProperties.second_subscriber_id
    __simple_callback_flag = False
    __simple_backup_callback_flag = False
    __primary_listeners_returned = 0
    __backup_listeners_returned = 0

    def get_new_ioloop(self):
        return IOLoop.instance()

    def __simple_response_callback(self, status_code, body):
        if body is None:
            body = ' '
        print '\n'.join(['Request finished', str(status_code), body])

    def test_add_listeners(self):
        sharing_space = SharingSpaceController()

        user_id1 = uuid.uuid4()
        user_id2 = uuid.uuid4()
        user_id3 = uuid.uuid4()

        request1 = MockFactory.get_mock_request(user_id1,
                                                callback=self.__simple_response_callback)

        #add one listener for one user
        sharing_space.add_listener(user_id1, request1)
        primary_listener_count = \
            sharing_space.get_number_of_primary_listeners()
        backup_listener_count = sharing_space. \
            get_number_of_backup_listeners()
        self.assertEqual(1, primary_listener_count)
        self.assertEqual(0, backup_listener_count)

        #add another listener for the smae user
        request2 = MockFactory.get_mock_request(user_id1,
                                                callback=self.__simple_response_callback)
        sharing_space.add_listener(user_id1, request2)
        primary_listener_count = \
            sharing_space.get_number_of_primary_listeners()
        backup_listener_count = sharing_space. \
            get_number_of_backup_listeners()
        self.assertEqual(1, primary_listener_count)
        self.assertEqual(1, backup_listener_count)

        #add an extra listener for the same user
        request3 = MockFactory.get_mock_request(user_id1,
                                                callback=self.__simple_response_callback)
        sharing_space.add_listener(user_id1, request3)
        primary_listener_count = \
            sharing_space.get_number_of_primary_listeners()
        backup_listener_count = sharing_space. \
            get_number_of_backup_listeners()
        self.assertEqual(1, primary_listener_count)
        self.assertEqual(1, backup_listener_count)

        #add a listener for another user
        request4 = MockFactory.get_mock_request(user_id2,
                                                callback=self.__simple_response_callback)
        sharing_space.add_listener(user_id2, request4)
        primary_listener_count = \
            sharing_space.get_number_of_primary_listeners()
        backup_listener_count = sharing_space. \
            get_number_of_backup_listeners()
        self.assertEqual(2, primary_listener_count)
        self.assertEqual(1, backup_listener_count)

        #add another listener for a third user
        request5 = MockFactory.get_mock_request(user_id3,
                                                callback=self.__simple_response_callback)
        sharing_space.add_listener(user_id3, request5)
        primary_listener_count = \
            sharing_space.get_number_of_primary_listeners()
        backup_listener_count = sharing_space. \
            get_number_of_backup_listeners()
        self.assertEqual(3, primary_listener_count)
        self.assertEqual(1, backup_listener_count)

        #add the backup listener for the third user
        request6 = MockFactory.get_mock_request(user_id3,
                                                callback=self.__simple_response_callback)
        sharing_space.add_listener(user_id3, request6)
        primary_listener_count = \
            sharing_space.get_number_of_primary_listeners()
        backup_listener_count = sharing_space. \
            get_number_of_backup_listeners()
        self.assertEqual(3, primary_listener_count)
        self.assertEqual(2, backup_listener_count)
        #add an extra request for the third user
        request7 = MockFactory.get_mock_request(user_id3,
                                                callback=self.__simple_response_callback)
        sharing_space.add_listener(user_id3, request7)
        primary_listener_count = \
            sharing_space.get_number_of_primary_listeners()
        backup_listener_count = sharing_space. \
            get_number_of_backup_listeners()
        self.assertEqual(3, primary_listener_count)
        self.assertEqual(2, backup_listener_count)

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
                                                callback=self.__simple_response_callback)
        sharing_space.add_listener(user_id1, request1)
        request2 = MockFactory.get_mock_request(user_id1,
                                                callback=self.__simple_response_callback)
        sharing_space.add_listener(user_id1, request2)
        request3 = MockFactory.get_mock_request(user_id1,
                                                callback=self.__simple_response_callback)
        sharing_space.add_listener(user_id1, request3)
        request4 = MockFactory.get_mock_request(user_id2,
                                                callback=self.__simple_response_callback)
        sharing_space.add_listener(user_id2, request4)
        request5 = MockFactory.get_mock_request(user_id3,
                                                callback=self.__simple_response_callback)
        sharing_space.add_listener(user_id3, request5)
        request6 = MockFactory.get_mock_request(user_id3,
                                                callback=self.__simple_response_callback)
        sharing_space.add_listener(user_id3, request6)
        request7 = MockFactory.get_mock_request(user_id3,
                                                callback=self.__simple_response_callback)
        sharing_space.add_listener(user_id3, request7)

        sharing_space.remove_listener(user_id1)
        backup_listener_count = sharing_space. \
            get_number_of_backup_listeners()
        primary_listener_count = sharing_space. \
            get_number_of_primary_listeners()
        all_primary_listeners = sharing_space. \
            get_all_primary_listener_ids()
        all_backup_listeners = sharing_space. \
            get_all_backup_listener_ids()

        self.assertEqual(2, primary_listener_count)
        self.assertEqual(1, backup_listener_count)
        self.assertTrue(user_id1 not in all_primary_listeners)
        self.assertTrue(user_id1 not in all_backup_listeners)

        sharing_space.remove_listener(user_id2)
        backup_listener_count = sharing_space. \
            get_number_of_backup_listeners()
        primary_listener_count = sharing_space. \
            get_number_of_primary_listeners()
        all_primary_listeners = sharing_space. \
            get_all_primary_listener_ids()
        all_backup_listeners = sharing_space. \
            get_all_backup_listener_ids()

        self.assertEqual(1, primary_listener_count)
        self.assertEqual(1, backup_listener_count)
        self.assertTrue(user_id2 not in all_primary_listeners)
        self.assertTrue(user_id2 not in all_backup_listeners)

        sharing_space.remove_listener(user_id3)
        backup_listener_count = sharing_space. \
            get_number_of_backup_listeners()
        primary_listener_count = sharing_space. \
            get_number_of_primary_listeners()
        all_primary_listeners = sharing_space. \
            get_all_primary_listener_ids()
        all_backup_listeners = sharing_space. \
            get_all_backup_listener_ids()

        self.assertEqual(0, primary_listener_count)
        self.assertEqual(0, backup_listener_count)
        self.assertTrue(user_id3 not in all_primary_listeners)
        self.assertTrue(user_id3 not in all_backup_listeners)

        #try to remove again
        sharing_space.remove_listener(user_id3)
        backup_listener_count = sharing_space. \
            get_number_of_backup_listeners()
        primary_listener_count = sharing_space. \
            get_number_of_primary_listeners()
        all_primary_listeners = sharing_space. \
            get_all_primary_listener_ids()
        all_backup_listeners = sharing_space. \
            get_all_backup_listener_ids()

        self.assertEqual(0, primary_listener_count)
        self.assertEqual(0, backup_listener_count)
        self.assertTrue(user_id3 not in all_primary_listeners)
        self.assertTrue(user_id3 not in all_backup_listeners)

        sharing_space.clear()

    def test_remove_non_existing_listener(self):
        sharing_space = SharingSpaceController()

        sharing_space.remove_listener('dummy_user')
        backup_listeners = sharing_space.get_number_of_backup_listeners()
        primary_listeners = sharing_space.get_number_of_primary_listeners()
        self.assertEqual(0, primary_listeners)
        self.assertEqual(0, backup_listeners)

        sharing_space.clear()

    def __create_collection(self, account_id, collection_name):

        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=account_id,
                                     collection_name=collection_name, callback=self.stop, file=file)
        response = self.wait(timeout=100)
        self.assertEqual(StorageResponse.OK, response)


    def __get_collection_manifest_content(self, account_id, collection_name):
        StorageServer.get_collection_manifest(account_id,
                                              collection_name, callback=self.stop)
        response = self.wait(timeout=100)
        if response is None:
            print 'GOT NONE; retrying'
            try:
                self.wait(timeout=10)
            except Exception:
                pass
            StorageServer.get_collection_manifest(account_id,
                                                  collection_name, callback=self.stop)
            response = self.wait(timeout=100)
            if response is None:
                print 'Still None, failing'
                return None
            else:
                return response.read()
        else:
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
        response = self.wait(timeout=100)

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

        self.__busy_wait(collection_name, 5)

        #verify
        manifest_body = self.__get_collection_manifest_content(self.__account_id,
                                                               collection_name)
        self.assertEqual(expected_manifest_body, manifest_body)

        #cleanup
        self.__remove_collection(self.__account_id, collection_name)

    def __create_note(self, user_id, collection_name, note_name, note_file):

        StorageServer.add_note_to_collection(user_id,
                                             collection_name, note_name, note_file, callback=self.stop)
        response = self.wait(timeout=100)
        self.assertEqual(StorageResponse.OK, response)

    def __get_note_content(self, user_id, collection_name, note_name):
        print 'getting note ' + note_name
        StorageServer.get_note_from_collection(user_id,
                                               collection_name, note_name, callback=self.stop)
        response = self.wait(timeout=100)
        if response is None:
            print 'GOT NONE; retrying'
            try:
                self.wait(timeout=15)
            except Exception:
                StorageServer.get_note_from_collection(user_id,
                                                       collection_name, note_name, callback=self.stop)
                response = self.wait(timeout=100)
                if response is None:
                    print 'still none; failing'
                    return None
                else:
                    return response.read()
        else:
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

        self.__busy_wait(collection_name, 5)

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

        self.__busy_wait(collection_name, 5)

        #verify
        note_content = self.__get_note_content(self.__account_id, collection_name,
                                               note_name)
        self.assertEqual(expected_note_body, note_content)

        #cleanup
        self.__remove_collection(self.__account_id, collection_name)

    def __create_note_image(self, user_id, collection_name, note_name,
                            note_img):

        StorageServer.add_image_to_note(user_id, collection_name,
                                        note_name, note_img, callback=self.stop)
        response = self.wait(timeout=100)
        self.assertEqual(StorageResponse.OK, response)

    def __get_img_content(self, user_id, collection_name, note_name):
        StorageServer.get_note_image(user_id, collection_name,
                                     note_name, callback=self.stop)
        response = self.wait(timeout=100)
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
        self.__busy_wait(collection_name, 7)

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

        self.__busy_wait(collection_name, 7)

        #verify
        self.__get_img_content(self.__account_id,
                               collection_name, note_name)

        #cleanup
        self.__remove_collection(self.__account_id, collection_name)

    def test_add_action_single_user_no_listener_create_thumbnail(self):

        sharing_space = SharingSpaceController()

        collection_name = 'col1'
        self.__create_collection(self.__account_id, collection_name)

        thumbnail_file = open('../test_resources/sharing_note_img1.jpg')
        update_thumbnail_action = UpdateSharedThumbnailAction(self.__account_id,
                                                              collection_name, thumbnail_file)
        sharing_space.add_action(update_thumbnail_action)

        self.__busy_wait(collection_name, 5)

        #verify
        StorageServer.get_thumbnail(self.__account_id, collection_name, callback=self.stop)
        thumbnail_response = self.wait()
        self.assertTrue(thumbnail_response)

        #cleanup
        self.__remove_collection(self.__account_id, collection_name)

    def test_add_action_single_user_no_listener_update_thumbnail(self):

        sharing_space = SharingSpaceController()

        collection_name = 'col1'
        self.__create_collection(self.__account_id, collection_name)

        thumbnail_file = open('../test_resources/sharing_note_img1.jpg')
        StorageServer.add_thumbnail(self.__account_id, collection_name,
                                    thumbnail_file, callback=self.stop)
        response = self.wait()
        self.assertTrue(StorageResponse.OK, response)

        thumbnail_file = open('../test_resources/sharing_note_img2.jpg')
        update_thumbnail_action = UpdateSharedThumbnailAction(self.__account_id,
                                                              collection_name, thumbnail_file)
        sharing_space.add_action(update_thumbnail_action)

        self.__busy_wait(collection_name, 5)

        #verify
        StorageServer.get_thumbnail(self.__account_id, collection_name, callback=self.stop)
        thumbnail_response = self.wait()
        self.assertTrue(thumbnail_response)

        #cleanup
        self.__remove_collection(self.__account_id, collection_name)

    def test_add_action_single_user_no_listener_delete_note(self):
        sharing_space = SharingSpaceController()

        collection_name = 'col'
        self.__create_collection(self.__account_id, collection_name)
        note_name = 'del_note'
        note_file = open('../test_resources/note.xml')
        self.__create_note(self.__account_id, collection_name, note_name, note_file)

        delete_note_action = DeleteSharedNoteAction(self.__account_id,
                                                    collection_name, note_name)
        sharing_space.add_action(delete_note_action)

        self.__busy_wait(collection_name, 5)
        #verify
        StorageServer.get_note_from_collection(self.__account_id,
                                               collection_name, note_name, callback=self.stop)
        response = self.wait()
        self.assertTrue(response is None)

        #clear
        self.__remove_collection(self.__account_id, collection_name)

    def test_add_action_single_user_no_listener_delete_non_existing_note(self):

        sharing_space = SharingSpaceController()

        collection_name = 'col'
        self.__create_collection(self.__account_id, collection_name)
        note_name = 'del_note'
        note_file = open('../test_resources/note.xml')
        self.__create_note(self.__account_id, collection_name, note_name, note_file)

        delete_note_action = DeleteSharedNoteAction(self.__account_id,
                                                    collection_name, note_name)
        delete_note_action.name = 'first'
        sharing_space.add_action(delete_note_action)

        #we expect nothing happening here
        delete_note_action = DeleteSharedNoteAction(self.__account_id,
                                                    collection_name, note_name)
        delete_note_action.name = 'second'
        sharing_space.add_action(delete_note_action)

        self.__busy_wait(collection_name, 5)

        #verify
        StorageServer.get_note_from_collection(self.__account_id,
                                               collection_name, note_name, callback=self.stop)
        response = self.wait()
        self.assertTrue(response is None)

        #clear
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
        for note_str in note_str_list:
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
        self.__busy_wait(collection_name1, 100)

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
        self.__remove_collection(self.__account_id, collection_name1)
        self.__remove_collection(self.__subscriber_id, collection_name2)

    def __load_test(self, manifest_count, note_count, busy_wait_cycle, acceptable_invalids):

        sharing_space = SharingSpaceController()
        collection_name1 = 'sharing_col1'
        collection_name2 = 'sharing_col2'
        self.__create_collection(self.__account_id, collection_name1)
        self.__create_collection(self.__subscriber_id, collection_name2)

        action_list = []
        sharing_template_file = open('../test_resources/sharing_template1.xml')
        sharing_template_str = sharing_template_file.read()
        manifest_str_list = MockFactory.get_list_of_different_strings(manifest_count,
                                                                      sharing_template_str)
        counter = 0
        last_manifest = None

        for x in range(manifest_count):
            for manifest_str in manifest_str_list:
                last_manifest = manifest_str + str(x)
                manifest_file1 = cStringIO.StringIO(last_manifest)
                manifest_file2 = cStringIO.StringIO(last_manifest)
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
        note_str_list = MockFactory.get_list_of_different_strings(note_count,
                                                                  sharing_template_str)
        file_name_counter = 0
        note_names = []
        for note_str in note_str_list:
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
            img_file1 = open('../test_resources/sharing_note_img1.jpg', 'rb')
            img_file_like1 = cStringIO.StringIO(img_file1.read())
            img_file2 = open('../test_resources/sharing_note_img2.jpg', 'rb')
            img_file_like2 = cStringIO.StringIO(img_file2.read())
            action3 = UpdateSharedNoteImageAction(self.__account_id,
                                                  collection_name1, note_name, img_file_like1)
            action3.name = 'user1-update-img-' + note_name
            action4 = UpdateSharedNoteImageAction(self.__subscriber_id,
                                                  collection_name2, note_name, img_file_like2)
            action4.name = 'user2-update-img-' + note_name
            action_list.append(action3)
            action_list.append(action4)

        for action in action_list:
            sharing_space.add_action(action)

        #busy wait for a long time
        self.__busy_wait(collection_name1, busy_wait_cycle)

        #verify
        collection1_manifest_content = \
            self.__get_collection_manifest_content(self.__account_id,
                                                   collection_name1)
        collection2_manifest_content = self.__get_collection_manifest_content(self.__subscriber_id,
                                                                              collection_name2)
        self.assertEquals(collection1_manifest_content, collection2_manifest_content)
        self.assertEquals(last_manifest, collection1_manifest_content)

        #now verify the notes
        counter = 0
        for note_name in note_names:
            note_content1 = self.__get_note_content(self.__account_id,
                                                    collection_name1, note_name)
            note_content2 = self.__get_note_content(self.__subscriber_id,
                                                    collection_name2, note_name)
            expected_note_content = note_str_list[counter]
            if note_content1 != note_content2 or \
                            expected_note_content != note_content1:
                acceptable_invalids -= 1
            if acceptable_invalids < 0:
                self.fail("invalid results more than acceptable threshold")
            counter += 1

        print 'acceptable invalids left: ' + str(acceptable_invalids)
        #cleanup
        self.__remove_collection(self.__account_id, collection_name1)
        self.__remove_collection(self.__subscriber_id, collection_name2)

    def test_add_multiple_actions_two_users_no_listener_low_load(self):
        self.__load_test(5, 10, 100, 0)

    #def test_add_multiple_actions_two_users_no_listener_medium_load(self):
    #    self.__load_test(20,50, 200, 0)

    #def test_add_multiple_actions_two_users_no_listener_heavy_load(self):
    #    self.__load_test(50,100, 400, 10)

    def test_primary_listener_notified_update_manifest(self):

        sharing_space = SharingSpaceController()
        collection_name1 = 'col_listener1'
        collection_name2 = 'col_listener2'
        self.__create_collection(self.__account_id, collection_name1)
        self.__create_collection(self.__subscriber_id, collection_name2)

        note_name1 = 'note_listener1'
        note_name2 = 'note_listener2'
        note_file1 = open('../test_resources/note.xml')
        note_file2 = open('../test_resources/note.xml')
        self.__create_note(self.__account_id, collection_name1, note_name1,
                           note_file1)
        self.__create_note(self.__subscriber_id, collection_name2, note_name2,
                           note_file2)

        #owner listens both on primary and backup port
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        owner_mock_request2 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        sharing_space.add_listener(self.__account_id, owner_mock_request1)
        sharing_space.add_listener(self.__account_id, owner_mock_request2)

        #subscriber sends an action
        new_manifest_file = open('../test_resources/sharing_manifest1.xml')
        expected_note_body = new_manifest_file.read()
        manifest_file_like = cStringIO.StringIO(expected_note_body)
        update_manifest_action = UpdateSharedManifestAction(self.__subscriber_id,
                                                            collection_name2, manifest_file_like)
        sharing_space.add_action(update_manifest_action)
        action_type = update_manifest_action.get_action_type()

        #check to see if the primary listener has been notified
        #busy wait three times and then give up
        success = self.__simple_callback_flag
        if not success:
            for count in range(2):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_callback_flag:
                            success = True

        self.assertTrue(success)
        self.assertTrue(action_type in self.__primary_listener_notification_action)

    def test_primary_listener_notified_update_note(self):

        sharing_space = SharingSpaceController()
        collection_name1 = 'col_listener1'
        collection_name2 = 'col_listener2'
        self.__create_collection(self.__account_id, collection_name1)
        self.__create_collection(self.__subscriber_id, collection_name2)

        note_name1 = 'note_listener1'
        note_name2 = 'note_listener2'
        note_file1 = open('../test_resources/note.xml')
        note_file2 = open('../test_resources/note.xml')
        self.__create_note(self.__account_id, collection_name1, note_name1,
                           note_file1)
        self.__create_note(self.__subscriber_id, collection_name2, note_name2,
                           note_file2)

        #owner listens both on primary and backup port
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        owner_mock_request2 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        sharing_space.add_listener(self.__account_id, owner_mock_request1)
        sharing_space.add_listener(self.__account_id, owner_mock_request2)

        #subscriber sends an action
        new_note_file = open('../test_resources/sharing_note1.xml')
        new_note_name = 'new_note_name'
        expected_note_body = new_note_file.read()
        note_file_like = cStringIO.StringIO(expected_note_body)
        update_note_action = UpdateSharedNoteAction(self.__subscriber_id, collection_name2,
                                                    new_note_name, note_file_like)
        sharing_space.add_action(update_note_action)
        action_type = update_note_action.get_action_type()

        #check to see if the primary listener has been notified
        #busy wait three times and then give up
        success = self.__simple_callback_flag
        if not success:
            for count in range(2):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_callback_flag:
                            success = True

        self.assertTrue(success)
        self.assertTrue(action_type in self.__primary_listener_notification_action)

    def test_primary_listener_notified_update_note_img(self):

        sharing_space = SharingSpaceController()
        collection_name1 = 'col_listener1'
        collection_name2 = 'col_listener2'
        self.__create_collection(self.__account_id, collection_name1)
        self.__create_collection(self.__subscriber_id, collection_name2)

        note_name1 = 'note_listener1'
        note_name2 = 'note_listener2'
        note_file1 = open('../test_resources/note.xml')
        note_file2 = open('../test_resources/note.xml')
        self.__create_note(self.__account_id, collection_name1, note_name1,
                           note_file1)
        self.__create_note(self.__subscriber_id, collection_name2, note_name2,
                           note_file2)

        #owner listens both on primary and backup port
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        owner_mock_request2 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        sharing_space.add_listener(self.__account_id, owner_mock_request1)
        sharing_space.add_listener(self.__account_id, owner_mock_request2)

        #subscriber sends an action
        new_note_img = open('../test_resources/workfile.jpg')
        expected_note_body = new_note_img.read()
        img_file_like = cStringIO.StringIO(expected_note_body)
        new_note_name = 'new_note'
        update_img_action = UpdateSharedNoteImageAction(self.__subscriber_id,
                                                        collection_name2, new_note_name, img_file_like)
        sharing_space.add_action(update_img_action)
        action_type = update_img_action.get_action_type()

        #check to see if the primary listener has been notified
        #busy wait three times and then give up
        success = self.__simple_callback_flag
        if not success:
            for count in range(2):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_callback_flag:
                            success = True

        self.assertTrue(success)
        self.assertTrue(action_type in self.__primary_listener_notification_action)

        action_details = self.__primary_listener_notification_action[action_type]
        assert (new_note_name in action_details)

        img_secret = str(action_details[new_note_name])
        sharing_space.get_temp_img(img_secret, self.__account_id, collection_name1,
                                   new_note_name, callback=self.stop)
        img = self.wait()

        self.assertTrue(img is not None)

    def test_primary_listener_notified_update_thumbnail(self):

        sharing_space = SharingSpaceController()
        collection_name1 = 'col_listener1'
        collection_name2 = 'col_listener2'
        self.__create_collection(self.__account_id, collection_name1)
        self.__create_collection(self.__subscriber_id, collection_name2)

        #owner listens both on primary and backup port
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        owner_mock_request2 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        sharing_space.add_listener(self.__account_id, owner_mock_request1)
        sharing_space.add_listener(self.__account_id, owner_mock_request2)


        #subscriber sends an action
        thumbnail_file = open('../test_resources/workfile.jpg')
        update_thumbnail_action = UpdateSharedThumbnailAction(self.__subscriber_id,
                                                              collection_name2, thumbnail_file)
        update_thumbnail_action.name = 'thumbnail'
        sharing_space.add_action(update_thumbnail_action)
        action_type = update_thumbnail_action.get_action_type()

        #check to see if the primary listener has been notified
        #busy wait three times and then give up
        success = self.__simple_callback_flag
        if not success:
            for count in range(2):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_callback_flag:
                            success = True

        self.assertTrue(success)
        self.assertTrue(action_type in self.__primary_listener_notification_action)

        secret = str(self.__primary_listener_notification_action[action_type])
        sharing_space.get_temp_img(secret, self.__account_id,
                                   collection_name1, note_name=None, callback=self.stop)
        img = self.wait()

        self.assertTrue(img is not None)

    def test_primary_listener_notified_delete_note(self):

        sharing_space = SharingSpaceController()
        collection_name1 = 'col_listener1'
        collection_name2 = 'col_listener2'
        self.__create_collection(self.__account_id, collection_name1)
        self.__create_collection(self.__subscriber_id, collection_name2)

        note_name1 = 'note_listener1'
        note_name2 = 'note_listener2'
        note_file1 = open('../test_resources/note.xml')
        note_file2 = open('../test_resources/note.xml')
        self.__create_note(self.__account_id, collection_name1, note_name1,
                           note_file1)
        self.__create_note(self.__subscriber_id, collection_name2, note_name2,
                           note_file2)

        #owner listens both on primary and backup port
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        owner_mock_request2 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        sharing_space.add_listener(self.__account_id, owner_mock_request1)
        sharing_space.add_listener(self.__account_id, owner_mock_request2)

        #subscriber acts
        delete_note_action = DeleteSharedNoteAction(self.__subscriber_id,
                                                    collection_name2, note_name2)
        sharing_space.add_action(delete_note_action)
        action_type = delete_note_action.get_action_type()

        success = self.__simple_callback_flag
        if not success:
            for count in range(2):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_callback_flag:
                            success = True

        self.assertTrue(success)
        self.assertTrue(action_type in self.__primary_listener_notification_action)

    def test_backup_listener_not_notified(self):

        sharing_space = SharingSpaceController()
        collection_name1 = 'col_listener1'
        collection_name2 = 'col_listener2'
        self.__create_collection(self.__account_id, collection_name1)
        self.__create_collection(self.__subscriber_id, collection_name2)

        note_name1 = 'note_listener1'
        note_name2 = 'note_listener2'
        note_file1 = open('../test_resources/note.xml')
        note_file2 = open('../test_resources/note.xml')
        self.__create_note(self.__account_id, collection_name1, note_name1,
                           note_file1)
        self.__create_note(self.__subscriber_id, collection_name2, note_name2,
                           note_file2)

        #owner listens both on primary and backup port
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        owner_mock_request2 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_backup_callback)
        sharing_space.add_listener(self.__account_id, owner_mock_request1)
        sharing_space.add_listener(self.__account_id, owner_mock_request2)

        #subscriber sends an action
        new_note_file = open('../test_resources/sharing_note1.xml')
        new_note_name = 'new_note_name'
        expected_note_body = new_note_file.read()
        note_file_like = cStringIO.StringIO(expected_note_body)
        update_note_action = UpdateSharedNoteAction(self.__subscriber_id, collection_name2,
                                                    new_note_name, note_file_like)
        sharing_space.add_action(update_note_action)
        action_type = update_note_action.get_action_type()

        #check to see if the primary listener has been notified
        #busy wait three times and then give up
        success = self.__simple_callback_flag
        if not success:
            for count in range(2):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_callback_flag:
                            success = True

        self.assertTrue(success)
        self.assertTrue(action_type in self.__primary_listener_notification_action)

        #subscriber sends another action
        #subscriber sends an action
        new_note_file = open('../test_resources/sharing_note1.xml')
        new_note_name = 'new_note_name'
        expected_note_body = new_note_file.read()
        note_file_like = cStringIO.StringIO(expected_note_body)
        update_note_action = UpdateSharedNoteAction(self.__subscriber_id, collection_name2,
                                                    new_note_name, note_file_like)
        sharing_space.add_action(update_note_action)

        #wait for a while
        print 'waiting for the backup listener notification'
        success = self.__simple_backup_callback_flag
        if not success:
            for count in range(2):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_backup_callback_flag:
                            success = True

        self.assertTrue(not success)

    def test_backup_listener_recording(self):

        sharing_space = SharingSpaceController()
        collection_name1 = 'col_listener1'
        collection_name2 = 'col_listener2'
        self.__create_collection(self.__account_id, collection_name1)
        self.__create_collection(self.__subscriber_id, collection_name2)

        note_name1 = 'note_listener1'
        note_name2 = 'note_listener2'
        note_file1 = open('../test_resources/note.xml')
        note_file2 = open('../test_resources/note.xml')
        self.__create_note(self.__account_id, collection_name1, note_name1,
                           note_file1)
        self.__create_note(self.__subscriber_id, collection_name2, note_name2,
                           note_file2)

        #owner listens both on primary and backup port
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        owner_mock_request2 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_backup_callback)
        sharing_space.add_listener(self.__account_id, owner_mock_request1)
        sharing_space.add_listener(self.__account_id, owner_mock_request2)

        #subscriber sends an action
        new_note_file = open('../test_resources/sharing_note1.xml')
        new_note_name = 'new_note_name'
        expected_note_body = new_note_file.read()
        note_file_like = cStringIO.StringIO(expected_note_body)
        update_note_action = UpdateSharedNoteAction(self.__subscriber_id, collection_name2,
                                                    new_note_name, note_file_like)
        sharing_space.add_action(update_note_action)
        action_type = update_note_action.get_action_type()

        #check to see if the primary listener has been notified
        #busy wait three times and then give up
        success = self.__simple_callback_flag
        if not success:
            for count in range(2):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_callback_flag:
                            success = True

        self.assertTrue(success)
        self.assertTrue(action_type in self.__primary_listener_notification_action)


        #subscriber sends another action
        #subscriber sends an action
        new_note_file = open('../test_resources/sharing_note1.xml')
        new_note_name = 'new_note_name2'
        expected_note_body = new_note_file.read()
        note_file_like = cStringIO.StringIO(expected_note_body)
        update_note_action = UpdateSharedNoteAction(self.__subscriber_id, collection_name2,
                                                    new_note_name, note_file_like)
        sharing_space.add_action(update_note_action)
        last_action_type = update_note_action.get_action_type()

        #wait for a while
        print 'waiting for the backup listener notification'
        success = self.__simple_backup_callback_flag
        if not success:
            for count in range(2):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_backup_callback_flag:
                            success = True

        self.assertTrue(not success)

        #just clean up some stuff :)
        self.__simple_callback_flag = False
        self.__simple_backup_callback_flag = False

        print 'waiting for the primary listener notification'
        #now we send another listener to listen on the space
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        sharing_space.add_listener(self.__account_id, owner_mock_request1)
        #the listener should come back as fast as possible with the recorder
        #results

        success = self.__simple_backup_callback_flag
        if not success:
            for count in range(2):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_backup_callback_flag:
                            success = True

        self.assertTrue(success)
        self.assertTrue(action_type in self.__primary_listener_notification_action)
        #just clean up some stuff :)
        self.__simple_callback_flag = False
        self.__simple_backup_callback_flag = False

        #now try to add other actions and the backup listener should not
        #return
        new_note_file = open('../test_resources/sharing_note1.xml')
        new_note_name = 'new_note_name3'
        expected_note_body = new_note_file.read()
        note_file_like = cStringIO.StringIO(expected_note_body)
        update_note_action = UpdateSharedNoteAction(self.__subscriber_id, collection_name2,
                                                    new_note_name, note_file_like)
        sharing_space.add_action(update_note_action)
        pending_note_actions = []
        last_action_type = update_note_action.get_action_type()
        pending_note_actions.append(update_note_action.get_action_resource_name())

        #because the last primary action became the backup action
        #we should check the simple callback flag and not backup flag
        #wait for a while
        print 'waiting for the backup listener notification'
        success = self.__simple_callback_flag
        if not success:
            for count in range(2):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_callback_flag:
                            success = True

        self.assertTrue(not success)

        #just clean up some stuff :) Again !
        self.__simple_callback_flag = False
        self.__simple_backup_callback_flag = False

        #add an action that we will replace later
        replacable_note_file = open('../test_resources/sharing_note1.xml')
        replacable_note_name = 'replaceable_note'
        expected_note_body = replacable_note_file.read()
        note_file_like = cStringIO.StringIO(expected_note_body)
        update_note_action = UpdateSharedNoteAction(self.__subscriber_id, collection_name2,
                                                    replacable_note_name, note_file_like)
        sharing_space.add_action(update_note_action)

        #now we are going to just add all types of actions to
        #see if all of them get recorded
        for x in range(3):
            new_note_file = open('../test_resources/sharing_note1.xml')
            new_note_name = 'new_note_name_append' + str(x)
            expected_note_body = new_note_file.read()
            note_file_like = cStringIO.StringIO(expected_note_body)
            update_note_action = UpdateSharedNoteAction(self.__subscriber_id, collection_name2,
                                                        new_note_name, note_file_like)
            sharing_space.add_action(update_note_action)
            pending_note_actions.append(update_note_action.get_action_resource_name())

        #this will replace the replacable action
        replaced_note_file = open('../test_resources/sharing_note1.xml')
        replaced_note_name = replacable_note_name
        expected_note_body = replaced_note_file.read()
        note_file_like = cStringIO.StringIO(expected_note_body)
        update_note_action = UpdateSharedNoteAction(self.__subscriber_id, collection_name2,
                                                    replaced_note_name, note_file_like)
        sharing_space.add_action(update_note_action)
        pending_note_actions.append(update_note_action.get_action_resource_name())

        #throw in an update manifest action
        new_manifest_file = open('../test_resources/sharing_manifest1.xml')
        expected_note_body = new_manifest_file.read()
        manifest_file_like = cStringIO.StringIO(expected_note_body)
        update_manifest_action = UpdateSharedManifestAction(self.__subscriber_id,
                                                            collection_name2, manifest_file_like)
        sharing_space.add_action(update_manifest_action)
        #and an update thumbnail
        thumbnail_file = open('../test_resources/workfile.jpg')
        update_thumbnail_action = UpdateSharedThumbnailAction(self.__subscriber_id,
                                                              collection_name2, thumbnail_file)

        thumbnail_file2 = open('../test_resources/sharing_note_img2.jpg')
        update_thumbnail_action2 = UpdateSharedThumbnailAction(self.__subscriber_id,
                                                               collection_name2, thumbnail_file2)
        sharing_space.add_action(update_thumbnail_action2)

        update_thumbnail_action = update_thumbnail_action2

        #some deleted
        pending_delete_actions = []

        #now we are going to just add all types of actions to
        #see if all of them get recorded
        for x in range(2):
            new_note_name = 'new_note_name_append' + str(x)
            delete_note_action = DeleteSharedNoteAction(self.__subscriber_id, collection_name2,
                                                        new_note_name)
            sharing_space.add_action(delete_note_action)
            pending_delete_actions.append(delete_note_action.get_action_resource_name())

        #an sprinkle of update note image actions
        pending_img_actions = []
        for x in range(2):
            new_note_img = open('../test_resources/workfile.jpg')
            img_file_like = cStringIO.StringIO(expected_note_body)
            new_note_name = 'new_note_img' + str(x)
            update_img_action = UpdateSharedNoteImageAction(self.__subscriber_id,
                                                            collection_name2, new_note_name, img_file_like)
            sharing_space.add_action(update_img_action)
            pending_img_actions.append(update_img_action.get_action_resource_name())

        #now wait a little bit
        try:
            self.wait(timeout=5)
        except Exception:
            pass

        #now add the primary listener again
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        sharing_space.add_listener(self.__account_id, owner_mock_request1)
        #the listener should come back as fast as possible with the recorder
        #results

        print 'waiting for the primary listener notification'
        success = self.__simple_callback_flag
        if not success:
            for count in range(3):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_callback_flag:
                            success = True

        self.assertTrue(success)

        note_action_type = update_note_action.get_action_type()
        update_note_actions = \
            self.__primary_listener_notification_action[note_action_type]
        for note_action_resource in update_note_actions:
            if note_action_resource not in pending_note_actions:
                self.fail('actions are not up to date')
            else:
                pending_note_actions.remove(note_action_resource)

        self.assertTrue(not len(pending_note_actions))

        delete_action_type = SharingEvent.DELETE_NOTE
        delete_note_actions = \
            self.__primary_listener_notification_action[delete_action_type]
        for delete_action_resource in delete_note_actions:
            if delete_action_resource not in pending_delete_actions:
                self.fail('actions are not up to date')
            else:
                pending_delete_actions.remove(delete_action_resource)

        self.assertTrue(not len(pending_delete_actions))

        manifest_action_type = update_manifest_action.get_action_type()
        self.assertTrue(manifest_action_type in self.__primary_listener_notification_action)

        thumbnail_action_type = SharingEvent.UPDATE_THUMBNAIL
        self.assertTrue(thumbnail_action_type in self.__primary_listener_notification_action)

        update_img_action_type = SharingEvent.UPDATE_NOTE_IMG
        update_img_actions = \
            self.__primary_listener_notification_action[update_img_action_type]
        for img_action_resource in update_img_actions:
            if img_action_resource not in pending_img_actions:
                self.fail('actions are not up to date')
            else:
                pending_img_actions.remove(img_action_resource)

        self.assertTrue(not len(pending_img_actions))

    def test_primary_listener_joining_without_backup_recording(self):

        sharing_space = SharingSpaceController()
        collection_name1 = 'col_listener1'
        collection_name2 = 'col_listener2'
        self.__create_collection(self.__account_id, collection_name1)
        self.__create_collection(self.__subscriber_id, collection_name2)

        note_name1 = 'note_listener1'
        note_name2 = 'note_listener2'
        note_file1 = open('../test_resources/note.xml')
        note_file2 = open('../test_resources/note.xml')
        self.__create_note(self.__account_id, collection_name1, note_name1,
                           note_file1)
        self.__create_note(self.__subscriber_id, collection_name2, note_name2,
                           note_file2)

        #owner listens both on primary and backup port
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        owner_mock_request2 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_backup_callback)
        sharing_space.add_listener(self.__account_id, owner_mock_request1)
        sharing_space.add_listener(self.__account_id, owner_mock_request2)

        #subscriber sends an action
        new_manifest_file = open('../test_resources/sharing_manifest1.xml')
        expected_note_body = new_manifest_file.read()
        manifest_file_like = cStringIO.StringIO(expected_note_body)
        update_manifest_action = UpdateSharedManifestAction(self.__subscriber_id,
                                                            collection_name2, manifest_file_like)
        sharing_space.add_action(update_manifest_action)
        action_type = update_manifest_action.get_action_type()

        #check to see if the primary listener has been notified
        #busy wait three times and then give up
        success = self.__simple_callback_flag
        if not success:
            for count in range(2):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_callback_flag:
                            success = True

        self.assertTrue(success)
        self.assertTrue(action_type in self.__primary_listener_notification_action)

        self.__simple_callback_flag = False

        #the primary listener is sent again without anything happening meanwhile
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        sharing_space.add_listener(self.__account_id, owner_mock_request1)

        #wait for a while
        success = self.__simple_callback_flag

        if not success:
            for count in range(2):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_callback_flag:
                            success = True

        self.assertTrue(not success)
        self.assertTrue(not self.__simple_backup_callback_flag)
        self.__simple_backup_callback_flag = False
        self.__simple_callback_flag = False

        #now subscriber sends another action
        new_manifest_file = open('../test_resources/sharing_manifest1.xml')
        expected_note_body = new_manifest_file.read()
        manifest_file_like = cStringIO.StringIO(expected_note_body)
        update_manifest_action = UpdateSharedManifestAction(self.__subscriber_id,
                                                            collection_name2, manifest_file_like)
        sharing_space.add_action(update_manifest_action)

        success = self.__simple_callback_flag
        if not success:
            for count in range(2):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_callback_flag:
                            success = True

        self.assertTrue(success)

    def test_multiple_users_listening(self):

        sharing_space = SharingSpaceController()
        collection_name1 = 'col_listener1'
        collection_name2 = 'col_listener2'

        self.__create_collection(self.__account_id, collection_name1)
        self.__create_collection(self.__subscriber_id, collection_name2)

        note_name1 = 'note_listener1'
        note_name2 = 'note_listener2'
        note_file1 = open('../test_resources/note.xml')
        note_file2 = open('../test_resources/note.xml')
        self.__create_note(self.__account_id, collection_name1, note_name1,
                           note_file1)
        self.__create_note(self.__subscriber_id, collection_name2, note_name2,
                           note_file2)

        #owner listens both on primary and backup port
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        owner_mock_request2 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_backup_callback)
        sharing_space.add_listener(self.__account_id, owner_mock_request1)
        sharing_space.add_listener(self.__account_id, owner_mock_request2)

        #subscriber listens both on primary and backup port
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        owner_mock_request2 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_backup_callback)
        sharing_space.add_listener(self.__subscriber_id, owner_mock_request1)
        sharing_space.add_listener(self.__subscriber_id, owner_mock_request2)

        #Another subscriber listens both on primary and backup port
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        owner_mock_request2 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_backup_callback)
        sharing_space.add_listener(self.__second_subscriber_id, owner_mock_request1)
        sharing_space.add_listener(self.__second_subscriber_id, owner_mock_request2)


        #cleanup flags
        self.__simple_callback_flag = False
        self.__simple_backup_callback_flag = False

        #the owner adds an action
        new_note_file = open('../test_resources/sharing_note1.xml')
        new_note_name = 'new_note_name'
        expected_note_body = new_note_file.read()
        note_file_like = cStringIO.StringIO(expected_note_body)
        update_note_action = UpdateSharedNoteAction(self.__account_id, collection_name1,
                                                    new_note_name, note_file_like)
        sharing_space.add_action(update_note_action)

        #check to see if the primary listener has been notified
        #busy wait three times and then give up
        success = self.__simple_callback_flag
        if not success:
            for count in range(3):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_callback_flag:
                            success = True

        self.assertTrue(success)
        self.assertFalse(self.__simple_backup_callback_flag)
        #we have three users, two responses should come back because
        #one listener is the one who made the action
        self.assertEqual(2, self.__primary_listeners_returned)
        #cleanup
        self.__simple_backup_callback_flag = False
        self.__primary_listeners_returned = 0

        #now add some actions for the backup listeners to record
        new_note_file = open('../test_resources/sharing_note1.xml')
        new_note_name = 'recording_note'
        expected_note_body = new_note_file.read()
        note_file_like = cStringIO.StringIO(expected_note_body)
        update_note_action = UpdateSharedNoteAction(self.__second_subscriber_id, collection_name2,
                                                    new_note_name, note_file_like)
        sharing_space.add_action(update_note_action)

        #wait a little bit
        try:
            self.wait(timeout=5)
        except Exception:
            pass

        #now add the primary listeners for the two primary listeners
        #that returned
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        sharing_space.add_listener(self.__subscriber_id, owner_mock_request1)

        #Another subscriber listens both on primary and backup port
        owner_mock_request1 = MockFactory.get_mock_request(self.__account_id,
                                                           self.owner_simple_callback)
        sharing_space.add_listener(self.__second_subscriber_id, owner_mock_request1)

        #check to see if the primary listener has been notified
        #busy wait three times and then give up
        success = self.__simple_backup_callback_flag
        if not success:
            for count in range(3):
                if not success:
                    try:
                        self.wait(timeout=5)
                    except Exception:
                        if self.__simple_backup_callback_flag:
                            success = True

        self.assertTrue(success)
        self.assertEqual(1, self.__primary_listeners_returned)
        #only one backup callback should return. Two listeners return one is the priamry listener
        #remainign from the owner and the other is the backup listener for first subscriber
        self.assertEqual(1, self.__backup_listeners_returned)

    def owner_simple_callback(self, status, body):

        self.__simple_callback_flag = True
        print 'first listener returned'
        print body
        response_json = json.loads(body)
        self.__primary_listener_notification_action = response_json
        self.__primary_listeners_returned += 1

    def owner_backup_callback(self, status, body):
        self.__simple_backup_callback_flag = True
        print 'backup listener returned'
        print body
        response_json = json.loads(body)
        self.__primary_listener_notification_action = response_json
        self.__backup_listeners_returned += 1


    def test_retreive_sotred_note_img_not_existing(self):

        sharing_space = SharingSpaceController()
        sharing_space.get_temp_img('img-dummy', 'img-dummer',
                                   'img-dumms', 'img-dummble', callback=self.stop)
        img = self.wait()
        self.assertTrue(img is None)

    def test_retreive_stored_note_img_not_cached(self):

        sharing_space = SharingSpaceController()

        collection_name = 'collName'
        note_name = 'note_name_temp'
        #add image
        img_file = open('../test_resources/note_img.jpg')
        StorageServer.add_image_to_note(self.__account_id, collection_name,
                                        note_name, img_file, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        sharing_space.get_temp_img('lalala', self.__account_id,
                                   collection_name, note_name, callback=self.stop)
        img = self.wait()

        self.assertTrue(img is not None)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_retreive_stored_thumbnail_not_existing(self):
        sharing_space = SharingSpaceController()
        sharing_space.get_temp_img('img-dummy', 'img-dummer',
                                   'img-dumms', note_name=None, callback=self.stop)
        img = self.wait()
        self.assertTrue(img is None)

    def test_retreive_stored_thumbnail_not_cached(self):

        collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.__account_id, collection_name,
                                     callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        thumbnail = open('../test_resources/thumbnail.jpg')
        StorageServer.add_thumbnail(self.__account_id, collection_name, thumbnail,
                                    callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        sharing_space = SharingSpaceController()
        sharing_space.get_temp_img('lalala', self.__account_id,
                                   collection_name, note_name=None, callback=self.stop)
        img = self.wait()
        self.assertTrue(img is not None)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
                                        callback=self.stop)
        self.wait()



