from Sharing.UpdateSharedManifestAction import UpdateSharedManifestAction
from Sharing.UpdateSharedNoteAction import UpdateSharedNoteAction
from Sharing.UpdateSharedNoteImageAction import UpdateSharedNoteImageAction
from Tests.TestingProperties import TestingProperties

__author__ = 'afathali'

from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

class SharingActionTestCase(AsyncTestCase):

    __account_id = TestingProperties.account_id
    __subscriber_id = TestingProperties.subscriber_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_update_sharing_manifest(self):

        #create collection
        first_collection_name = 'shareable_collection'
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=first_collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #update manifest
        file = open('../test_resources/XooML2.xml')
        update_manifest_action = UpdateSharedManifestAction(self.__account_id,first_collection_name, file)
        update_manifest_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, first_collection_name,
            callback=self.stop)
        self.wait()


    def test_update_sharing_manifest_non_existing_manifest(self):

        collection_name = 'collection_name'
        #update manifest
        file = open('../test_resources/XooML2.xml')
        update_manifest_action = UpdateSharedManifestAction(self.__account_id,
            collection_name, file)
        update_manifest_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()

    def test_update_sharing_manifest_repeatedly(self):

        collection_name = 'collection_name'

        #update manifest
        file = open('../test_resources/XooML2.xml')
        update_manifest_action = UpdateSharedManifestAction(self.__account_id,
            collection_name, file)
        for x in range(1,5):
            update_manifest_action.execute(callback=self.stop)
            response = self.wait()
            self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()

    def test_update_sharing_note(self):

        #create collection
        collection_name = 'shareable_collection'
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #add note
        note_name = "noteName"
        note_file = open('../test_resources/note.xml')
        StorageServer.add_note_to_collection(self.__account_id,
            collection_name, note_name, note_file, callback = self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #update note
        note_file = open('../test_resources/note2.xml')
        update_note_action = UpdateSharedNoteAction(self.__account_id, collection_name,
            note_name, note_file)
        update_note_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()


    def test_update_note_non_existing_note(self):

        note_name = 'note_name'
        collection_name = 'collection_name'
        #update note
        note_file = open('../test_resources/note2.xml')
        update_note_action = UpdateSharedNoteAction(self.__account_id, collection_name,
            note_name, note_file)
        update_note_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()

    def test_update_same_note_repeatedly(self):

        note_name = 'note_name'
        collection_name = 'collection_name'
        #update note
        note_file = open('../test_resources/note2.xml')
        update_note_action = UpdateSharedNoteAction(self.__account_id, collection_name,
            note_name, note_file)
        for x in range(1,5):
            update_note_action.execute(callback=self.stop)
            response = self.wait()
            self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()

    def test_update_different_notes_repeatedly(self):

        note_name = 'note_name'
        collection_name = 'collection_name'
        #update note
        note_file = open('../test_resources/note2.xml')
        for x in range(1,7):
            note_name += str(x)
            update_note_action = UpdateSharedNoteAction(self.__account_id, collection_name,
            note_name, note_file)
            update_note_action.execute(callback=self.stop)
            response = self.wait()
            self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()

    def test_update_note_img(self):

        #create collection
        collection_name = 'shareable_collection'
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #add note
        note_name = "noteName"
        note_file = open('../test_resources/note.xml')
        StorageServer.add_note_to_collection(self.__account_id,
            collection_name, note_name, note_file, callback = self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #add note image
        img_file = open('../test_resources/note_img.jpg')
        StorageServer.add_image_to_note(self.__account_id, collection_name,
            note_name, img_file, callback= self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #update note image
        img_file2 = open('../test_resources/note_img2.jpg')
        update_not_img_action = UpdateSharedNoteImageAction(self.__account_id, collection_name,
            note_name, img_file2)
        update_not_img_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()

    def test_update_note_img_non_existing_img(self):

        collection_name = 'collection_name'
        note_name = 'note_name'
        #update note image
        img_file2 = open('../test_resources/note_img2.jpg')
        update_not_img_action = UpdateSharedNoteImageAction(self.__account_id, collection_name,
            note_name, img_file2)
        update_not_img_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()

    def test_update_same_note_img_repetedly(self):

        collection_name = 'collection_name'
        note_name = 'note_name'
        #update note image
        img_file2 = open('../test_resources/note_img2.jpg')
        update_not_img_action = UpdateSharedNoteImageAction(self.__account_id, collection_name,
            note_name, img_file2)
        for x in range(1,5):
            update_not_img_action.execute(callback=self.stop)
            response = self.wait()
            self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()

    def test_update_different_note_imgs_repeatedly(self):

        collection_name = 'collection_name'
        note_name = 'note_name'
        #update note image
        for x in range(1,5):

            img_file2 = open('../test_resources/note_img2.jpg')
            note_name += str(x)
            update_not_img_action = UpdateSharedNoteImageAction(self.__account_id, collection_name,
                note_name, img_file2)
            update_not_img_action.execute(callback=self.stop)
            response = self.wait()
            self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()
