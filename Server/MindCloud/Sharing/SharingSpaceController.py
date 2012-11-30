from tornado import gen
from Sharing.LatestSharingActions import LatestSharingActions
from Sharing.SharingEvent import SharingEvent
from Storage.StorageResponse import StorageResponse

__author__ = 'afathali'

class SharingSpaceController():

    """
    A sharing space is per shared collection.
    """

    #primary listeners is a dictionary of user id to a request
    #these listeners are notified as soon as an update becomes
    #available for them
    __listeners = {}

    #backup listeners is a dictionary of user_id to a tuple of
    #(request, sharing_event). These listeners act as a backup
    #for primary listeners and save the next notification until
    #another listener is added for them.
    #As soon as another listener is added for these, the backup listeners
    #are notified with all the changes before the other listener arrived
    #and go back to the user. In this case, the second listener becomes a
    #backup listener
    __backup_listeners = {}

    #At any point in time the following conditions may exist:
    # 1- There is a primary listener and no back up listener:
    #   In this case the primary listener is notified and returned
    #   to the user. Any other changes made during the time the user is
    #   notified is lost.
    # 2- There is a primary listener and a backup listener:
    #   In this case, as soon as a change happens the primary listener
    #   gets notified and the backup listeners starts recording the changes
    #   Once the user recieves the notification he should send back another
    #   listener. As soon as another listener arrives the backup listener
    #   returns to the user; the second listener becomes the backup listener
    #   and begins recording all the changes while the user is notified.
    #   If no changes happen during the first listener notifying the user
    #   and backup listener recording. Then the second listener becomes
    #   the primary listener and the backup listener stays a backup listener
    # 3- There is only a backup listener:
    #   As mentioned in above the backup listener starts recording any thing
    #   that happens while another listener is added. In that case the
    #   backup listener returns to user with notification and the second
    #   listener becomes the primary listener.


    __latest_sharing_actions = None
    def __init__(self):
        self.__latest_sharing_actions = LatestSharingActions()

    def add_listener(self, user_id, request):
        """
        Adds a listener to the list of the listeners.
        If the user is already existing , the listener will be
        added to the backup listeners.
        It is recommended that each user register a primary listener and
        a backup listener.
        The backup listener is never returned.

        This mechanism allows the user to alternate between primary and backup
        listener and always keep a listener.

        Args:
            user_id : The id of the user
            request : A tornado request object that will be returned to the
            user as response
        """

        if user_id in self.__listeners:
            self.__backup_listeners[user_id] = (request, SharingEvent())

        #if there is a backup listener for the current listener
        #check to see if it has updates
        elif user_id in self.__backup_listeners:
            backup_listener_events = self.__backup_listeners[user_id][1]
            if backup_listener_events.has_update():
                #return the back up listener to the user and make
                #the new listener backup listener
                request = self.__backup_listeners[user_id][0]
                request.write(backup_listener_events.convert_to_json_string())
                request.set_status(StorageResponse.OK)
                request.finish()
                del self.__backup_listeners[user_id]
                self.__backup_listeners[user_id] = (request, SharingEvent())
            else:
                #There are no updates in the backup listener make this listener
                #the primary listener
                self.__listeners[user_id] = request
        else:
            #the listener is not in primary listeners or backup listener
            #it must be the first listener add it to primary listerners
            self.__listeners[user_id] = request


    def remove_listener(self, user_id):
        """
        removes the primary and backup listener for the user if they exist
        """

        if user_id in self.__backup_listeners:
            del self.__backup_listeners[user_id]
        if user_id in self.__listeners:
            del self.__listeners[user_id]

    def add_action(self, sharing_action):
        """
        An action that needs to be taken place and all the
        listeners sohuld get notified of

        When an action is added first all of the listeners get notified
        immediatley . Then the action goes on a queue and when the
        sharing space has time it will submit the action to the actual
        storage. However after registering an action and before submitting
        it, if a new action with the same type is registered. The latest
        action will take the place of the most recent one before it

        It is not neccessary for an action to affect only listeners.
        There might be an offline user that gets updated by the request.
        In those cases the timing for the submission of action is the based
        on the best try of the class.

        -Args:
            -``sharing_action``: A proper subclass of the sharing action
        """
        self.__notify_listeners(sharing_action)

        #THIS DOESNT WORK
        if self.__latest_sharing_actions.is_empty():
            self.__latest_sharing_actions.add_action(sharing_action)
            actions = self.__latest_sharing_actions.queue_up_actions()
            yield gen.Task(self.__start_processing_queue, actions)
        else:
            self.__latest_sharing_actions.add_action(sharing_action)

    @gen.engine
    def __notify_listeners(self, sharing_action):
        #for each primary listener notify the primary listener
        event_type = sharing_action.get_action_type()
        event_file = sharing_action.get_associated_file()
        notified_listeners = set()
        for user_id, request in self.__listeners:
            sharing_event = SharingEvent()
            sharing_event.add_event(event_type, event_file)
            notification_json = sharing_event.convert_to_json_string()
            request.write(notification_json)
            request.set_status(StorageResponse.OK)
            request.finish()
            notified_listeners.add(user_id)

        #now update the backup listeners only for those items that
        #didn't get notified
        for user_id in self.__backup_listeners:
            #the backup listener didn't have a primary listener
            #so it must be in recording state
            if user_id not in notified_listeners:
                backup_sharing_event = self.__backup_listeners[user_id][1]
                backup_sharing_event.add_event(event_file, event_file)


    @gen.engine
    def __process_queue_recursive(self, callback):

        #this may break if the queue has more than 1000 items in it
        #because of of the recursion depth limit in python
        if not len(self.__sharing_action_queue):
            next_sharing_action = self.__sharing_action_queue[0]
            yield gen.Task(next_sharing_action.execute)
            del self.__sharing_action_queue[0]
            gen.Task(self.__process_queue_recursive)
        else:
            #this is actually called once
            callback()

    @gen.engine
    def __start_processing_queue(self, callback):
        yield gen.Task(self.__process_queue_recursive)









