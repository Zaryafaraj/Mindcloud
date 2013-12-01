__author__ = 'afathali'

import urllib2
from tornado import gen
import tornado.web
from Logging import Log
from Storage.StorageServer import StorageServer
from Storage.StorageResponse import StorageResponse
from Sharing.SharingController import SharingController


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
        #optional parameter. If the user has sent it we will save the file
        # to send the subscribers workspace
        sharing_secret = self.get_argument('sharing_secret', default=None)

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
                result_code = yield gen.Task(StorageServer.set_collection_file,
                                             user_id,
                                             collection_name,
                                             file_name,
                                             collection_file)
                self.set_status(result_code)
                self.finish()

                #if we managed to save the file for one user, we need to save it for all the users
                #since file saves don't go to joker (since they are heavy & their sharing
                # is done by sending diff files). We do it here.
                if result_code == StorageResponse.OK:
                    #first get a list of all subscriber
                    if sharing_secret is not None:
                        sharing_record = yield gen.Task(
                            SharingController.get_sharing_record_by_secret, sharing_secret)
                        if sharing_record is not None:
                            subscribers = sharing_record.get_subscribers()
                            if subscribers is not None:
                                for subscriber_info in subscribers:
                                    subscriber_id = subscriber_info[0]
                                    subscriber_collection = subscriber_info[1]
                                    #fire and forget
                                    StorageServer.set_collection_file(subscriber_id,
                                                                      subscriber_collection,
                                                                      file_name,
                                                                      collection_file)

            else:
                self.set_status(StorageResponse.BAD_REQUEST)
                self.finish()
