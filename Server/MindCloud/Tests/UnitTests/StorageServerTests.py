import uuid
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

__author__ = 'afathali'

class StorageServerTests(AsyncTestCase):

    __account_id = '04B08CB7-17D5-493A-8ED1-E086FDC1327E'

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_list_collections_valid_account(self):
        StorageServer.list_collections(self.__account_id, callback=self.stop)
        collections = self.wait()
        self.assertTrue(len(collections) > 0)

    def test_list_collection_invalid_account(self):
        StorageServer.list_collections('dummy_user', callback=self.stop)
        collections = self.wait()
        self.assertTrue(len(collections) == 0)

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
        #StorageServer.remove_collection(self.__account_id, collection_name,
        #    callback=self.stop)
        #self.wait()

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
        response = self.wait()
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
        result_file = open('../test_resources/workfile.jpg', 'wr+')
        result_file.write(response.getvalue())
        response.close()
        #cleanup
        StorageServer.remove_collection(self.__account_id, collection_name,
            callback=self.stop)
        self.wait()

