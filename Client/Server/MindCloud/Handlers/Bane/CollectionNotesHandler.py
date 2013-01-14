import tornado
from Logging import Log
from Helpers.JokerHelper import JokerHelper
from Sharing.SharingController import SharingController
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

    __log = Log.log()

    @tornado.web.asynchronous
    @gen.engine
    def get(self, user_id, collection_name):

        self.__log.info('%s - GET: get all notes for collection %s for user %s' % (str(self.__class__), collection_name, user_id))

        collection_name = urllib2.unquote(collection_name)
        results = yield gen.Task(StorageServer.list_all_notes, user_id, collection_name)
        json_str = json.dumps({'Notes': results})
        self.write(json_str)
        self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def post(self, user_id, collection_name):

        self.__log.info('%s - POST: Save note for collection %s for user %s' % (str(self.__class__), collection_name, user_id))

        collection_name = urllib2.unquote(collection_name)
        note_file = None
        note_name = self.get_argument('noteName')
        #if there is an actual file
        if len(self.request.files) > 0:
            note_file = self.request.files['file'][0]


        sharing_secret = yield gen.Task(SharingController.get_sharing_secret_from_subscriber_info,
            user_id, collection_name)
        if sharing_secret is None:
            #its not shared
            result_code =yield gen.Task(StorageServer.add_note_to_collection,
                user_id, collection_name, note_name, note_file)
            self.set_status(result_code)
        else:
            if note_file is None:
                self.__log.info('Collection Note Handler - POST: updating shared note with no file for %s' % sharing_secret)
                self.set_status(StorageResponse.BAD_REQUEST)

            else:
                #Its shared go the the corresponding sharing space
                joker_helper = JokerHelper.get_instance()
                sharing_server =\
                yield gen.Task(joker_helper.get_sharing_space_server, sharing_secret)
                if sharing_server is None:
                    #sharing server could not be found just update it locally
                    self.__log.info('Collection Note Handler - POST: sharing server not found for %s; performing updates locally' % sharing_secret)
                    result_code =yield gen.Task(StorageServer.add_note_to_collection,
                        user_id, collection_name, note_name, note_file)
                    self.set_status(result_code)
                else:
                    result_code = yield gen.Task(joker_helper.update_note, sharing_server,
                        sharing_secret, user_id, collection_name, note_name, note_file)
                    self.set_status(result_code)
        self.finish()

