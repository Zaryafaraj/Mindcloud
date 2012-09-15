import json
from threading import Timer
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from dropbox import session
import Accounts

class AuthorizationHandler(tornado.web.RequestHandler):

    __APP_KEY =  'h7f38af0ewivq6s'
    __APP_SECRET = 'iiq8oz2lae46mwp'
    __ACCESS_TYPE = 'app_folder'
    #duration before which a sweep gets performed
    __SWEEP_PERIOD = 30

    #active requests that pend user approval
    active_requests = {}
    #Sweep candidates
    sweep_candidates = []

    account_store = Accounts.Accounts()
    timer = None

    def sweep(self):
        """
        This is the sweep operation that gets called every __SWEEP_PERIOD.
        """
        print 'sweep started'
        print "pending authorizations: "
        print self.active_requests

        #Remove sweep candidates from the list of active requests
        for sweep_candidate in self.sweep_candidates:
            if self.active_requests.has_key(sweep_candidate):
                del self.active_requests[sweep_candidate]
                print 'removed: ' + sweep_candidate

        #clone the remaining active requests to delete in the next sweep
        self.sweep_candidates = list(self.active_requests.keys())

        #The timer stops after this function is finished. Create a new one if there are items still remaining
        #TODO there should be a better way to have a timer automatically call this function periodically
        if len(self.active_requests) > 0:
            self.timer = Timer(10,self.sweep)
            self.timer.start()
        #No need for timer when there are no pending requests
        else:
            self.timer = None

    def get(self, account_id):

        #FIXME what is the cost of making this object ?
        #Is it better to use a static function
        sess = session.DropboxSession(self.__APP_KEY,
                self.__APP_SECRET, self.__ACCESS_TYPE)
        if self.account_store.doesAccountExist():
            json_str = json.dumps({'account_status':'authorized'})
            self.write(json_str)
        else:
            request_token = sess.obtain_request_token()
            #store the request_token until the user approves
            self.active_requests[account_id] = request_token

            #lazily initialize sweep timer
            if not self.timer:
                self.timer = Timer(self.__SWEEP_PERIOD,self.sweep)
                self.timer.start()

            print "pending authorizations: "
            print self.active_requests
            url = sess.build_authorize_url(request_token)
            json_str = json.dumps({'account_status':'unauthorized', 'url':url})
            self._generate_headers()
            self.write(json_str)

    def post(self, account_id):
        if self.active_requests.has_key(account_id):
            sess = session.DropboxSession(self.__APP_KEY,
                self.__APP_SECRET, self.__ACCESS_TYPE)
            request_token = self.active_requests[account_id]
            access_token = sess.obtain_access_token(request_token)
            self.account_store.addAccount(account_id, access_token)
            #remove the pending request from the dictionary
            del self.active_requests[account_id]

if __name__ == "__main__":
    print 'hi'
