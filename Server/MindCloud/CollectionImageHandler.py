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
        pass

    def post(self, user_id, collection_name):
        pass

