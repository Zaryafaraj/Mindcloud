from tornado import gen
import tornado.web
from Logging import Log
from Sharing.SharingSpaceStorage import SharingSpaceStorage
from Sharing.SharingActionFactory import SharingActionFactory

__author__ = 'Fathalian'


class SharingSpaceDiffHandler(tornado.web.RequestHandler):
    __log = Log.log()

    @tornado.web.asynchronous
    @gen.engine
    def post(self, sharing_secret):

        """
        Always assumes that the file that is passed in is base64
        """

        #Check to see if the required params are here
        user_id = self.get_argument('user_id', default=None)
        collection_name = self.get_argument('collection_name', default=None)
        diff_resource_path = self.get_argument('resource_path', default=None)
        if len(self.request.files) == 0 or user_id is None or collection_name is None or diff_resource_path is None:
            self.set_status(400)
            self.finish()
        else:
            diff_file = self.request.files.popitem()[1][0]
            #Create the sharing action
            sharing_action = SharingActionFactory.from_diff_file_and_user(diff_file,
                                                                          user_id,
                                                                          collection_name,
                                                                          diff_resource_path)
            #Create actions for all the subscriber
            all_actions = \
                yield gen.Task(SharingActionFactory.create_related_sharing_actions,
                               sharing_secret, sharing_action)
            if all_actions is None:
                self.set_status(404)
                self.finish()
            else:
                sharing_storage = SharingSpaceStorage.get_instance()
                sharing_space = sharing_storage.get_sharing_space(sharing_secret)
                self.__log.info(
                    'SharingSpaceDiffHandler - Diff sent. Adding %s actions to sharing_secret=%s, user_id=%s' %
                    (str(len(all_actions)), sharing_secret, user_id))

                #Notify the sharing space of the actions making sure that we only notify for
                #the first action
                is_first_action = True
                for action in all_actions:
                    if is_first_action:
                        is_first_action = False
                        sharing_space.add_action(action, owner=sharing_action.get_user_id(), notify_listeners=True)
                    else:
                        sharing_space.add_action(action, owner=sharing_action.get_user_id(), notify_listeners=False)

            #as the user is concerned this call is finished
            self.set_status(200)
            self.finish()
