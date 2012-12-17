import json
from tornado import gen, web
import tornado
from Logging import Log
from Sharing.SharingController import SharingController
from Storage.StorageResponse import StorageResponse

__author__ = 'afathali'

class SharingSubscriptionHandler(tornado.web.RequestHandler):

    __log = Log.log()

    @tornado.web.asynchronous
    @gen.engine
    def post(self, user_id):


        sharing_secret = self.get_argument('sharing_secret')

        self.__log.info('%s - POST: User %s subscribes to sharing space with secret %s' % (str(self.__class__), user_id, sharing_secret))
        
        shared_collection = yield gen.Task\
            (SharingController.subscribe_to_sharing_space,
            user_id,
            sharing_secret)
        #TODO: maybe we could send back the response code
        if shared_collection is None:
            self.set_status(StorageResponse.NOT_FOUND)
            self.finish()
        else:
            json_str = json.dumps({'collection_name' : shared_collection})
            self.write(json_str)
            self.finish()

