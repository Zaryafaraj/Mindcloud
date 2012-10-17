from tornado import gen
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

class CategoriesHandler(tornado.web.RequestHandler):
    """
    Main handler class for all things related to the categories
    """

    @tornado.web.asynchronous
    @gen.engine
    def post(self, user_id):

        if len(self.request.files) > 0:
            categories_file = self.request.files['file'][0]
            result_code = yield gen.Task(StorageServer.save_categories,
                user_id, categories_file)
            self.set_status(result_code)
            self.finish()
        else:
            self.set_status(StorageResponse.BAD_REQUEST)

