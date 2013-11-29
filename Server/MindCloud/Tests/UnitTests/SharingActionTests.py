from Sharing.DeleteSharedNoteAction import DeleteSharedNoteAction
from Sharing.UpdateSharedManifestAction import UpdateSharedManifestAction
from Sharing.UpdateSharedNoteAction import UpdateSharedNoteAction
from Sharing.UpdateSharedNoteImageAction import UpdateSharedNoteImageAction
from Sharing.UpdateSharedThumbnailAction import UpdateSharedThumbnailAction
from Sharing.SendDiffFileAction import SendDiffFileAction
from Sharing.SendCustomMessageAction import SendCustomMessageAction
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
        test_file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
                                     collection_name=first_collection_name, callback=self.stop, file=test_file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #update manifest
        test_file = open('../test_resources/XooML2.xml')
        update_manifest_action = UpdateSharedManifestAction(self.__account_id, first_collection_name, test_file)
        update_manifest_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, first_collection_name,
                                        callback=self.stop)
        self.wait()

    def test_send_diff(self):

        #create collection
        first_collection_name = 'shareable_collection'
        test_file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
                                     collection_name=first_collection_name, callback=self.stop, file=test_file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        test_file = open('../test_resources/XooML2.xml')
        send_diff_action = SendDiffFileAction(self.__account_id, first_collection_name, test_file, 'XooML.xml')
        send_diff_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

    def test_send_custom_message(self):

        #create collection
        first_collection_name = 'shareable_collection'
        test_file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
                                     collection_name=first_collection_name, callback=self.stop, file=test_file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        send_msg_action = SendCustomMessageAction(self.__account_id, 'msgID', first_collection_name, 'msg')
        send_msg_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

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
        for x in range(1, 5):
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
                                     collection_name=collection_name, callback=self.stop, file=file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #add note
        note_name = "noteName"
        note_file = open('../test_resources/note.xml')
        StorageServer.add_note_to_collection(self.__account_id,
                                             collection_name, note_name, note_file, callback=self.stop)
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
        for x in range(1, 5):
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
        for x in range(1, 7):
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
                                     collection_name=collection_name, callback=self.stop, file=file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #add note
        note_name = "noteName"
        note_file = open('../test_resources/note.xml')
        StorageServer.add_note_to_collection(self.__account_id,
                                             collection_name, note_name, note_file, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #add note image
        img_file = open('../test_resources/note_img.jpg')
        StorageServer.add_image_to_note(self.__account_id, collection_name,
                                        note_name, img_file, callback=self.stop)
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
        for x in range(1, 5):
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
        for x in range(1, 5):
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

    def test_update_sharing_thumbnail(self):

        first_collection_name = 'shareable_collection_thumbnail'
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
                                     collection_name=first_collection_name, callback=self.stop, file=file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #add thumbnail
        file = open('../test_resources/note_img.jpg')
        StorageServer.add_thumbnail(self.__account_id, first_collection_name,
                                    file, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #update thumnail action
        file = open('../test_resources/note_img2.jpg')
        update_thumbnail_action = UpdateSharedThumbnailAction(self.__account_id,
                                                              first_collection_name, file)
        update_thumbnail_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, first_collection_name,
                                        callback=self.stop)
        self.wait()

    def test_update_sharing_thumbnail_non_existing_thumbnail(self):

        first_collection_name = 'shareable_collection_thumbnail'
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
                                     collection_name=first_collection_name, callback=self.stop, file=file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #update thumnail action
        file = open('../test_resources/note_img2.jpg')
        update_thumbnail_action = UpdateSharedThumbnailAction(self.__account_id,
                                                              first_collection_name, file)
        update_thumbnail_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, first_collection_name,
                                        callback=self.stop)
        self.wait()

    def test_update_sharing_thumbnail_repeatedly(self):

        first_collection_name = 'shareable_collection_thumbnail'
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
                                     collection_name=first_collection_name, callback=self.stop, file=file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        for x in range(3):
            #update thumnail action
            file = open('../test_resources/note_img2.jpg')
            update_thumbnail_action = UpdateSharedThumbnailAction(self.__account_id,
                                                                  first_collection_name, file)
            update_thumbnail_action.execute(callback=self.stop)
            response = self.wait()
            self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, first_collection_name,
                                        callback=self.stop)
        self.wait()

    def test_delete_shared_note(self):

        note_name = 'note_name'
        collection_name = 'collection_name'
        #update note
        note_file = open('../test_resources/note2.xml')
        update_note_action = UpdateSharedNoteAction(self.__account_id, collection_name,
                                                    note_name, note_file)
        update_note_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        delete_action = DeleteSharedNoteAction(self.__account_id,
                                               collection_name, note_name)
        delete_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
                                        callback=self.stop)
        self.wait()

    def test_delete_shared_note_non_existing_note(self):

        delete_action = DeleteSharedNoteAction(self.__account_id,
                                               'dummy', 'dummer')
        delete_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.NOT_FOUND, response)

    def test_double_deleting_shared_note(self):

        note_name = 'note_name'
        collection_name = 'collection_name'
        #update note
        note_file = open('../test_resources/note2.xml')
        update_note_action = UpdateSharedNoteAction(self.__account_id, collection_name,
                                                    note_name, note_file)
        update_note_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        delete_action = DeleteSharedNoteAction(self.__account_id,
                                               collection_name, note_name)
        delete_action.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        delete_action2 = DeleteSharedNoteAction(self.__account_id,
                                                collection_name, note_name)
        delete_action2.execute(callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.NOT_FOUND, response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
                                        callback=self.stop)
        self.wait()
