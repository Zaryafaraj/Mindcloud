import json
import urllib2
from tornado import gen
import tornado.web
from Sharing.SharingController import SharingController
from Storage.StorageResponse import StorageResponse

__author__ = 'afathali'

class SharingHandler(tornado.web.RequestHandler):

    @tornado.web.asynchronous
    @gen.engine
    def post(self, user_id, collection_name):

        collection_name = urllib2.unquote(collection_name)
        sharing_secret = yield gen.Task(SharingController.create_sharing_record,
                                        user_id, collection_name)
        if sharing_secret is None:
            self.set_status(StorageResponse.SERVER_EXCEPTION)
            self.finish()
        else:
            json_str = json.dumps({'sharing_secret':sharing_secret})
            self.set_status(StorageResponse.OK)
            self.write(json_str)
            self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def delete(self, user_id, collection_name):

        collection_name = urllib2.unquote(collection_name)
        yield gen.Task(SharingController.remove_sharing_record,
                        user_id,
                        collection_name)
        self.set_status(StorageResponse.OK)
        self.finish()



