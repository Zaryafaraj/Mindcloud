"""
The class for handling authentication requests.
"""

from threading import Timer
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from Accounts import Accounts
from DropboxHelper import DropboxHelper
import json

class AuthorizationHandler(tornado.web.RequestHandler):

    #duration before which a sweep gets performed
    __SWEEP_PERIOD = 30

    #active requests that pend user approval
    active_requests = {}
    #Sweep candidates
    sweep_candidates = []

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

        #The timer stops after this function is finished.
        #Create a new one if there are items still remaining
        #TODO there should be a better way to have a timer
        #automatically call this function periodically
        if len(self.active_requests) > 0:
            self.timer = Timer(10, self.sweep)
            self.timer.start()
        #No need for timer when there are no pending requests
        else:
            self.timer = None

    def get(self, account_id):
        """
        Authorize a single user.
        If user has been authorized before return authorized .
        Otherwise return unauthorized.
        When unauthorized is issued the user is added to a pending list.
        The user is removed from the pending list when he indicates
        that he has authorized mindcloud by issuing a post on this class
        After some period of time the users who have not answered the
        unauthorized call will be removed from the pending list
        """

        #FIXME what is the cost of making this object ?
        #Is it better to use a static function

        sess = DropboxHelper.create_session()
        if Accounts.does_account_exist(account_id):
            json_str = json.dumps({'account_status':'authorized'})
            self.write(json_str)
        else:
            request_token = sess.obtain_request_token()
            #store the request_token until the user approves
            self.active_requests[account_id] = request_token

            #lazily initialize sweep timer
            if not self.timer:
                self.timer = Timer(self.__SWEEP_PERIOD, self.sweep)
                self.timer.start()

            url = sess.build_authorize_url(request_token)
            json_str = json.dumps({'account_status':'unauthorized', 'url':url})
            self._generate_headers()
            self.write(json_str)

    def post(self, account_id):
        if self.active_requests.has_key(account_id):
            sess = DropboxHelper.create_session()
            request_token = self.active_requests[account_id]

            #If the request token has been expired send
            # Not Authorized. The user should start again
            if request_token is None:
                self.write_error(401)

            access_token = sess.obtain_access_token(request_token)
            Accounts.add_account(account_id, access_token)
            #remove the pending request from the dictionary
            del self.active_requests[account_id]

if __name__ == "__main__":
    print 'hi'
