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

    def _get_client(self, user_id):

        account_info = Accounts.get_account(user_id)
        if account_info is not None:
            key = account_info['ticket'][0]
            secret = account_info['ticket'][1]
            db_client = DropboxHelper.create_client(key, secret)
            return db_client

        else:
            return None

    def get(self, user_id):

        db_client = self._get_client(user_id)
        if db_client is not  None:
            try:
                metadata = db_client.metadata("/")
                contents = metadata[self.CONTENT_KEY]

                #Pythonic Zen master \m/
                #Filter the name of the folders from the root metadata
                result = [content[self.PATH_KEY].replace("/","") for content in contents if content[self.IS_DIR] == True]
                json_str = json.dumps({'Collections': result})
                self.write(json_str)

            except rest.ErrorResponse as exception:
                print "user: " + user_id + ": " + exception.status + ": " + exception.error_msg


    def post(self, user_id):

        collection_name = self.get_argument('collectionName')
        db_client = self._get_client(user_id)
        if db_client is not None:
            try:
                db_client.file_create_folder("/" + collection_name)
            except rest.ErrorResponse as exception:
                #if the folder already exists notify the user
                if exception.status == 403:
                    self.set_status(403)
                else:
                    print exception.status + ": " + exception.error_msg

if __name__ == "__main__":
    print 'hi'
