"""
Mocking handlers
"""
from tornado import gen
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from Storage.StorageServer import StorageServer


class CollectionHandler(tornado.web.RequestHandler):

    def get(self, word):
        self.write('all the collections')
        print "GET"
        print word

    def post(self, word):
        print "POST"
        print word

    @tornado.web.asynchronous
    @gen.engine
    def put(self, user_id, collection_name):
        new_collection_name = self.get_argument('collectionName')
        result_code = yield gen.Task(StorageServer.rename_collection, user_id, collection_name, new_collection_name)
        self.set_status(result_code)
        self.finish()

    @tornado.web.asynchronous
    @gen.engine
    def delete(self, user_id, collection_name):
        result_code = yield gen.Task(StorageServer.remove_collection, user_id, collection_name)
        self.set_status(result_code)
        self.finish()

if __name__ == "__main__":
    print 'hi'
