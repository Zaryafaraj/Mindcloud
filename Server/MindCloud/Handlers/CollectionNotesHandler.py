import tornado
from Storage.StorageServer import StorageServer

__author__ = 'afathali'
import urllib2
from tornado import gen
from Storage.StorageResponse import StorageResponse
import json
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web

class CollectionNotesHandler(tornado.web.RequestHandler):
    """
    Handles actions relating to the notes in a collection collectively
    """
    @tornado.web.asynchronous
    @gen.engine
    def get(self, user_id, collection_name):
       pass

    @tornado.web.asynchronous
    @gen.engine
    def post(self, user_id, collection_name):

        collection_name = urllib2.unquote(collection_name)
        note_file = None
        note_name = self.get_argument('noteName')
        #if there is an actual file
        if len(self.request.files) > 0:
            note_file = self.request.files['file'][0]
        result_code =yield gen.Task(StorageServer.add_note_to_collection,
            user_id, collection_name, note_name, note_file)
        self.set_status(result_code)
        self.finish()

