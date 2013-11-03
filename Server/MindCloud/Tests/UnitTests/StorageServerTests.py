import uuid
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Storage.StorageResourceType import StorageResourceType
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer
from Tests.TestingProperties import TestingProperties

__author__ = 'afathali'

class StorageServerTests(AsyncTestCase):

    __account_id = TestingProperties.account_id
    __second_account_id = TestingProperties.subscriber_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_list_collections_valid_account(self):
        collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        StorageServer.list_collections(self.__account_id, callback=self.stop)
        collections = self.wait()
        self.assertTrue(len(collections) > 0)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()

    def test_list_collection_invalid_account(self):
        StorageServer.list_collections('dummy_user', callback=self.stop)
        collections = self.wait()
        self.assertTrue(len(collections) == 0)

    def test_does_collection_exist(self):
        collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageServer.does_collection_exist(self.__account_id, collection_name,
            callback= self.stop)
        response = self.wait()
        self.assertTrue(response)

        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()

    def test_does_collection_exist_invalid_collection(self):

        StorageServer.does_collection_exist(self.__account_id, 'dummy',
            callback= self.stop)
        response = self.wait()
        self.assertTrue(not response)

    def test_add_collection_with_no_file(self):
        collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()

    def test_add_collection_with_file(self):
        collection_name = str(uuid.uuid1())
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
        callback=self.stop)
        self.wait()

    def test_remove_collection_with_no_file(self):
        collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        StorageServer.remove_collection(self.__account_id,
            collection_name, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

    def test_remove_collection_with_file(self):
        collection_name = str(uuid.uuid1())
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=collection_name, callback=self.stop, file= file)
        response = self.wait(timeout=10)
        self.assertEqual(StorageResponse.OK, response)
        StorageServer.remove_collection(self.__account_id,
            collection_name, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

    def test_remove_invalid_collection(self):
        StorageServer.remove_collection(self.__account_id,
            'dummy_collection', callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.NOT_FOUND, response)

    def test_rename_collection_with_no_file(self):
        collection_name = str(uuid.uuid1())
        new_collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        StorageServer.rename_collection(self.__account_id,collection_name,
            new_collection_name, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        #cleanup
        StorageServer.remove_collection(self.__account_id, new_collection_name,
            callback=self.stop)
        self.wait()

    def test_rename_collection_with_file(self):
        collection_name = str(uuid.uuid1())
        new_collection_name = str(uuid.uuid1())
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        StorageServer.rename_collection(self.__account_id,collection_name,
            new_collection_name, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        #cleanup
        StorageServer.remove_collection(self.__account_id,
         new_collection_name, callback=self.stop)
        self.wait()

    def test_retrieve_renamed_collection(self):
        collection_name = str(uuid.uuid1())
        new_collection_name = str(uuid.uuid1())
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        StorageServer.rename_collection(self.__account_id,collection_name,
            new_collection_name, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        StorageServer.list_collections(self.__account_id, callback=self.stop)
        collections = self.wait()
        self.assertTrue(collection_name not in collections)
        self.assertTrue(new_collection_name in collections)
        #cleanup
        StorageServer.remove_collection(self.__account_id, new_collection_name,
            callback=self.stop)
        self.wait()

    def test_rename_invalid_collection(self):
        StorageServer.rename_collection(self.__account_id,'dummy',
            'dummy2', callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.NOT_FOUND, response)


    def test_add_thumbnail(self):
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
        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()

    def test_add_thumbnail_invalid_collection(self):
        thumbnail = open('../test_resources/thumbnail.jpg')
        StorageServer.add_thumbnail(self.__account_id, 'dummy', thumbnail,
            callback=self.stop)
        response = self.wait()
        #Accepted
        self.assertEqual(StorageResponse.OK, response)
        StorageServer.remove_collection(self.__account_id, 'dummy',
            callback=self.stop)
        self.wait()

    def test_get_thumbnail(self):
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
        StorageServer.get_thumbnail(self.__account_id, collection_name, callback=self.stop)
        response = self.wait()
        result_file = open('../test_resources/thumbnail2.jpg', 'w')
        result_file.write(response.read())
        response.close()
        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()

    def test_save_categories(self):
        collection_file = open('../test_resources/categories.xml')
        StorageServer.save_categories(self.__account_id, collection_file,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        #clean up
        StorageServer.remove_categories(self.__account_id, callback=self.stop)
        self.wait()

    def test_save_categories_with_existing_categories(self):
        collection_file = open('../test_resources/categories.xml')
        for i in range(1,5):
            StorageServer.save_categories(self.__account_id, collection_file,
                callback=self.stop)
            response = self.wait()
            self.assertEqual(StorageResponse.OK, response)
        #clean up
        StorageServer.remove_categories(self.__account_id, callback=self.stop)
        self.wait()

    def test_get_categories_with_existing_categories(self):

        collection_file = open('../test_resources/categories.xml')
        StorageServer.save_categories(self.__account_id, collection_file,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageServer.get_categories(self.__account_id, callback=self.stop)
        response = self.wait()
        self.assertTrue(response is not None)

        #clean up
        StorageServer.remove_categories(self.__account_id, callback=self.stop)
        self.wait()

    def test_get_categories_without_existing_categories(self):
        StorageServer.get_categories(self.__account_id, callback=self.stop)
        response = self.wait()
        self.assertTrue(response is not None)

        #clean up
        StorageServer.remove_categories(self.__account_id, callback=self.stop)
        self.wait()

    def test_save_collection_manifest(self):
        collection_name = "dummy"
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        collection_file = open('../test_resources/collection.xml')
        StorageServer.save_collection_manifest(self.__account_id,
            collection_name, collection_file, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_save_collection_manifest_invalid_collection(self):

        collection_name = 'non_existing'
        collection_file = open('../test_resources/collection.xml')
        StorageServer.save_collection_manifest(self.__account_id,
            collection_name, collection_file, callback=self.stop)
        response = self.wait()
        #Accepted
        self.assertEqual(StorageResponse.OK, response)
        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_update_collection_manifest(self):

        collection_name = 'non_existing'
        collection_file = open('../test_resources/collection.xml')
        StorageServer.save_collection_manifest(self.__account_id,
            collection_name, collection_file, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #update
        collection_file = open('../test_resources/collection2.xml')
        StorageServer.save_collection_manifest(self.__account_id,
            collection_name, collection_file, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_get_collection_manifest(self):
        collection_name = "dummy_test_get_collection"
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        collection_file = open('../test_resources/collection.xml')
        StorageServer.save_collection_manifest(self.__account_id,
            collection_name, collection_file, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageServer.get_collection_manifest(self.__account_id,
            collection_name, callback=self.stop)
        response = self.wait()
        self.assertTrue(response is not None)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_get_collection_manifest_non_existing(self):
        StorageServer.get_collection_manifest(self.__account_id,
            'dummy', callback=self.stop)
        response = self.wait()
        self.assertTrue(response is None)

    def test_add_note_to_collection(self):

        collection_name = "dummy"
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        note_name = "noteName"
        note_file = open('../test_resources/note.xml')
        StorageServer.add_note_to_collection(self.__account_id,
            collection_name, note_name, note_file, callback = self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_add_note_to_non_existing_collection(self):

        collection_name = 'col_name'
        note_name = 'noteName'
        note_file = open('../test_resources/note.xml')
        StorageServer.add_note_to_collection(self.__account_id,
            collection_name, note_name, note_file, callback = self.stop)
        response = self.wait()
        #Accepted
        self.assertEqual(StorageResponse.OK, response)
        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_add_note_to_collection_no_file(self):

        collection_name = 'col_name'
        note_name = 'noteName'
        StorageServer.add_note_to_collection(self.__account_id,
            collection_name, note_name, note_file=None, callback = self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_update_note(self):
        collection_name = 'col_name'
        note_name = 'noteName'
        note_file = open('../test_resources/note.xml')
        StorageServer.add_note_to_collection(self.__account_id,
            collection_name, note_name, note_file, callback = self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #update
        note_file = open('../test_resources/note2.xml')
        StorageServer.add_note_to_collection(self.__account_id,
            collection_name, note_name, note_file, callback = self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_get_note(self):

        collection_name = 'col_name'
        note_name = 'noteName'
        note_file = open('../test_resources/note.xml')
        StorageServer.add_note_to_collection(self.__account_id,
            collection_name, note_name, note_file, callback = self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        StorageServer.get_note_from_collection(self.__account_id,
            collection_name, note_name, callback=self.stop)
        response = self.wait()
        self.assertTrue(response is not None)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_existance_of_note_valid(self):
        collection_name = 'col_name'
        note_name = 'noteName'
        note_file = open('../test_resources/note.xml')
        StorageServer.add_note_to_collection(self.__account_id,
            collection_name, note_name, note_file, callback = self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #check the existance
        StorageServer.does_note_resource_exist(self.__account_id,
            collection_name, note_name, StorageResourceType.NOTE_MANIFEST,
            callback=self.stop)

        does_exist = self.wait()
        self.assertTrue(does_exist)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_existance_of_note_invalid(self):

        collection_name = 'col_name'
        note_name = 'noteName'
        StorageServer.add_note_to_collection(self.__account_id,
            collection_name, note_name, note_file=None, callback = self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #check
        StorageServer.does_note_resource_exist(self.__account_id,
            collection_name, note_name, StorageResourceType.NOTE_MANIFEST,
            callback=self.stop)

        does_exist = self.wait()
        self.assertTrue(not does_exist)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_get_non_existing_note(self):

        collection_name = 'col_name'
        note_name = 'noteName'
        StorageServer.get_note_from_collection(self.__account_id,
            collection_name, note_name, callback=self.stop)
        response = self.wait()
        self.assertTrue(response is None)

    def test_add_note_img_to_collection(self):

        #create note
        collection_name = 'col_name'
        note_name = 'noteName'
        note_file = open('../test_resources/note.xml')
        StorageServer.add_note_to_collection(self.__account_id,
            collection_name, note_name, note_file, callback = self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #add image
        img_file = open('../test_resources/note_img.jpg')
        StorageServer.add_image_to_note(self.__account_id, collection_name,
            note_name, img_file, callback= self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()


    def test_add_note_img_to_invalid_collection(self):

        #add image
        img_file = open('../test_resources/note_img.jpg')
        StorageServer.add_image_to_note(self.__account_id, 'dummy',
            'dummy', img_file, callback= self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #clean up
        StorageServer.remove_collection(self.__account_id, 'dummy', callback=self.stop)
        self.wait()

    def test_add_note_img_to_invalid_note(self):

        #create note
        collection_name = 'col_name'
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)


        #add image
        img_file = open('../test_resources/note_img.jpg')
        StorageServer.add_image_to_note(self.__account_id, collection_name,
            'dummy', img_file, callback= self.stop)
        response = self.wait()
        #expected
        self.assertEqual(StorageResponse.OK, response)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_add_note_img_to_note_with_existing_img(self):

        #create note
        collection_name = 'col_name'
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #add image
        note_name = 'dummy'
        img_file = open('../test_resources/note_img.jpg')
        StorageServer.add_image_to_note(self.__account_id, collection_name,
            note_name, img_file, callback= self.stop)
        response = self.wait()
        #expected
        self.assertEqual(StorageResponse.OK, response)

        img_file = open('../test_resources/note_img2.jpg')
        StorageServer.add_image_to_note(self.__account_id, collection_name,
            note_name, img_file, callback= self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_get_note_img(self):

        #add image
        img_file = open('../test_resources/note_img.jpg')
        collection_name = 'dummyCol'
        note_name = 'dummyNote'
        StorageServer.add_image_to_note(self.__account_id, collection_name,
            note_name, img_file, callback= self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #get image

        StorageServer.get_note_image(self.__account_id, collection_name,
            note_name, callback=self.stop)
        response = self.wait()
        self.assertTrue(response is not None)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_existance_of_note_img_valid(self):

        #add image
        img_file = open('../test_resources/note_img.jpg')
        collection_name = 'dummyCol'
        note_name = 'dummyNote'
        StorageServer.add_image_to_note(self.__account_id, collection_name,
            note_name, img_file, callback= self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #check for the exsistance
        StorageServer.does_note_resource_exist(self.__account_id,
            collection_name, note_name, StorageResourceType.NOTE_IMG, callback=self.stop)
        does_exist = self.wait()
        self.assertTrue(does_exist)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_existance_of_note_img_invalid(self):
        #create collection and note without image
        collection_name = 'col_name'
        note_name = 'noteName'
        StorageServer.add_note_to_collection(self.__account_id,
            collection_name, note_name, note_file=None, callback = self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #check for existance
        StorageServer.does_note_resource_exist(self.__account_id,
            collection_name, note_name, StorageResourceType.NOTE_IMG, callback=self.stop)
        does_exist = self.wait()
        self.assertTrue(not does_exist)


        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()


    def test_get_note_img_invalid_collection(self):

        StorageServer.get_note_image(self.__account_id, 'dummy',
            'dummy', callback=self.stop)
        response = self.wait()
        self.assertTrue(response is None)

    def test_get_note_img_invalid_note(self):

        #create note
        collection_name = 'col_name'
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageServer.get_note_image(self.__account_id, collection_name,
            'dummy', callback=self.stop)
        response = self.wait()
        self.assertTrue(response is None)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_get_note_img_a_note_with_no_img(self):

        collection_name = 'col_name'
        note_name = 'noteName'
        note_file = open('../test_resources/note.xml')
        StorageServer.add_note_to_collection(self.__account_id,
            collection_name, note_name, note_file, callback = self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)


        StorageServer.get_note_image(self.__account_id, collection_name,
            note_name, callback=self.stop)
        response = self.wait()
        self.assertTrue(response is None)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_list_all_notes(self):

        collection_name = 'col_name'
        note_name = 'noteName'
        note_file = open('../test_resources/note.xml')
        for i in range(1,5):
            new_note_name = note_name + str(i)
            StorageServer.add_note_to_collection(self.__account_id,
                collection_name, new_note_name, note_file, callback = self.stop)
            response = self.wait()
            self.assertEqual(StorageResponse.OK, response)

        StorageServer.list_all_notes(self.__account_id,
            collection_name, callback=self.stop)
        response = self.wait()
        self.assertEqual(4, len(response))

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_list_all_notes_invalid_collection(self):
        StorageServer.list_all_notes(self.__account_id,
            'dummy', callback=self.stop)
        response = self.wait()
        self.assertEqual(0, len(response))

    def test_list_all_notes_empty_collection(self):

        collection_name = "dummy"
        StorageServer.add_collection(self.__account_id, collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageServer.list_all_notes(self.__account_id,
            collection_name, callback=self.stop)
        response = self.wait()
        self.assertEqual(0, len(response))

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_remove_note(self):

        collection_name = 'col_name'
        note_name = 'noteName'
        note_file = open('../test_resources/note.xml')
        StorageServer.add_note_to_collection(self.__account_id,
            collection_name, note_name, note_file, callback = self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #remove
        StorageServer.remove_note(self.__account_id, collection_name,
            note_name, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #verify the delete
        StorageServer.list_all_notes(self.__account_id,
            collection_name, callback=self.stop)
        response = self.wait()
        self.assertEqual(0, len(response))
        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_remove_non_existing_note(self):

        collection_name = 'dummy'
        note_name = 'dummy'
        StorageServer.remove_note(self.__account_id, collection_name,
            note_name, callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.NOT_FOUND, response)

    def test_copy_collection_between_accounts(self):

        collection_name = str(uuid.uuid1())
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageServer.copy_collection_between_accounts(self.__account_id,
                                                        self.__second_account_id,
                                                        collection_name,
                                                        collection_name,
                                                        callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageServer.list_collections(self.__second_account_id,
                                        callback=self.stop)
        col_list = self.wait()
        self.assertTrue(collection_name in col_list)
        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()
        StorageServer.remove_collection(self.__second_account_id, collection_name,
            callback=self.stop)
        self.wait()

    def test_copy_collections_between_accounts_different_name(self):

        first_collection_name = str(uuid.uuid1())
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=first_collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        second_collection_name = str(uuid.uuid1())
        StorageServer.copy_collection_between_accounts(self.__account_id,
            self.__second_account_id,
            first_collection_name,
            second_collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageServer.list_collections(self.__second_account_id,
            callback=self.stop)
        col_list = self.wait()
        self.assertTrue(second_collection_name in col_list)
        #cleanup
        StorageServer.remove_collection(self.__account_id, first_collection_name,
            callback=self.stop)
        self.wait()
        StorageServer.remove_collection(self.__second_account_id, second_collection_name,
            callback=self.stop)
        self.wait()

    def test_copy_collection_with_notes_between_accounts(self):
        first_collection_name = str(uuid.uuid1())
        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id=self.__account_id,
            collection_name=first_collection_name, callback=self.stop, file= file)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)
        note_name = "noteName"
        note_file = open('../test_resources/note.xml')
        StorageServer.add_note_to_collection(self.__account_id,
            first_collection_name, note_name, note_file, callback = self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        second_collection_name = first_collection_name
        StorageServer.copy_collection_between_accounts(self.__account_id,
            self.__second_account_id,
            first_collection_name,
            second_collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageServer.list_collections(self.__second_account_id,
            callback=self.stop)
        col_list = self.wait()
        self.assertTrue(second_collection_name in col_list)

        StorageServer.list_all_notes(self.__second_account_id,
                                    second_collection_name,
                                    callback = self.stop)
        note_list = self.wait()
        self.assertTrue(note_name in note_list)

        #cleanup
        StorageServer.remove_collection(self.__account_id, first_collection_name,
            callback=self.stop)
        self.wait()
        StorageServer.remove_collection(self.__second_account_id, second_collection_name,
            callback=self.stop)
        self.wait()

    def test_copy_non_existing_collection_to_another_account(self):
        collection_name = str(uuid.uuid1())
        StorageServer.copy_collection_between_accounts(self.__account_id,
            self.__second_account_id,
            collection_name,
            collection_name,
            callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.NOT_FOUND, response)

    def test_save_collection_file(self):
        collection_name = "dummy123"
        StorageServer.add_collection(self.__account_id, collection_name,
                                     callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        collection_file = open('../test_resources/screen.drw')
        StorageServer.set_collection_file(self.__account_id, collection_name, 'screen.draw', collection_file,
                                          callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def  test_save_collection_file_non_existing_collection(self):
        collection_file = open('../test_resources/screen.drw')
        StorageServer.set_collection_file(self.__account_id, 'dumm', 'screen.draw', collection_file,
                                          callback=self.stop)
        response = self.wait()

        #expected behavior
        self.assertEqual(StorageResponse.OK, response)

        #clean up
        StorageServer.remove_collection(self.__account_id, 'dumm', callback=self.stop)
        self.wait()

    def test_save_collection_file_non_existing_user(self):

        collection_file = open('../test_resources/screen.drw')
        StorageServer.set_collection_file('teapot', 'xa', 'screen.draw', collection_file,
                                          callback=self.stop)
        response = self.wait()

        #fix this. We need to return 401
        self.assertEqual(StorageResponse.SERVER_EXCEPTION, response)

    def test_save_collection_file_invalid_filename(self):
        collection_file = open('../test_resources/screen.drw')
        StorageServer.set_collection_file(self.__account_id, 'xa', '../screen.draw', collection_file,
                                          callback=self.stop)
        response = self.wait()

        #fix this. We need to return 404
        self.assertEqual(StorageResponse.BAD_REQUEST, response)

    def test_get_collection_file(self):
        collection_name = "dummy423"
        StorageServer.add_collection(self.__account_id, collection_name,
                                     callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        collection_file = open('../test_resources/screen.drw')
        StorageServer.set_collection_file(self.__account_id, collection_name, 'screen.drw', collection_file,
                                          callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageServer.get_collection_file(self.__account_id, collection_name, 'screen.drw',
                                          callback=self.stop)
        response = self.wait()
        self.assertIsNotNone(response)
        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_get_collection_file_non_existing_collection(self):

        StorageServer.get_collection_file(self.__account_id, 'no_exist', 'screen.drw',
                                          callback=self.stop)
        response = self.wait()
        self.assertIsNone(response)

    def test_get_collection_file_non_existing_file(self):

        collection_name = "dummy423"
        StorageServer.add_collection(self.__account_id, collection_name,
                                     callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageServer.get_collection_file(self.__account_id, collection_name, 'screen.drw',
                                          callback=self.stop)
        response = self.wait()
        self.assertIsNone(response)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_get_collection_file_invalid_file_name(self):

        collection_name = "dummy523"
        StorageServer.add_collection(self.__account_id, collection_name,
                                     callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        collection_file = open('../test_resources/screen.drw')
        StorageServer.set_collection_file(self.__account_id, collection_name, 'screen.drw', collection_file,
                                          callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageServer.get_collection_file(self.__account_id, collection_name, './../' + collection_name + '/screen.drw',
                                          callback=self.stop)
        response = self.wait()
        self.assertIsNone(response)
        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_remove_collection_file(self):

        collection_name = "dummee435"
        StorageServer.add_collection(self.__account_id, collection_name,
                                     callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        collection_file = open('../test_resources/screen.drw')
        StorageServer.set_collection_file(self.__account_id, collection_name, 'screen.drw', collection_file,
                                          callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageServer.get_collection_file(self.__account_id, collection_name, 'screen.drw',
                                          callback=self.stop)
        response = self.wait()
        self.assertIsNotNone(response)

        StorageServer.remove_collection_file(self.__account_id, collection_name, 'screen.drw',
                                             callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageServer.get_collection_file(self.__account_id, collection_name, 'screen.drw',
                                          callback=self.stop)
        response = self.wait()
        self.assertIsNone(response)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

    def test_remove_collection_file_non_existing_collection(self):

        StorageServer.remove_collection_file(self.__account_id, 'zaza', 'screen.drw',
                                             callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.NOT_FOUND, response)

    def test_remove_collection_file_non_existing_file(self):

        collection_name = "Xdummee435"
        StorageServer.add_collection(self.__account_id, collection_name,
                                     callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.OK, response)

        StorageServer.remove_collection_file(self.__account_id, collection_name, 'screen.drw',
                                             callback=self.stop)
        response = self.wait()
        self.assertEqual(StorageResponse.NOT_FOUND, response)

        #clean up
        StorageServer.remove_collection(self.__account_id, collection_name, callback=self.stop)
        self.wait()

