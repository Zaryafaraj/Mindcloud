"""
Mocking handlers
"""
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from MindCloud.StorageServer import StorageServer


class CollectionHandler(tornado.web.RequestHandler):

    def get(self, word):
        self.write('all the collections')
        print "GET"
        print word

    def post(self, word):
        print "POST"
        print word

    def put(self, user_id, collection_name):
        new_collection_name = self.get_argument('collection_name')
        result_code = StorageServer.rename_collection(user_id, collection_name, new_collection_name)
        self.set_status(result_code)

    def delete(self, user_id, collection_name):
        result_code = StorageServer.remove_collection(user_id, collection_name)
        self.set_status(result_code)

if __name__ == "__main__":
    print 'hi'
