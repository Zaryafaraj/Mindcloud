from tornado import gen
import tornado.web
from Sharing.SharingSpaceStorage import SharingSpaceStorage

__author__ = 'afathali'

class SharingSpaceListenerHandler(tornado.web.RequestHandler):

    @tornado.web.asynchronous
    @gen.engine
    def post(self, sharing_secret):
        sharing_space = SharingSpaceStorage.get_sharing_space(sharing_secret)
        if sharing_space is None:
            self.set_status(404)
            self.finish()
        else:
            sharing_space.add_listener(request=self)
