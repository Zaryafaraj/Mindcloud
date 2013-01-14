from tornado import gen
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from Logging import Log
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

class CategoriesHandler(tornado.web.RequestHandler):
    """
    Main handler class for all things related to the categories
    """

    __log = Log.log()
    @tornado.web.asynchronous
    @gen.engine
    def get(self, user_id):

        self.__log.info('%s - GET: Get categories for user %s' % (str(self.__class__), user_id))

        categories = yield gen.Task(StorageServer.get_categories, user_id)
        self.write(categories.read())
        self.set_header('Content-Type', 'text/xml')
        self.finish()

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
            self.finish()

