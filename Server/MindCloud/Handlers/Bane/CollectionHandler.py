import urllib2
from tornado import gen
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from Logging import Log
from Helpers.JokerHelper import JokerHelper
from Sharing.SharingController import SharingController
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer


class CollectionHandler(tornado.web.RequestHandler):

    __log = Log.log()

    @tornado.web.asynchronous
    @gen.engine
    def get(self, user_id, collection_name):

        self.__log.info('%s - GET: Get collection %s for user %s' % (str(self.__class__), collection_name, user_id))

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

        self.__log.info('%s - PUT: update collection %s for user %s' % (str(self.__class__), collection_name, user_id))

        collection_name = urllib2.unquote(collection_name)
        new_collection_name = self.get_argument('collectionName')
        result_code = yield gen.Task(StorageServer.rename_collection, user_id,
            collection_name, new_collection_name)

        if result_code == StorageResponse.OK:
            #try to update sharing records
            yield gen.Task(SharingController.rename_shared_collection, user_id,
                collection_name, new_collection_name)

        self.set_status(result_code)
        self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def delete(self, user_id, collection_name):

        self.__log.info('%s - DELETE: delete collection %s for user %s' % (str(self.__class__), collection_name, user_id))

        collection_name = urllib2.unquote(collection_name)
        result_code = yield gen.Task(StorageServer.remove_collection, user_id, collection_name)
        if result_code == StorageResponse.OK:
            #in case this was shared unsubscribe from the collection. The check for the existance of
            #the sharing record is done in the sharing controller
            yield gen.Task(SharingController.unsubscribe_from_sharing_space, user_id, collection_name)
        self.set_status(result_code)
        self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def post(self, user_id, collection_name):

        self.__log.info('%s-POST: post collection %s for user %s' % (str(self.__class__), collection_name, user_id))

        collection_name = urllib2.unquote(collection_name)
        if len(self.request.files) > 0:
            collection_file = self.request.files.popitem()[1][0]

            sharing_secret = yield gen.Task(SharingController.get_sharing_secret_from_subscriber_info,
                user_id, collection_name)

            if sharing_secret is None:
                #Its not shared
                result_code = yield gen.Task(StorageServer.
                save_collection_manifest, user_id, collection_name, collection_file)
                self.set_status(result_code)
            else:
                #Its shared it has to go to the corresponding sharing space
                #first figure out the sharing space server
                joker_helper = JokerHelper.get_instance()
                sharing_server = \
                    yield gen.Task(joker_helper.get_sharing_space_server, sharing_secret)
                if sharing_server is None:
                    #sharing server could not be found just update it locally
                    self.__log.info('Collection Handler - POST: sharing server not found for %s; performing updates locally' % sharing_secret)

                    result_code = yield gen.Task(StorageServer.
                        save_collection_manifest, user_id, collection_name, collection_file)
                    self.set_status(result_code)
                else:
                    result_code = yield gen.Task(joker_helper.update_manifest,
                        sharing_server, sharing_secret, user_id, collection_name,
                        collection_file)
                    self.set_status(result_code)
            self.finish()

        else:
            self.set_status(StorageResponse.BAD_REQUEST)
            self.finish()
