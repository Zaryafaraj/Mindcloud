import json
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Sharing.DeleteSharedNoteAction import DeleteSharedNoteAction
from Sharing.SharingActionFactory import SharingActionFactory
from Sharing.SharingController import SharingController
from Sharing.SharingEvent import SharingEvent
from Sharing.UpdateSharedManifestAction import UpdateSharedManifestAction
from Sharing.UpdateSharedNoteAction import UpdateSharedNoteAction
from Sharing.UpdateSharedNoteImageAction import UpdateSharedNoteImageAction
from Sharing.UpdateSharedThumbnailAction import UpdateSharedThumbnailAction
from Sharing.SendDiffFileAction import SendDiffFileAction
from Sharing.SendCustomMessageAction import SendCustomMessageAction
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer
from Tests.TestingProperties import TestingProperties

__author__ = 'afathali'


class SharingActionFactoryTestCase(AsyncTestCase):
    __account_id = TestingProperties.account_id
    __subscriber_id = TestingProperties.subscriber_id
    __second_subscriber = TestingProperties.second_subscriber_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_deserialize_json_for_update_manifest(self):
        user_id = 'userID'
        collection_name = 'collection_name'
        details = {'user_id': user_id, 'collection_name': collection_name}
        test_dict = {SharingEvent.UPDATE_MANIFEST: details}
        json_str = json.dumps(test_dict)
        manifest = open('../test_resources/XooML.xml')
        sharing_action = SharingActionFactory.from_json_and_file(json_str, manifest)

        self.assertEqual(user_id, sharing_action.get_user_id())
        self.assertEqual(collection_name, sharing_action.get_collection_name())
        self.assertTrue(sharing_action.get_associated_file() is not None)
        self.assertEqual(SharingEvent.UPDATE_MANIFEST, sharing_action.get_action_type())

    def test_create_action_for_send_diff_file(self):

        user_id = 'userID'
        collection_name = 'collection_name'
        diff_file = open('../test_resources/XooML.xml')
        resource_path = 'XooML.xml'
        sharing_action = SharingActionFactory.from_diff_file_and_user(diff_file,
                                                                      user_id,
                                                                      collection_name,
                                                                      resource_path)
        self.assertEqual(user_id, sharing_action.get_user_id())
        self.assertEqual(collection_name, sharing_action.get_collection_name())
        self.assertTrue(sharing_action.get_associated_file() is not None)
        self.assertEqual(SharingEvent.SEND_DIFF_FILE, sharing_action.get_action_type())

    def test_create_action_for_custom_message(self):

        user_id = 'UserId'
        collection_name = 'collection_name'
        msg = "{'hello' : 'hi'}"
        msg_id = 'ID1234'

        sharing_action = SharingActionFactory.from_custom_message_and_user(msg, msg_id, user_id, collection_name)

        self.assertEqual(user_id, sharing_action.get_user_id())
        self.assertEqual(collection_name, sharing_action.get_collection_name())
        self.assertTrue(sharing_action.get_associated_file() is None)
        self.assertEqual(SharingEvent.SEND_CUSTOM_MSG, sharing_action.get_action_type())
        self.assertEqual(msg_id, sharing_action.get_action_resource_name())
        self.assertEqual(msg, sharing_action.get_custom_message())

    def test_deserialize_json_for_update_manifest_invalid_json(self):

        invalid_str = 'invalid_str'
        test_dict = {SharingEvent.UPDATE_MANIFEST: invalid_str}
        json_str = json.dumps(test_dict)

        manifest = open('../test_resources/XooML.xml')
        sharing_action = SharingActionFactory.from_json_and_file(json_str, manifest)

        self.assertTrue(sharing_action is None)

    def test_deserialize_json_for_update_manifest_missing_file(self):

        user_id = 'userID'
        collection_name = 'collection_name'
        details = {'user_id': user_id, 'collection_name': collection_name}
        test_dict = {SharingEvent.UPDATE_MANIFEST: details}
        json_str = json.dumps(test_dict)
        manifest = None
        sharing_action = SharingActionFactory.from_json_and_file(json_str, manifest)

        self.assertTrue(sharing_action is None)

    def test_deserialize_json_for_update_note(self):

        user_id = 'userID'
        collection_name = 'collection_name'
        note_name = 'note_name'
        note_file = open('../test_resources/XooML.xml')

        details = {'user_id': user_id,
                   'collection_name': collection_name,
                   'note_name': note_name}
        test_dict = {SharingEvent.UPDATE_NOTE: details}
        json_str = json.dumps(test_dict)
        sharing_action = SharingActionFactory.from_json_and_file(json_str, note_file)

        self.assertEqual(user_id, sharing_action.get_user_id())
        self.assertEqual(collection_name, sharing_action.get_collection_name())
        self.assertEqual(note_name, sharing_action.get_note_name())
        self.assertTrue(sharing_action.get_associated_file() is not None)
        self.assertEqual(SharingEvent.UPDATE_NOTE, sharing_action.get_action_type())

    def test_deserialize_json_for_update_note_invalid_json(self):

        note_file = open('../test_resources/XooML.xml')

        invalid_str = 'invalid_str'
        test_dict = {SharingEvent.UPDATE_NOTE: invalid_str}
        json_str = json.dumps(test_dict)

        sharing_action = SharingActionFactory.from_json_and_file(json_str, note_file)
        self.assertTrue(sharing_action is None)

    def test_deserialize_json_for_update_note_missing_file(self):

        user_id = 'userID'
        collection_name = 'collection_name'
        note_name = 'note_name'

        details = {'user_id': user_id,
                   'collection_name': collection_name,
                   'note_name': note_name}
        test_dict = {SharingEvent.UPDATE_NOTE: details}
        json_str = json.dumps(test_dict)
        sharing_action = SharingActionFactory.from_json_and_file(json_str, None)

        self.assertTrue(sharing_action is None)

    def test_deserialize_json_for_update_note_img(self):

        user_id = 'userID'
        collection_name = 'collection_name'
        note_name = 'note_name'
        note_img_file = open('../test_resources/workfile.jpg')

        details = {'user_id': user_id,
                   'collection_name': collection_name,
                   'note_name': note_name}
        test_dict = {SharingEvent.UPDATE_NOTE_IMG: details}
        json_str = json.dumps(test_dict)
        sharing_action = SharingActionFactory.from_json_and_file(json_str,
                                                                 note_img_file)

        self.assertEqual(user_id, sharing_action.get_user_id())
        self.assertEqual(collection_name, sharing_action.get_collection_name())
        self.assertEqual(note_name, sharing_action.get_note_name())
        self.assertTrue(sharing_action.get_associated_file() is not None)
        self.assertEqual(SharingEvent.UPDATE_NOTE_IMG, sharing_action.get_action_type())

    def test_deserialize_json_for_update_note_img_invalid_json(self):

        note_img_file = open('../test_resources/XooML.xml')

        invalid_str = 'invalid_str'
        test_dict = {SharingEvent.UPDATE_NOTE_IMG: invalid_str}
        json_str = json.dumps(test_dict)

        sharing_action = SharingActionFactory.from_json_and_file(json_str, note_img_file)
        self.assertTrue(sharing_action is None)

    def test_deserialize_json_for_update_note_img_missing_file(self):

        user_id = 'userID'
        collection_name = 'collection_name'
        note_name = 'note_name'

        details = {'user_id': user_id,
                   'collection_name': collection_name,
                   'note_name': note_name}
        test_dict = {SharingEvent.UPDATE_NOTE_IMG: details}
        json_str = json.dumps(test_dict)
        sharing_action = SharingActionFactory.from_json_and_file(json_str,
                                                                 None)
        self.assertTrue(sharing_action is None)

    def test_deserialize_json_for_update_thumbnail(self):

        user_id = 'userID'
        collection_name = 'coll_name'
        thumbnail_file = open('../test_resources/XooML.xml')
        details = {'user_id': user_id, 'collection_name': collection_name}
        test_dict = {SharingEvent.UPDATE_THUMBNAIL: details}
        json_str = json.dumps(test_dict)
        sharing_action = SharingActionFactory.from_json_and_file(json_str,
                                                                 thumbnail_file)

        self.assertEqual(user_id, sharing_action.get_user_id())
        self.assertEqual(collection_name, sharing_action.get_collection_name())
        self.assertTrue(sharing_action.get_associated_file() is not None)
        self.assertEqual(SharingEvent.UPDATE_THUMBNAIL, sharing_action.get_action_type())

    def test_deserialize_json_for_update_thumbnail_invalid_json(self):

        invalid_str = 'invalid_str'
        test_dict = {SharingEvent.UPDATE_THUMBNAIL: invalid_str}
        json_str = json.dumps(test_dict)

        thumbnail_file = open('../test_resources/XooML.xml')
        sharing_action = SharingActionFactory.from_json_and_file(json_str, thumbnail_file)

        self.assertTrue(sharing_action is None)

    def test_deserialize_json_for_update_thumbnail_missing_file(self):

        user_id = 'userID'
        collection_name = 'coll_name'
        details = {'user_id': user_id, 'collection_name': collection_name}
        test_dict = {SharingEvent.UPDATE_THUMBNAIL: details}
        json_str = json.dumps(test_dict)
        sharing_action = SharingActionFactory.from_json_and_file(json_str,
                                                                 None)

        self.assertTrue(sharing_action is None)

    def test_deserialize_json_for_delete_note(self):

        user_id = 'userID'
        collection_name = 'collection_name'
        note_name = 'note_name'

        details = {'user_id': user_id,
                   'collection_name': collection_name,
                   'note_name': note_name}
        test_dict = {SharingEvent.DELETE_NOTE: details}
        json_str = json.dumps(test_dict)
        sharing_action = SharingActionFactory.from_json_and_file(json_str, None)

        self.assertEqual(user_id, sharing_action.get_user_id())
        self.assertEqual(collection_name, sharing_action.get_collection_name())
        self.assertEqual(note_name, sharing_action.get_note_name())
        self.assertTrue(sharing_action.get_associated_file() is None)
        self.assertEqual(SharingEvent.DELETE_NOTE, sharing_action.get_action_type())

    def test_deserialize_json_for_delete_note_invalid_json(self):

        invalid_str = 'invalid_str'
        test_dict = {SharingEvent.DELETE_NOTE: invalid_str}
        json_str = json.dumps(test_dict)

        sharing_action = SharingActionFactory.from_json_and_file(json_str, None)

        self.assertTrue(sharing_action is None)

    def __create_sharing_record(self, subscriber_list, collection_name):

        #create collection
        test_file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
                                     collection_name=collection_name, callback=self.stop, file=test_file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #create sharing record
        SharingController.create_sharing_record(self.__account_id,
                                                collection_name, callback=self.stop)
        sharing_secret = self.wait(timeout=10000)
        self.assertTrue(sharing_secret is not None)

        for subscriber_id in subscriber_list:
            #subscribe
            SharingController.subscribe_to_sharing_space(subscriber_id,
                                                         sharing_secret, callback=self.stop)
            subscribers_collection_name = self.wait()
            self.assertTrue(subscribers_collection_name is not None)

        return sharing_secret

    def test_create_related_actions_update_manifest(self):

        collection_name = 'sharing_collection'
        subscribers = [self.__subscriber_id]
        sharing_secret = \
            self.__create_sharing_record(subscribers, collection_name)
        subscribers.append(self.__account_id)

        test_file = open('../test_resources/XooML.xml')
        manifest_action = UpdateSharedManifestAction(self.__account_id,
                                                     collection_name, test_file)
        SharingActionFactory.create_related_sharing_actions(sharing_secret,
                                                            manifest_action, callback=self.stop)
        sharing_action_list = self.wait()

        self.assertEqual(2, len(sharing_action_list))

        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            self.assertTrue(user_id in subscribers)
            subscribers.remove(user_id)
            self.assertEqual(SharingEvent.UPDATE_MANIFEST,
                             sharing_action.get_action_type())
        self.assertEqual(0, len(subscribers))

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback=self.stop)
        self.wait()
        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            collection_name = sharing_action.get_collection_name()
            StorageServer.remove_collection(user_id, collection_name,
                                            callback=self.stop)
            self.wait()

    def test_create_related_actions_update_note(self):

        collection_name = 'sharing_collection'
        subscribers = [self.__subscriber_id]
        sharing_secret = \
            self.__create_sharing_record(subscribers, collection_name)
        subscribers.append(self.__account_id)

        note_name = 'lala_note'
        test_file = open('../test_resources/XooML.xml')
        note_action = UpdateSharedNoteAction(self.__account_id,
                                             collection_name, note_name, test_file)
        SharingActionFactory.create_related_sharing_actions(sharing_secret,
                                                            note_action, callback=self.stop)
        sharing_action_list = self.wait()

        self.assertEqual(2, len(sharing_action_list))

        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            actual_note_name = sharing_action.get_note_name()
            self.assertEqual(note_name, actual_note_name)
            self.assertTrue(user_id in subscribers)
            subscribers.remove(user_id)
            self.assertEqual(SharingEvent.UPDATE_NOTE,
                             sharing_action.get_action_type())
        self.assertEqual(0, len(subscribers))

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback=self.stop)
        self.wait()
        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            collection_name = sharing_action.get_collection_name()
            StorageServer.remove_collection(user_id, collection_name,
                                            callback=self.stop)
            self.wait()

    def test_create_related_actions_update_note_img(self):

        collection_name = 'sharing_collection'
        subscribers = [self.__subscriber_id]
        sharing_secret = \
            self.__create_sharing_record(subscribers, collection_name)
        subscribers.append(self.__account_id)

        note_name = 'lala_note'
        test_file = open('../test_resources/XooML.xml')
        note_img_action = UpdateSharedNoteImageAction(self.__account_id,
                                                      collection_name, note_name, test_file)
        SharingActionFactory.create_related_sharing_actions(sharing_secret,
                                                            note_img_action, callback=self.stop)
        sharing_action_list = self.wait()

        self.assertEqual(2, len(sharing_action_list))

        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            actual_note_name = sharing_action.get_note_name()
            self.assertEqual(note_name, actual_note_name)
            self.assertTrue(user_id in subscribers)
            subscribers.remove(user_id)
            self.assertEqual(SharingEvent.UPDATE_NOTE_IMG,
                             sharing_action.get_action_type())
        self.assertEqual(0, len(subscribers))

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback=self.stop)
        self.wait()
        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            collection_name = sharing_action.get_collection_name()
            StorageServer.remove_collection(user_id, collection_name,
                                            callback=self.stop)
            self.wait()

    def test_create_related_actions_delete_note(self):

        collection_name = 'sharing_collection'
        subscribers = [self.__subscriber_id]
        sharing_secret = \
            self.__create_sharing_record(subscribers, collection_name)
        subscribers.append(self.__account_id)

        note_name = 'lala note'
        delete_action = DeleteSharedNoteAction(self.__account_id,
                                               collection_name, note_name)

        SharingActionFactory.create_related_sharing_actions(sharing_secret,
                                                            delete_action, callback=self.stop)
        sharing_action_list = self.wait()

        self.assertEqual(2, len(sharing_action_list))

        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            actual_note_name = sharing_action.get_note_name()
            note_file = sharing_action.get_associated_file()
            self.assertTrue(note_file is None)
            self.assertEqual(note_name, actual_note_name)
            self.assertTrue(user_id in subscribers)
            subscribers.remove(user_id)
            self.assertEqual(SharingEvent.DELETE_NOTE,
                             sharing_action.get_action_type())
        self.assertEqual(0, len(subscribers))

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback=self.stop)
        self.wait()
        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            collection_name = sharing_action.get_collection_name()
            StorageServer.remove_collection(user_id, collection_name,
                                            callback=self.stop)
            self.wait()

    def test_create_related_actions_update_thumbnail(self):

        collection_name = 'sharing_collection'
        subscribers = [self.__subscriber_id]
        sharing_secret = \
            self.__create_sharing_record(subscribers, collection_name)
        subscribers.append(self.__account_id)

        test_file = open('../test_resources/XooML.xml')
        thumbnail_action = UpdateSharedThumbnailAction(self.__account_id,
                                                       collection_name, test_file)
        SharingActionFactory.create_related_sharing_actions(sharing_secret,
                                                            thumbnail_action, callback=self.stop)
        sharing_action_list = self.wait()

        self.assertEqual(2, len(sharing_action_list))

        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            thumbnail_file = sharing_action.get_associated_file()
            self.assertTrue(thumbnail_file is not None)
            self.assertTrue(user_id in subscribers)
            subscribers.remove(user_id)
            self.assertEqual(SharingEvent.UPDATE_THUMBNAIL,
                             sharing_action.get_action_type())
        self.assertEqual(0, len(subscribers))

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback=self.stop)
        self.wait()
        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            collection_name = sharing_action.get_collection_name()
            StorageServer.remove_collection(user_id, collection_name,
                                            callback=self.stop)
            self.wait()

    def test_create_related_actions_invalid_sharing_secret(self):

        collection_name = 'dummy'
        test_file = open('../test_resources/XooML.xml')
        manifest_action = UpdateSharedManifestAction(self.__account_id,
                                                     collection_name, test_file)
        SharingActionFactory.create_related_sharing_actions('dummy',
                                                            manifest_action, callback=self.stop)
        sharing_action_list = self.wait()
        self.assertTrue(sharing_action_list is None)

    def test_create_related_actions_send_diff_file(self):

        collection_name = 'sharing_collection'
        subscribers = [self.__subscriber_id]
        sharing_secret = \
            self.__create_sharing_record(subscribers, collection_name)
        subscribers.append(self.__account_id)

        test_file = open('../test_resources/XooML.xml')
        diff_action = SendDiffFileAction(self.__account_id, collection_name, test_file, 'XooML.xml')

        SharingActionFactory.create_related_sharing_actions(sharing_secret,
                                                            diff_action,
                                                            callback=self.stop)
        sharing_action_list = self.wait()

        self.assertEqual(2, len(sharing_action_list))

        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            self.assertTrue(user_id in subscribers)
            subscribers.remove(user_id)
            self.assertEqual(SharingEvent.SEND_DIFF_FILE,
                             sharing_action.get_action_type())
        self.assertEqual(0, len(subscribers))

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback=self.stop)
        self.wait()
        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            collection_name = sharing_action.get_collection_name()
            StorageServer.remove_collection(user_id, collection_name,
                                            callback=self.stop)
            self.wait()

    def test_create_related_actions_custom_message(self):
        collection_name = 'sharing_collection'
        subscribers = [self.__subscriber_id]
        sharing_secret = \
            self.__create_sharing_record(subscribers, collection_name)
        subscribers.append(self.__account_id)

        msg = 'custom_msg'
        msg_id = 'customMSGId'
        message_action = SendCustomMessageAction(self.__account_id, msg_id, collection_name, msg)

        SharingActionFactory.create_related_sharing_actions(sharing_secret,
                                                            message_action,
                                                            callback=self.stop)
        sharing_action_list = self.wait()

        self.assertEqual(2, len(sharing_action_list))

        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            self.assertTrue(user_id in subscribers)
            subscribers.remove(user_id)
            self.assertEqual(SharingEvent.SEND_CUSTOM_MSG,
                             sharing_action.get_action_type())
            self.assertEqual(msg,
                             sharing_action.get_custom_message())
            self.assertEqual(msg_id,
                             sharing_action.get_action_resource_name())
        self.assertEqual(0, len(subscribers))

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback=self.stop)
        self.wait()
        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            collection_name = sharing_action.get_collection_name()
            StorageServer.remove_collection(user_id, collection_name,
                                            callback=self.stop)
            self.wait()

    def test_created_related_actions_multiple_subscribers(self):

        collection_name = 'sharing_collection'
        subscribers = [self.__subscriber_id, self.__second_subscriber]
        sharing_secret = \
            self.__create_sharing_record(subscribers, collection_name)
        subscribers.append(self.__account_id)

        test_file = open('../test_resources/XooML.xml')
        manifest_action = UpdateSharedManifestAction(self.__account_id,
                                                     collection_name, test_file)
        SharingActionFactory.create_related_sharing_actions(sharing_secret,
                                                            manifest_action, callback=self.stop)
        sharing_action_list = self.wait()

        self.assertEqual(3, len(sharing_action_list))

        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            self.assertTrue(user_id in subscribers)
            subscribers.remove(user_id)
            self.assertEqual(SharingEvent.UPDATE_MANIFEST,
                             sharing_action.get_action_type())
        self.assertEqual(0, len(subscribers))

        #cleanup
        SharingController.remove_sharing_record_by_secret(sharing_secret, callback=self.stop)
        self.wait()
        for sharing_action in sharing_action_list:
            user_id = sharing_action.get_user_id()
            collection_name = sharing_action.get_collection_name()
            StorageServer.remove_collection(user_id, collection_name,
                                            callback=self.stop)
            self.wait()
