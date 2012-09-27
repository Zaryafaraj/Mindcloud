import json
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from Accounts import Accounts
from DropboxHelper import DropboxHelper
from dropbox import client, rest, session

class AccountHandler(tornado.web.RequestHandler):

    CONTENT_KEY = 'contents'
    PATH_KEY = 'path'
    IS_DIR = 'is_dir'

    def _get_storage(self, user_id):

        account_info = Accounts.get_account(user_id)
        if account_info is not None:
            key = account_info['ticket'][0]
            secret = account_info['ticket'][1]
            storage = DropboxHelper.create_client(key, secret)
            return storage

        else:
            return None

    def get(self, user_id):

        storage = self._get_storage(user_id)
        if storage is not  None:
            result = DropboxHelper.get_folders(storage, "/", user_id)
            json_str = json.dumps({'Collections': result})
            self.write(json_str)

    def post(self, user_id):

        collection_name = self.get_argument('collectionName')
        hasFile = self.get_argument('hasFile',default=False)

        storage = self._get_storage(user_id)
        if storage is not None:
            result_code = DropboxHelper.create_folder(storage, collection_name)
            self.set_status(result_code)

if __name__ == "__main__":
    print 'hi'
