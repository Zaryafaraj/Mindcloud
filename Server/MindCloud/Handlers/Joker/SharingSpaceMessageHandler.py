__author__ = 'Fathalian'

from tornado import gen
import tornado.web
from Logging import Log
from Sharing.SharingSpaceStorage import SharingSpaceStorage
from Sharing.SharingActionFactory import SharingActionFactory


class SharingSpaceDiffHandler(tornado.web.RequestHandler):
    """
    An api for sending custom messages to all listeners
    """
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
        custom_message = self.get_argument('message', default=None)
        msg_id = self.get_argument('msg_id', default=None)
        if user_id is None or collection_name is None or custom_message is None or msg_id is None:
            self.set_status(400)
            self.finish()
        else:
            #Create the sharing action
            sharing_action = SharingActionFactory.from_custom_message_and_user(custom_message, msg_id,
                                                                               user_id, collection_name)
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
