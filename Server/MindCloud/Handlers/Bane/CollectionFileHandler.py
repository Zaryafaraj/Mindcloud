__author__ = 'afathali'

import urllib2
from tornado import gen
import tornado.web
from Logging import Log
from Storage.StorageServer import StorageServer
from Storage.StorageResponse import StorageResponse


class CollectionFileHandler(tornado.web.RequestHandler):

    __log = Log.log()

    @tornado.web.asynchronous
    @gen.engine
    def get(self, user_id, collection_name, file_name):
        self.__log.info("CollectionFileHandler - GET: collectionName = %s , user_id = %s , file_name = %s" %
                        (collection_name, user_id, file_name))

        collection_name = urllib2.unquote(collection_name)
        file_name = urllib2.unquote(file_name)
        result = yield gen.Task(StorageServer.get_collection_file, user_id, collection_name, file_name)
        if result is not None:
            self.set_status(StorageResponse.OK)
            self.set_header('Content-Type', 'application/octet-stream')
            self.write(result.read())
        else:
            self.set_status(StorageResponse.NOT_FOUND)

        self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def delete(self, user_id, collection_name, file_name):
        self.__log.info("CollectionFileHandler - DELETE: collectionName = %s , user_id = %s , file_name = %s" %
                        (collection_name, user_id, file_name))
        collection_name = urllib2.unquote(collection_name)
        file_name = urllib2.unquote(file_name)
        result_code = yield gen.Task(StorageServer.remove_collection_file, user_id, collection_name, file_name)
        self.set_status(result_code)
        self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def post(self, user_id, collection_name):

        file_name = self.get_argument('fileName')

        if file_name is None:
            self.set_status(StorageResponse.BAD_REQUEST)
            self.finish()
        else:
            self.__log.info("CollectionFileHandler - POST: collectionName = %s , user_id = %s , file_name = %s" %
                            (collection_name, user_id, file_name))

            collection_name = urllib2.unquote(collection_name)
            file_name = urllib2.unquote(file_name)

            if len(self.request.files) > 0:
                collection_file = self.request.files.popitem()[1][0]
                #add talking with joker here based on CollectionHandler
                result_code = yield gen.Task(StorageServer.set_collection_file, user_id, collection_name, file_name,
                                             collection_file)
                self.set_status(result_code)
                self.finish()
            else:
                self.set_status(StorageResponse.BAD_REQUEST)
                self.finish()
