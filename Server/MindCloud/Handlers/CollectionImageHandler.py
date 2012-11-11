"""
Created for Mindcloud
"""
from tornado import gen
from Storage.StorageResponse import StorageResponse

__author__ = 'afathali'
import json
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from Storage.StorageServer import StorageServer

class CollectionImageHandler(tornado.web.RequestHandler):
    """
    Handles actions relating a collections thumbnail
    """
    @tornado.web.asynchronous
    @gen.engine
    def get(self, user_id, collection_name):
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

        #if there is an actual file
        if len(self.request.files) > 0:
            file = self.request.files['file'][0]
            result_code = yield gen.Task(StorageServer.add_thumbnail, user_id, collection_name, file)
            self.set_status(result_code)
            self.finish()
        else:
            self.set_status(StorageResponse.BAD_REQUEST)
            self.finish()

