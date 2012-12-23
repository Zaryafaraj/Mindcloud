from tornado import gen
import tornado.web
from Sharing.SharingSpaceStorage import SharingSpaceStorage

__author__ = 'afathali'

class SharingSpaceActionHandler(tornado.web.RequestHandler):

    @tornado.web.asynchronous
    @gen.engine
    def post(self, sharing_secret):

        sharing_space = SharingSpaceStorage.get_sharing_space(sharing_secret)
        action = SharingActionFactory



