from tornado.ioloop import IOLoop
from tornado.testing import AsyncTestCase

__author__ = 'afathali'


class SharingSpaceTestcase(AsyncTestCase):

    def get_new_ioloop(self):
        return IOLoop.instance()

    def test_add_listeners(self):
        pass

    def test_add_many_listeners(self):
        pass

    def test_remove_listeners(self):
        pass

    def test_remove_non_existing_listener(self):
        pass

    def test_backup_placement_strategy_backup_recorded(self):
        pass

    def test_backup_placement_strategy_backup_empty(self):
        pass


