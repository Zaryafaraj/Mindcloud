"""
Created for Mindcloud
"""
__author__ = 'afathali'
import json
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from StorageServer import StorageServer

class CollectionImageHandler(tornado.web.RequestHandler):
    """
    Handles actions relating a collections thumbnail
    """
    def get(self, user_id, collection_name):
        thumbnail = StorageServer.get_thumbnail(user_id, collection_name)
        self.write(thumbnail.read())
        self.set_header('Content-Type', 'image/jpeg')

    def post(self, user_id, collection_name):

        #if there is an actual file
        if len(self.request.files) > 0:
            file = self.request.files['file'][0]
            result_code = StorageServer.add_thumbnail(user_id, collection_name, file)
            self.set_status(result_code)

