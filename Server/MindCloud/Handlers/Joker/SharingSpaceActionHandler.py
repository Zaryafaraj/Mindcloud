from tornado import gen
import tornado.web
from Sharing.SharingActionFactory import SharingActionFactory
from Sharing.SharingSpaceStorage import SharingSpaceStorage

__author__ = 'afathali'

class SharingSpaceActionHandler(tornado.web.RequestHandler):

    @tornado.web.asynchronous
    @gen.engine
    def post(self, sharing_secret):

        sharing_storage = SharingSpaceStorage.get_instance()
        sharing_space = sharing_storage.get_sharing_space(sharing_secret)
        action_json = self.get_argument('action')
        file = None
        if len(self.request.files) > 0:
            file = self.request.files['file'][0]
        sharing_action = \
            SharingActionFactory.from_json_and_file(action_json, file)
        #as the user is concerned this call is finished
        self.set_status(200)
        self.finish()

        all_actions = \
            yield gen.Task(SharingActionFactory.create_related_sharing_actions,
                sharing_secret, sharing_action)

        for action in all_actions:
            sharing_space.add_action(action)



