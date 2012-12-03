from Sharing.SharingEvent import SharingEvent
from Sharing.SharingQueue import SharingQueue
from Sharing.UpdateSharedManifestAction import UpdateSharedManifestAction
from Sharing.UpdateSharedNoteAction import UpdateSharedNoteAction
from Sharing.UpdateSharedNoteImageAction import UpdateSharedNoteImageAction
from Tests.TestingProperties import TestingProperties

__author__ = 'afathali'

from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

class SharingQueueTests(AsyncTestCase):
    __account_id = TestingProperties.account_id
    __subscriber_id = TestingProperties.subscriber_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_push_action(self):

        sharing_queue = SharingQueue()
        collection_name = 'collection_name'
        note_name = 'note_name'
        #update manifest
        file = open('../test_resources/XooML2.xml')
        update_manifest_action = UpdateSharedManifestAction(self.__account_id,
            collection_name, file)

        note_file = open('../test_resources/note2.xml')
        update_note_action = UpdateSharedNoteAction(self.__account_id, collection_name,
            note_name, note_file)

        img_file2 = open('../test_resources/note_img2.jpg')
        update_note_img_action = UpdateSharedNoteImageAction(self.__account_id, collection_name,
            note_name, img_file2)

        sharing_queue.push_action(update_manifest_action)
        sharing_queue.push_action(update_note_action)
        sharing_queue.push_action(update_note_img_action)

        expected_manifest_action = sharing_queue.pop_next_action().get_action_type()
        expected_note_action = sharing_queue.pop_next_action().get_action_type()
        expected_note_img_action = sharing_queue.pop_next_action().get_action_type()

        self.assertEqual(expected_manifest_action, SharingEvent.UPDATE_MANIFEST)
        self.assertEqual(expected_note_action, SharingEvent.UPDATE_NOTE)
        self.assertEqual(expected_note_img_action, SharingEvent.UPDATE_NOTE_IMG)

    def test_pop_and_push_single_user(self):

        collection_name = 'col_name'
        sharing_queue = SharingQueue()
        popped_item = sharing_queue.pop_next_action()
        self.assertTrue(popped_item is None)

        #single push
        file = open('../test_resources/XooML2.xml')
        update_manifest_action = UpdateSharedManifestAction(self.__account_id,
            collection_name, file)
        sharing_queue.push_action(update_manifest_action)
        popped_item = sharing_queue.pop_next_action()
        self.assertTrue(popped_item is not None)
        popped_item = sharing_queue.pop_next_action()
        self.assertTrue(popped_item is None)

        #push and update
        sharing_queue.push_action(update_manifest_action)
        update_manifest_action = UpdateSharedManifestAction(self.__account_id,
            'new_col_name', file)
        sharing_queue.push_action(update_manifest_action)
        popped_item = sharing_queue.pop_next_action()
        self.assertTrue(popped_item is not None)
        popped_item = sharing_queue.pop_next_action()
        self.assertTrue(popped_item is None)

        note_file = open('../test_resources/note2.xml')
        update_note_action = UpdateSharedNoteAction(self.__account_id, collection_name,
            'note_1', note_file)
        note_file2 = open('../test_resources/note.xml')
        update_note_action2 = UpdateSharedNoteAction(self.__account_id, collection_name,
            'note_2', note_file2)
        sharing_queue.push_action(update_manifest_action)
        sharing_queue.push_action(update_note_action)
        sharing_queue.push_action(update_note_action2)
        action = sharing_queue.pop_next_action()
        self.assertTrue(action is not None)
        action = sharing_queue.pop_next_action()
        self.assertTrue(action is not None)
        action = sharing_queue.pop_next_action()
        self.assertTrue(action is not None)
        action = sharing_queue.pop_next_action()
        self.assertTrue(action is None)

    def test_push_and_pop_multiple_users(self):
        sharing_queue = SharingQueue()
        collection_name1 = 'collection_name1'
        collection_name2 = 'collection_name2'
        note_name1 = 'note_name'
        note_name2 = 'note_name2'

        action_list = []
        #note actions
        #user1
        note_file = open('../test_resources/note2.xml')
        for user_id in [self.__account_id, self.__subscriber_id]:
            #add the same note twice
            for x in range (2):
                update_note_action = UpdateSharedNoteAction(user_id,
                    collection_name1, note_name1, note_file)
                action_list.append(update_note_action)
            #now add different notes
            for x in range(2):
                update_note_action = UpdateSharedNoteAction(user_id,
                    collection_name1, note_name1 + str(x), note_file)
                action_list.append(update_note_action)
        #manifest actions
        manifest_file = open('../test_resources/XooML2.xml')
        for user_id in [self.__account_id, self.__subscriber_id]:
            #these should be added only once per user
            for x in range(5):
                update_manifest_action = UpdateSharedManifestAction(user_id,
                    collection_name1, manifest_file)
                action_list.append(update_manifest_action)

        #image actions
        note_img = open('../test_resources/note2.xml')
        for user_id in [self.__account_id, self.__subscriber_id]:
            #these should be only added once per user
            for x in range (3):
                update_note_img_action = UpdateSharedNoteImageAction(user_id, collection_name1,
                    note_name1, note_img)
                action_list.append(update_note_img_action)
                #now add different notes
            for x in range(3):
                update_note_img_action = UpdateSharedNoteImageAction(user_id, collection_name1,
                    note_name1 + str(x), note_img)
                action_list.append(update_note_img_action)
        #now update the queue
        for action in action_list:
            sharing_queue.push_action(action)

        #verify
        #two manifest actions
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_MANIFEST, next_action.get_action_type())
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_MANIFEST, next_action.get_action_type())
        #6 update note actions
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_NOTE, next_action.get_action_type())
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_NOTE, next_action.get_action_type())
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_NOTE, next_action.get_action_type())
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_NOTE, next_action.get_action_type())
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_NOTE, next_action.get_action_type())
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_NOTE, next_action.get_action_type())
        #8 update img actions
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_NOTE_IMG, next_action.get_action_type())
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_NOTE_IMG, next_action.get_action_type())
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_NOTE_IMG, next_action.get_action_type())
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_NOTE_IMG, next_action.get_action_type())
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_NOTE_IMG, next_action.get_action_type())
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_NOTE_IMG, next_action.get_action_type())
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_NOTE_IMG, next_action.get_action_type())
        next_action = sharing_queue.pop_next_action()
        self.assertEqual(SharingEvent.UPDATE_NOTE_IMG, next_action.get_action_type())

        #rest should be empty
        next_action = sharing_queue.pop_next_action()
        self.assertTrue(next_action is None)
        next_action = sharing_queue.pop_next_action()
        self.assertTrue(next_action is None)



    def test_pop_action_order(self):

        sharing_queue = SharingQueue()
        collection_name = 'collection_name'
        note_name = 'note_name'
        note_name2 = 'note_name2'
        #update manifest
        file = open('../test_resources/XooML2.xml')
        update_manifest_action = UpdateSharedManifestAction(self.__account_id,
            collection_name, file)

        note_file = open('../test_resources/note2.xml')
        update_note_action = UpdateSharedNoteAction(self.__account_id, collection_name,
            note_name, note_file)
        update_note_action2 = UpdateSharedNoteAction(self.__account_id, collection_name,
            note_name2, note_file)

        img_file2 = open('../test_resources/note_img2.jpg')
        update_note_img_action = UpdateSharedNoteImageAction(self.__account_id, collection_name,
            note_name, img_file2)
        update_note_img_action2 = UpdateSharedNoteImageAction(self.__account_id, collection_name,
            note_name2, img_file2)

        sharing_queue.push_action(update_note_action)
        sharing_queue.push_action(update_note_img_action)
        sharing_queue.push_action(update_note_img_action2)
        sharing_queue.push_action(update_note_action2)
        sharing_queue.push_action(update_manifest_action)

        action = sharing_queue.pop_next_action()
        self.assertEqual(action.get_action_type(), SharingEvent.UPDATE_MANIFEST)
        action = sharing_queue.pop_next_action()
        self.assertEqual(action.get_action_type(), SharingEvent.UPDATE_NOTE)
        action = sharing_queue.pop_next_action()
        self.assertEqual(action.get_action_type(), SharingEvent.UPDATE_NOTE)
        action = sharing_queue.pop_next_action()
        self.assertEqual(action.get_action_type(), SharingEvent.UPDATE_NOTE_IMG)
        action = sharing_queue.pop_next_action()
        self.assertEqual(action.get_action_type(), SharingEvent.UPDATE_NOTE_IMG)
        action = sharing_queue.pop_next_action()
        self.assertTrue(action is None)
        action = sharing_queue.pop_next_action()
        self.assertTrue(action is None)

    def test_push_updated_actions(self):

        sharing_queue = SharingQueue()
        collection_name = 'collection_name'
        note_name = 'note_name'
        collection_name2 = 'collection_name2'
        #update manifest
        file = open('../test_resources/XooML2.xml')
        update_manifest_action = UpdateSharedManifestAction(self.__account_id,
            collection_name, file)
        update_manifest_action2 = UpdateSharedManifestAction(self.__account_id,
            collection_name2, file)

        note_file = open('../test_resources/note2.xml')
        update_note_action = UpdateSharedNoteAction(self.__account_id, collection_name,
            note_name, note_file)
        update_note_action2 = UpdateSharedNoteAction(self.__account_id, collection_name,
            note_name, note_file)

        img_file2 = open('../test_resources/note_img2.jpg')
        update_note_img_action = UpdateSharedNoteImageAction(self.__account_id, collection_name,
            note_name, img_file2)
        update_note_img_action2 = UpdateSharedNoteImageAction(self.__account_id, collection_name,
            note_name, img_file2)

        sharing_queue.push_action(update_note_action)
        sharing_queue.push_action(update_note_img_action)
        sharing_queue.push_action(update_manifest_action)
        sharing_queue.push_action(update_manifest_action2)
        sharing_queue.push_action(update_note_img_action2)
        sharing_queue.push_action(update_note_action2)

        action = sharing_queue.pop_next_action()
        self.assertEqual(action.get_action_type(), SharingEvent.UPDATE_MANIFEST)
        self.assertEqual(action.get_collection_name(), collection_name2)
        action = sharing_queue.pop_next_action()
        self.assertEqual(action.get_action_type(), SharingEvent.UPDATE_NOTE)
        action = sharing_queue.pop_next_action()
        self.assertEqual(action.get_action_type(), SharingEvent.UPDATE_NOTE_IMG)
        action = sharing_queue.pop_next_action()
        self.assertTrue(action is None)
