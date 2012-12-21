from tornado import gen
import tornado.web

__author__ = 'afathali'

class SharingSpaceActionHandler(tornado.web.RequestHandler):

    @tornado.web.asynchronous
    @gen.engine
    def post(self, sharing_secret):



