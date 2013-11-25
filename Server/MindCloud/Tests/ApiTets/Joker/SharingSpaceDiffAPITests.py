import json
import random
import urllib
from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from Sharing.SharingEvent import SharingEvent
from Sharing.SharingSpaceStorage import SharingSpaceStorage
from Storage.StorageResponse import StorageResponse
from Tests.ApiTets.HTTPHelper import HTTPHelper
from Tests.TestingProperties import TestingProperties
from TornadoMain import Application

__author__ = 'afathali'


class SharingSpaceDiffAPITests(AsyncHTTPTestCase):

    account_id = TestingProperties.account_id
    subscriber_id = TestingProperties.subscriber_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def get_app(self):
        application = Application()
        return application
