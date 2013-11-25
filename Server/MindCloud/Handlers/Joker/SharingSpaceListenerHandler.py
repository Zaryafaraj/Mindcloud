from tornado import gen
import tornado.web
from Logging import Log
from Sharing.SharingSpaceStorage import SharingSpaceStorage

__author__ = 'afathali'


class SharingSpaceListenerHandler(tornado.web.RequestHandler):
    __log = Log.log()

    @tornado.web.asynchronous
    @gen.engine
    def post(self, sharing_secret, user_id):

        print "XXXXXX"
        sharing_storage = SharingSpaceStorage.get_instance()
        is_valid = yield gen.Task(sharing_storage.validate_secret, sharing_secret)
        if is_valid:
            sharing_space = sharing_storage.get_sharing_space(sharing_secret)
            if sharing_space is None:
                self.set_status(404)
                self.finish()
            else:

                self.__log.info('SharingSpaceListener - adding user %s as listener to sharing space %s' %
                                (user_id, sharing_secret))
                sharing_space.add_listener(user_id, request=self)

        else:
            self.set_status(404)
            self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def delete(self, sharing_secret, user_id):

        sharing_storage = SharingSpaceStorage.get_instance()

        is_valid = yield gen.Task(sharing_storage.validate_secret,
                                  sharing_secret)
        if is_valid:
            sharing_space = sharing_storage.get_sharing_space(sharing_secret)
            if sharing_space is None:
                self.set_status(404)
                self.finish()
            else:
                try:

                    self.__log.info('SharingSpaceListener - removing user %s as listener from sharing space %s' % (
                        user_id, sharing_secret))
                    sharing_space.remove_listener(user_id)
                    self.set_status(200)
                    self.finish()
                except Exception:
                    self.set_status(400)
                    self.finish()
        else:
            self.set_status(404)
            self.finish()
