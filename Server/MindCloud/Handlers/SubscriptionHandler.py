import json
import urllib2
from tornado import gen
import tornado.web
from Logging import Log
from Sharing.SharingController import SharingController
from Storage.StorageResponse import StorageResponse

__author__ = 'afathali'

class SubscriptionHandler(tornado.web.RequestHandler):

    __log = Log.log()

    @tornado.web.asynchronous
    @gen.engine
    def delete(self,user_id, collection_name):

        self.__log.info('%s - DELETE: User %s unsubscribes from sharing space of collection %s' % (str(self.__class__), user_id, collection_name))

        collection_name = urllib2.unquote(collection_name)
        response = \
        yield gen.Task(SharingController.unsubscribe_from_sharing_space,
           user_id, collection_name)
        self.set_status(response)
        self.finish()

