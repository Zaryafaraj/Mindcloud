import urllib2
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

__author__ = 'afathali'


from tornado import gen
import tornado.web
class NoteImageHandler(tornado.web.RequestHandler):

    @tornado.web.asynchronous
    @gen.engine
    def get(self, user_id, collection_name, note_name):

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

        collection_name = urllib2.unquote(collection_name)
        note_name = urllib2.unquote(note_name)
        if len(self.request.files) < 1:
            self.set_status(StorageResponse.BAD_REQUEST)
        else:
            note_img = self.request.files['file'][0]
            result_code = yield gen.Task(StorageServer.add_image_to_note,
                user_id, collection_name, note_name, note_img)
            self.set_status(result_code)
        self.finish()



