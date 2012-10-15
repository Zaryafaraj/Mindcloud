from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from TornadoMain import Application

__author__ = 'afathali'

class CollectnTests(AsyncHTTPTestCase):

    account_id = '04B08CB7-17D5-493A-8ED1-E086FDC1327E'

    def get_new_ioloop(self):
        return IOLoop.instance()

    def get_app(self):
        application = Application()
        return application

    def test_rename_collection(self):

    def test_delete_collection(self):
        collectoin_name = str(uuid.uuid)


