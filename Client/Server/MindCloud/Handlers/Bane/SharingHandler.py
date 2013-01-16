import json
import urllib2
from tornado import gen
import tornado.web
from Logging import Log
from Sharing.SharingController import SharingController
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

__author__ = 'afathali'

class SharingHandler(tornado.web.RequestHandler):

    __log = Log.log()

    @tornado.web.asynchronous
    @gen.engine
    def post(self, user_id, collection_name):

        self.__log.info('%s - POST: create sharing space for collection %s for user %s' % (str(self.__class__), collection_name, user_id))

        collection_name = urllib2.unquote(collection_name)
        does_exist = yield gen.Task(StorageServer.does_collection_exist,
                                    user_id, collection_name)
        if does_exist:
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
        else:
            self.set_status(StorageResponse.NOT_FOUND)
            self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def delete(self, user_id, collection_name):

        self.__log.info('%s - DELETE: delete sharing space for collection %s for user %s' % (str(self.__class__), collection_name, user_id))

        collection_name = urllib2.unquote(collection_name)

        yield gen.Task(SharingController.remove_sharing_record_by_owner_info,
                        user_id,
                        collection_name)
        self.set_status(StorageResponse.OK)
        self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def get(self, user_id, collection_name):

        self.__log.info('%s - GET: Get sharing space info for collection %s for user %s' % (str(self.__class__), collection_name, user_id))

        collection_name = urllib2.unquote(collection_name)

        does_exist = yield gen.Task(StorageServer.does_collection_exist,
            user_id, collection_name)
        if does_exist:
            sharing_record = yield gen.Task(SharingController.get_sharing_record_by_owner_info,
                            user_id, collection_name)
            self.set_status(StorageResponse.OK)
            if sharing_record is not None:
                json_str = json.dumps(sharing_record.toDictionary())
                self.write(json_str)
                self.finish()
            else:
                self.set_status(StorageResponse.NOT_FOUND)
                self.finish()
        else:
            self.set_status(StorageResponse.NOT_FOUND)
            self.finish()