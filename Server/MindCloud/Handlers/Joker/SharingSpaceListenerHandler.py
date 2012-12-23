from tornado import gen
import tornado.web
from Sharing.SharingSpaceStorage import SharingSpaceStorage

__author__ = 'afathali'

class SharingSpaceListenerHandler(tornado.web.RequestHandler):

    @tornado.web.asynchronous
    @gen.engine
    def post(self, sharing_secret):
        sharing_storage = SharingSpaceStorage.get_instance()
        sharing_space = sharing_storage.get_sharing_space(sharing_secret)
        if sharing_space is None:
            self.set_status(404)
            self.finish()
        else:
            user_id = self.get_argument('user_id')
            sharing_space.add_listener(user_id, request=self)

    @tornado.web.asynchronous
    @gen.engine
    def delete(self, sharing_secret):

        sharing_storage = SharingSpaceStorage.get_instance()
        sharing_space = sharing_storage.get_sharing_space(sharing_secret)
        if sharing_space is None:
            self.set_status(404)
            self.finish()
        else:
            user_id = self.get_argument('user_id')
            sharing_space.remove_listener(user_id, request=self)
