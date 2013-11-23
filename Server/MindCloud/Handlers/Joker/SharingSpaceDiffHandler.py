from tornado import gen
import tornado.web
from Logging import Log
from Sharing.SharingSpaceStorage import SharingSpaceStorage
from Sharing.SharingActionFactory import SharingActionFactory

__author__ = 'Fathalian'


class SharingSpaceDiffHandler(tornado.web.RequestHandler):
    __log = Log.log()

    @tornado.web.asynchronous
    @gen.engine
    def post(self, sharing_secret):

        #Check to see if there is a diff file
        user_id = self.get_argument('user_id', default=None)
        if len(self.request.files) == 0 or user_id is None:
            self.set_status(400)
            self.finish()
        else:
            diff_file = self.request.files.popitem()[1][0]
            SharingActionFactory.
            sharing_storage = SharingSpaceStorage.get_instance()
            sharing_space = sharing_storage.get_sharing_space(sharing_secret)
            self.__log.info(
                'SharingSpaceDiffHandler - Diff sent. sharing_secret=%s, user_id=%s' %
                (sharing_secret, user_id))
            #Notify the sharing space controller that there is a diff

        pass
