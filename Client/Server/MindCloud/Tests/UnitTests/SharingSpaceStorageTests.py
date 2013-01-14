import cStringIO
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Sharing.SharingSpaceController import SharingSpaceController
from Sharing.SharingSpaceStorage import SharingSpaceStorage
from Sharing.UpdateSharedManifestAction import UpdateSharedManifestAction
from Sharing.UpdateSharedNoteAction import UpdateSharedNoteAction
from Sharing.UpdateSharedNoteImageAction import UpdateSharedNoteImageAction
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer
from Tests.TestingProperties import TestingProperties
from Tests.UnitTests.MockFactory import MockFactory

__author__ = 'afathali'

class SharingSpaceStorageTestcase(AsyncTestCase):


    __account_id = TestingProperties.account_id
    __subscriber_id = TestingProperties.subscriber_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_get_sharing_space_fresh(self):
        sharing_secret = 'XXXXXXX1'
        sharing_space_storage = SharingSpaceStorage.get_instance()
        sharing_space = \
            sharing_space_storage.get_sharing_space(sharing_secret)
        self.assertTrue(sharing_space is not None)
        self.assertTrue(isinstance(sharing_space,SharingSpaceController))
        sharing_space_storage.stop_cleanup_service()
        sharing_space_storage.clear()

    def test_get_Sharing_space_used(self):

        sharing_secret = 'XXXXXXX2'
        sharing_space_storage = SharingSpaceStorage.get_instance()
        sharing_space =\
            sharing_space_storage.get_sharing_space(sharing_secret)
        self.assertTrue(sharing_space is not None)
        self.assertTrue(isinstance(sharing_space,SharingSpaceController))

        sharing_space2 =\
            sharing_space_storage.get_sharing_space(sharing_secret)
        self.assertTrue(sharing_space2 is not None)
        self.assertTrue(isinstance(sharing_space2,SharingSpaceController))
        self.assertEqual(sharing_space, sharing_space2)
        sharing_space_storage.stop_cleanup_service()
        sharing_space_storage.clear()


    def test_cleanup_unused_space(self):

        sharing_secret = 'XXXXXXX3'
        #for testing set the sweep period low
        SharingSpaceStorage.SWEEP_PERIOD = 5
        sharing_space_storage = SharingSpaceStorage.get_instance()
        sharing_space_storage.reset_cleanup_timer()
        sharing_space = sharing_space_storage.get_sharing_space(sharing_secret)
        self.assertEqual(1, sharing_space_storage.get_sharing_space_count())

        #wait for the cleanup service

        try:
            self.wait(timeout=5)
        except Exception:
            pass

        self.assertEqual(1, sharing_space_storage.get_sharing_space_count())

        try:
            self.wait(timeout=11)
        except Exception:
            pass

        self.assertEqual(0, sharing_space_storage.get_sharing_space_count())
        sharing_space_storage.stop_cleanup_service()
        sharing_space_storage.clear()


    def test_cleanup_used_space(self):
        sharing_secret = 'XXXXXXX3'
        #for testing set the sweep period low
        SharingSpaceStorage.SWEEP_PERIOD = 5
        sharing_space_storage = SharingSpaceStorage.get_instance()
        sharing_space_storage.reset_cleanup_timer()
        sharing_space = sharing_space_storage.get_sharing_space(sharing_secret)
        self.assertEqual(1, sharing_space_storage.get_sharing_space_count())

        #wait for the cleanup service

        try:
            self.wait(timeout=5)
        except Exception:
            pass

        self.assertEqual(1, sharing_space_storage.get_sharing_space_count())
        sharing_space = sharing_space_storage.get_sharing_space(sharing_secret)

        try:
            self.wait(timeout=5)
        except Exception:
            pass

        sharing_space = sharing_space_storage.get_sharing_space(sharing_secret)

        try:
            self.wait(timeout=5)
        except Exception:
            pass
        self.assertEqual(1, sharing_space_storage.get_sharing_space_count())

        try:
            self.wait(timeout=11)
        except Exception:
            pass
        self.assertEqual(0, sharing_space_storage.get_sharing_space_count())
        sharing_space_storage.stop_cleanup_service()
        sharing_space_storage.clear()


    def test_recreated_cleanup_space(self):

        sharing_secret = 'XXXXXXX5'
        #for testing set the sweep period low
        SharingSpaceStorage.SWEEP_PERIOD = 5
        sharing_space_storage = SharingSpaceStorage.get_instance()
        sharing_space_storage.reset_cleanup_timer()
        sharing_space = sharing_space_storage.get_sharing_space(sharing_secret)
        self.assertEqual(1, sharing_space_storage.get_sharing_space_count())

        #wait for the cleanup service
        try:
            self.wait(timeout=15)
        except Exception:
            pass

        self.assertEqual(0, sharing_space_storage.get_sharing_space_count())
        sharing_space = sharing_space_storage.get_sharing_space(sharing_secret)
        self.assertEqual(1, sharing_space_storage.get_sharing_space_count())

        sharing_space_storage.stop_cleanup_service()
        sharing_space_storage.clear()


    def test_cleanup_unused_and_used_space(self):

        sharing_secret = 'XXXXXXX6'
        sharing_secret2 = 'YXXXXXXX'
        #for testing set the sweep period low
        SharingSpaceStorage.SWEEP_PERIOD = 5
        sharing_space_storage = SharingSpaceStorage.get_instance()
        sharing_space_storage.reset_cleanup_timer()
        sharing_space = sharing_space_storage.get_sharing_space(sharing_secret)
        sharing_space = sharing_space_storage.get_sharing_space(sharing_secret2)
        self.assertEqual(2, sharing_space_storage.get_sharing_space_count())

        #wait for the cleanup service

        try:
            self.wait(timeout=15)
        except Exception:
            pass

        cleanup_count = sharing_space_storage.get_sharing_space_count()
        print cleanup_count
        self.assertTrue(cleanup_count < 2)
        sharing_space = sharing_space_storage.get_sharing_space(sharing_secret)

        try:
            self.wait(timeout=7)
        except Exception:
            pass

        cleanup_count = sharing_space_storage.get_sharing_space_count()
        self.assertTrue(cleanup_count < 2)
        sharing_space = sharing_space_storage.get_sharing_space(sharing_secret)

        try:
            self.wait(timeout=5)
        except Exception:
            pass

        cleanup_count = sharing_space_storage.get_sharing_space_count()
        self.assertTrue(cleanup_count < 2)

        try:
            self.wait(timeout=11)
        except Exception:
            pass
        self.assertEqual(0, sharing_space_storage.get_sharing_space_count())
        sharing_space_storage.stop_cleanup_service()
        sharing_space_storage.clear()


    def test_cleanup_candidate_is_being_processed(self):

        sharing_secret = 'XXXXXXX7'
        #for testing set the sweep period low
        SharingSpaceStorage.SWEEP_PERIOD = 2
        sharing_space_storage = SharingSpaceStorage.get_instance()
        sharing_space_storage.reset_cleanup_timer()
        sharing_space = sharing_space_storage.get_sharing_space(sharing_secret)
        #make the sharing_space busy
        self.__load_test(sharing_space, 20,10, 10, 0)

        self.assertEqual(1, sharing_space_storage.get_sharing_space_count())

        #wait for the cleanup service

        try:
            self.wait(timeout=3)
        except Exception:
            pass
        self.assertEqual(1, sharing_space_storage.get_sharing_space_count())

        try:
            self.wait(timeout=30)
        except Exception:
            pass
        self.assertEqual(0, sharing_space_storage.get_sharing_space_count())
        sharing_space_storage.stop_cleanup_service()
        sharing_space_storage.clear()



    def test_cleanup_nothing_is_there(self):

        #for testing set the sweep period low
        SharingSpaceStorage.SWEEP_PERIOD = 5
        sharing_space_storage = SharingSpaceStorage.get_instance()
        sharing_space_storage.reset_cleanup_timer()
        self.assertEqual(0, sharing_space_storage.get_sharing_space_count())

        #wait for the cleanup service
        try:
            self.wait(timeout=10)
        except Exception:
            pass

        self.assertEqual(0, sharing_space_storage.get_sharing_space_count())
        sharing_space_storage.stop_cleanup_service()
        sharing_space_storage.clear()



    def __create_collection(self, account_id, collection_name):

        file = open('../test_resources/XooML.xml')
        StorageServer.add_collection(user_id= account_id,
            collection_name=collection_name, callback=self.stop, file= file)
        response = self.wait(timeout=100)
        self.assertEqual(StorageResponse.OK, response)

    def __load_test(self, sharing_space, manifest_count, note_count, busy_wait_cycle, acceptable_invalids):

        self.__load_finished = False
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

        #cleanup
        self.__remove_collection(self.__account_id, collection_name1)
        self.__remove_collection(self.__subscriber_id, collection_name2)

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
