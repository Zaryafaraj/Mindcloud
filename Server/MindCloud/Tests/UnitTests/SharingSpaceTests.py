import uuid
from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase
from Sharing.SharingSpaceController import SharingSpaceController
from Tests.UnitTests.MockFactory import MockFactory

__author__ = 'afathali'


class SharingSpaceTestcase(AsyncTestCase):

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

    #def test_backup_placement_strategy_backup_recorded(self):
    #    pass

    #def test_backup_placement_strategy_backup_empty(self):
    #    pass


