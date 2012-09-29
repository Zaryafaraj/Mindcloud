"""
Handler to all the requests to work with top level collections for a user
"""
__author__ = 'afathali'

import json
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from StorageServer import StorageServer

class AccountHandler(tornado.web.RequestHandler):
    """
    Main handler class that is responsible for user activities around his collections
    """

    def get(self, user_id):

        results = StorageServer.list_collections(user_id)
        json_str = json.dumps({'Collections': results})
        self.write(json_str)

    def post(self, user_id):

        collection_name = self.get_argument('collectionName')
        result_code = StorageServer.add_collection(user_id, collection_name)
        self.set_status(result_code)

    def delete(self, user_id):
        collection_name = self.get_argument('collectionName')
        result_code = StorageServer.remove_collection(user_id, collection_name)
        self.set_status(result_code)



if __name__ == "__main__":
    print 'hi'
