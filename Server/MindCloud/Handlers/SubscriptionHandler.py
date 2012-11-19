import json
from tornado import gen
import tornado.web
from Sharing.SharingController import SharingController
from Storage.StorageResponse import StorageResponse

__author__ = 'afathali'

class SubscriptionHandler(tornado.web.RequestHandler):

    @tornado.web.asynchronous
    @gen.engine
    def post(self, user_id):

        sharing_secret = self.get_argument('sharingSecret')
        shared_collection = yield gen.Task\
            (SharingController.subscribe_to_sharing_space,
            user_id,
            sharing_secret)
        #TODO: maybe we could send back the response code
        if shared_collection is None:
            self.set_status(StorageResponse.SERVER_EXCEPTION)
            self.finish()
        else:
            json_str = json.dumps({'collection_name' : shared_collection})
            self.write(json_str)
            self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def delete(self, user_id):
        collection_name = self.get_argument('collectionName')

