import urllib2
from Logging import Log
from Helpers.JokerHelper import JokerHelper
from Sharing.SharingController import SharingController
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

__author__ = 'afathali'


from tornado import gen
import tornado.web
class NoteImageHandler(tornado.web.RequestHandler):

    __log = Log.log()

    @tornado.web.asynchronous
    @gen.engine
    def get(self, user_id, collection_name, note_name):

        self.__log.info('%s - GET: get note img for note %s for collection %s for user %s' % (str(self.__class__), note_name, collection_name, user_id))

        collection_name = urllib2.unquote(collection_name)
        note_name = urllib2.unquote(note_name)

        note_image_file = yield gen.Task(StorageServer.get_note_image,
            user_id, collection_name, note_name)
        if note_image_file is None:
            self.set_status(StorageResponse.NOT_FOUND)
        else:
            self.write(note_image_file.read())
            self.set_status(StorageResponse.OK)
            self.set_header('Content-Type', 'image/jpeg')
        self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def post(self, user_id, collection_name, note_name):

        self.__log.info('%s - POST: save note img for note %s for collection %s for user %s' % (str(self.__class__), note_name, collection_name, user_id))

        collection_name = urllib2.unquote(collection_name)
        note_name = urllib2.unquote(note_name)
        if len(self.request.files) < 1:
            self.set_status(StorageResponse.BAD_REQUEST)
        else:
            note_img = self.request.files.popitem()[1][0]

            sharing_secret = yield gen.Task(SharingController.get_sharing_secret_from_subscriber_info,
                user_id, collection_name)
            if sharing_secret is None:
                #its not shared
                result_code = yield gen.Task(StorageServer.add_image_to_note,
                    user_id, collection_name, note_name, note_img)
                self.set_status(result_code)
            else:

                joker_helper = JokerHelper.get_instance()
                sharing_server =\
                yield gen.Task(joker_helper.get_sharing_space_server, sharing_secret)
                if sharing_server is None:
                    #sharing server could not be found just update it locally
                    self.__log.info('Note img Handler - POST: sharing server not found for %s; performing updates locally' % sharing_secret)
                    result_code = yield gen.Task(StorageServer.add_image_to_note,
                        user_id, collection_name, note_name, note_img)
                    self.set_status(result_code)
                else:
                    result_code = yield gen.Task(joker_helper.update_note_image, sharing_server,
                        sharing_secret, user_id, collection_name, note_name, note_img)
                    self.set_status(result_code)
        self.finish()
