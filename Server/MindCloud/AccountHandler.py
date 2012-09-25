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

    def get(self, user_id):

        account_info = Accounts.get_account(user_id)
        if account_info is not None:
            key = account_info['ticket'][0]
            secret = account_info['ticket'][1]
            sess = DropboxHelper.create_session()
            sess.set_token(key, secret)
            db_client = client.DropboxClient(sess)
            try:
                metadata = db_client.metadata("/")
                contents = metadata[self.CONTENT_KEY]

                #Pythonic Zen master \m/
                #Filter the name of the folders from the root metadata
                result = [content[self.PATH_KEY].replace("/","") for content in contents if content[self.IS_DIR] == True]
                json_str = json.dumps({'Collections': result})
                self.write(json_str)

            except rest.ErrorResponse as exception:
                print exception.status + ": " + exception.error_msg



if __name__ == "__main__":
    print 'hi'
