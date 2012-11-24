import urllib2
from tornado import gen
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from Sharing.SharingController import SharingController
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer


class CollectionHandler(tornado.web.RequestHandler):


    @tornado.web.asynchronous
    @gen.engine
    def get(self, user_id, collection_name):

        collection_name = urllib2.unquote(collection_name)
        result = yield gen.Task(StorageServer.get_collection_manifest, user_id, collection_name)
        if result is not None:
            self.set_status(StorageResponse.OK)
            self.set_header('Content-Type', 'application/xml')
            self.write(result.read())
        else:
            self.set_status(StorageResponse.NOT_FOUND)

        self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def put(self, user_id, collection_name):

        collection_name = urllib2.unquote(collection_name)
        new_collection_name = self.get_argument('collectionName')
        result_code = yield gen.Task(StorageServer.rename_collection, user_id, collection_name, new_collection_name)
        self.set_status(result_code)
        self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def delete(self, user_id, collection_name):

        collection_name = urllib2.unquote(collection_name)
        result_code = yield gen.Task(StorageServer.remove_collection, user_id, collection_name)
        #in case this was shared unsubscribe from the collection. The check for the existance of
        #the sharing record is done in the sharing controller
        yield gen.Task(SharingController.unsubscribe_from_sharing_space, user_id, collection_name)
        self.set_status(result_code)
        self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def post(self, user_id, collection_name):

        collection_name = urllib2.unquote(collection_name)
        if len(self.request.files) > 0:
            collection_file = self.request.files['file'][0]
            result_code = yield gen.Task(StorageServer.
            save_collection_manifest, user_id, collection_name, collection_file)
            self.set_status(result_code)
        else:
            self.set_status(StorageResponse.BAD_REQUEST)
        self.finish()
