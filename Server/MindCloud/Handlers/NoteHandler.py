import tornado
from Logging import Log
from Storage.StorageServer import StorageServer
import urllib2
from tornado import gen
from Storage.StorageResponse import StorageResponse
import json
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web

class NoteHandler(tornado.web.RequestHandler):
    """
    Handles actions relating to the notes in a collection collectively
    """

    __log = Log.log()

    @tornado.web.asynchronous
    @gen.engine
    def get(self, user_id, collection_name, note_name):


        self.__log.info('%s - GET: get note %s for collection %s for user %s' % (str(self.__class__), note_name, collection_name, user_id))

        collection_name = urllib2.unquote(collection_name)
        note_name = urllib2.unquote(note_name)

        note_file = yield gen.Task(StorageServer.get_note_from_collection,
            user_id, collection_name, note_name)
        if note_file is None:
            self.set_status(StorageResponse.NOT_FOUND)
        else:
            self.write(note_file.read())
            self.set_header('Content-Type', 'application/xml')
        self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def delete(self, user_id, collection_name, note_name):

        self.__log.info('%s - DELETE: delete note %s for collection %s for user %s' % (str(self.__class__), note_name, collection_name, user_id))

        collection_name = urllib2.unquote(collection_name)
        note_name = urllib2.unquote(note_name)
        result_code = yield gen.Task(StorageServer.remove_note, user_id, collection_name, note_name)
        self.set_status(result_code)
        self.finish()
