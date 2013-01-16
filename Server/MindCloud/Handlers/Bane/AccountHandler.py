"""
Handler to all the requests to work with top level collections for a user
"""
from tornado import gen
from Logging import Log

__author__ = 'afathali'

import json
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from Storage.StorageServer import StorageServer

class AccountHandler(tornado.web.RequestHandler):
    """
    Main handler class that is responsible for user activities around his collections
    """

    __log = Log.log()
    @tornado.web.asynchronous
    @gen.engine
    def get(self, user_id):

        self.__log.info('Bane-AccountHandler - GET: retrieving collection list for user %s' % user_id)

        results = yield gen.Task(StorageServer.list_collections, user_id)
        json_str = json.dumps({'Collections': results})
        self.write(json_str)
        self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def post(self, user_id):

        self.__log.info('Bane-AccountHandler - POST:  adding collection for user %s' % user_id)

        #if we have a file
        file = None
        if len(self.request.files) > 0 :
            file = self.request.files['file'][0]
        collection_name = self.get_argument('collectionName')
        result_code = yield gen.Task(StorageServer.add_collection, user_id = user_id,
            collection_name = collection_name, file=file)
        self.set_status(result_code)
        self.finish()

if __name__ == "__main__":
    print 'hi'
