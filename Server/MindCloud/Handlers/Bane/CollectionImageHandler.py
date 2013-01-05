"""
Created for Mindcloud
"""
import urllib2
from tornado import gen
from Logging import Log
from Helpers.JokerHelper import JokerHelper
from Sharing.SharingController import SharingController
from Storage.StorageResponse import StorageResponse
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from Storage.StorageServer import StorageServer

class CollectionImageHandler(tornado.web.RequestHandler):
    """
    Handles actions relating a collections thumbnail
    """

    __log = Log.log()

    @tornado.web.asynchronous
    @gen.engine
    def get(self, user_id, collection_name):

        self.__log.info('%s - GET: get collection img for %s for user %s' % (str(self.__class__), collection_name, user_id))

        collection_name = urllib2.unquote(collection_name)
        thumbnail = yield gen.Task(StorageServer.get_thumbnail, user_id, collection_name)
        if thumbnail is None:
            self.set_status(StorageResponse.NOT_FOUND)
        else:
            self.write(thumbnail.read())
            self.set_header('Content-Type', 'image/jpeg')
        self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def post(self, user_id, collection_name):

        self.__log.info('%s - SET: set collection img for %s for user %s' % (str(self.__class__), collection_name, user_id))

        collection_name = urllib2.unquote(collection_name)
        #if there is an actual file
        if len(self.request.files) > 0:
            file = self.request.files['file'][0]

            sharing_secret = yield gen.Task(SharingController.get_sharing_secret_from_subscriber_info,
                user_id, collection_name)
            if sharing_secret is None:
                #its not shared
                result_code = yield gen.Task(StorageServer.add_thumbnail, user_id, collection_name, file)
                self.set_status(result_code)
            else:
                #its shared
                joker_helper = JokerHelper.get_instance()
                sharing_server =\
                yield gen.Task(joker_helper.get_sharing_space_server, sharing_secret)
                if sharing_server is None:
                    #sharing server could not be found just update it locally
                    self.__log.info('Collection Thumbnail Handler - POST: sharing server not found for %s; performing updates locally' % sharing_secret)
                    result_code = yield gen.Task(StorageServer.add_thumbnail, user_id, collection_name, file)
                    self.set_status(result_code)
                else:
                    result_code = yield gen.Task(joker_helper.update_thumbnail, sharing_server,
                        sharing_secret, user_id, collection_name, file)
                    self.set_status(result_code)
            self.finish()
        else:
            self.set_status(StorageResponse.BAD_REQUEST)
            self.finish()

