from tornado import gen
from Logging import Log
from Cache.MindcloudCache import MindcloudCache
from Properties import MindcloudProperties
from Sharing.SharingActionDelegate import SharingActionDelegate
from Sharing.SharingQueue import SharingQueue
from Sharing.SharingEvent import SharingEvent
from Storage.StorageResponse import StorageResponse
from Storage.StorageServer import StorageServer

__author__ = 'afathali'

class SharingSpaceController(SharingActionDelegate):

    """
    A sharing space is per shared collection.
    """

    __cache = MindcloudCache()

    __log = Log.log()

    #number of items to process in a batch
    #as the batch size grows actions will be processed faster however
    #there is a chance that we will be performing extra actions that
    #will be later replaced by a new action.
    #with a small batch size we process and execute slower however this
    #slowness allows us to see the next incoming actions and if necessary
    #replace an existing action in a queue by the new action
    #it seems that 5 is kinda our magic number any bigger and we have
    #weird lost packets in dropbox
    __BATCH_SIZE = MindcloudProperties.Properties.action_batch_size

    #current remaining actions in a batch
    __remaining_actions = 0


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


    __sharing_queue = None

    def __init__(self):
        self.__sharing_queue = SharingQueue()
        self.__sharing_queue.is_being_processed = False
        #primary listeners is a dictionary of user id to a request
        #these listeners are notified as soon as an update becomes
        #available for them
        self.__listeners = {}

        #backup listeners is a dictionary of user_id to a tuple of
        #(request, sharing_event). These listeners act as a backup
        #for primary listeners and save the next notification until
        #another listener is added for them.
        #As soon as another listener is added for these, the backup listeners
        #are notified with all the changes before the other listener arrived
        #and go back to the user. In this case, the second listener becomes a
        #backup listener
        self.__backup_listeners = {}

    def is_being_processed(self):
        if self.__sharing_queue is None:
            return False
        else:
            return self.__sharing_queue.is_being_processed

    def give_opprotunity_to_be_processed(self):
        #gives half an hour of opprotunity for this to become set again. If not it will be cleaned up
        self.__sharing_queue.is_being_processed = False

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
            self.__log.info('SharingSpaceController - Backup listener added for user %s' % user_id)
            self.__backup_listeners[user_id] = (request, SharingEvent())

        #if there is a backup listener for the current listener
        #check to see if it has updates
        elif user_id in self.__backup_listeners:
            backup_listener_events = self.__backup_listeners[user_id][1]
            if backup_listener_events.has_update():
                self.__log.info('SharingSpaceController - backup listener has updates for user %s' % user_id)
                #return the back up listener to the user and make
                #the new listener backup listener

                backup_request = self.__backup_listeners[user_id][0]
                try:
                    backup_request.write(backup_listener_events.convert_to_json_string())
                    backup_request.set_status(StorageResponse.OK)
                    backup_request.finish()
                except Exception:
                    pass
                del self.__backup_listeners[user_id]
                self.__backup_listeners[user_id] = (request, SharingEvent())
                self.__log.info('SharingSpaceController - backup listener update returned for user %s; replacing backup listener' % user_id)
            else:
                #There are no updates in the backup listener make this listener
                #the primary listener
                self.__listeners[user_id] = request

                self.__log.info('SharingSpaceController - primary listener added for user %s' % user_id)

        else:
            #the listener is not in primary listeners or backup listener
            #it must be the first listener add it to primary listerners
            self.__log.info('SharingSpaceController - primary listener added for user %s' % user_id)
            self.__listeners[user_id] = request


    def __finish_request(self, request):
        try:
            request.set_status(200)
            request.finish()
        #in case the request is automatically close don't bother
        except Exception:
           pass

    def remove_listener(self, user_id):
        """
        removes the primary and backup listener for the user if they exist
        """

        if user_id in self.__backup_listeners:
            backup_listener = self.__backup_listeners[user_id][0]
            self.__finish_request(backup_listener)
            del self.__backup_listeners[user_id]
        if user_id in self.__listeners:
            primary_listener = self.__listeners[user_id]
            self.__finish_request(primary_listener)
            del self.__listeners[user_id]

    def cleanup(self):

        to_be_removed = []
        for user_id in self.__backup_listeners:
            backup_listener = self.__backup_listeners[user_id][0]
            self.__finish_request(backup_listener)
            to_be_removed.append(user_id)

        for user_id in to_be_removed:
            del self.__backup_listeners[user_id]

        del to_be_removed[:]

        for user_id in self.__listeners:
            primary_listener = self.__listeners[user_id]
            self.__finish_request(primary_listener)
            to_be_removed.append(user_id)

        for user_id in to_be_removed:
            del self.__listeners[user_id]

    def get_number_of_primary_listeners(self):
        """
        Returns the number of primary listeners on this space

        """
        return len(self.__listeners)

    def get_number_of_backup_listeners(self):
        """
        Returns the number of backup listeners on this space.

        """
        return len(self.__backup_listeners)

    def get_all_primary_listener_ids(self):
        """
        Returns a list of user_id of the primary listeners
        """
        return [user_id for user_id in self.__listeners]

    def get_all_backup_listener_ids(self):
        """
        Returns a list of user_id of the backup listeners
        """
        return [user_id for user_id in self.__backup_listeners]

    def add_action(self, sharing_action, owner=' ', notify_listeners=True):
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

        #first notify all the listeners as fast as possible
        if notify_listeners and sharing_action.get_action_type != SharingEvent.UPDATE_THUMBNAIL:
            self.__notify_listeners(sharing_action, owner)

        #Now add the action to the latest_sharing_actions to be
        #performed later. This is not as time bound as notify listeners
        #since the user has the perception of being real time

        self.__sharing_queue.push_action(sharing_action)

        #if the class is not processing the actions start processing them
        if  not self.__sharing_queue.is_being_processed :
            self.__process_next_batch_of_queue_actions()


    def __process_next_batch_of_queue_actions(self):
        self.__sharing_queue.is_being_processed = True
        self.__process_actions_iterative(self.__BATCH_SIZE)

    def remove_temp_img(self, img_secret):
        """
        There shouldn't be any real world use cases for this. The image
        will be automatically removed from cached based on the caching
        alg
        """
        self.__cache.remove_temp_img(img_secret, callback=None)

    def __get_temp_img(self, img_secret, callback):
        """
        Returns None in case its a cache miss
        """
        self.__cache.get_temp_img(img_secret, callback)

    @gen.engine
    def get_temp_img(self, img_secret, user_id, collection_name, note_name=None, callback=None):
        """
        Retrievs the temp img
        """
        img = yield gen.Task(self.__get_temp_img, img_secret)
        #if its a cache miss; it has probably passed enough time to
        #get the image directly from the storage
        if img is None:
            #this relates to a note image
            if note_name is not None:
                img_file = yield gen.Task(StorageServer.get_note_image, user_id, collection_name, note_name)
                if img_file is not None:
                    img = img_file.read()
            else:
            #its a thumbnail
                img_file = yield gen.Task(StorageServer.get_thumbnail, user_id, collection_name)
                if img_file is not None:
                    img = img_file.read()

            if img is None:
                SharingSpaceController.__log.info('SharingSpaceController - failed to update img for %s; collection= %s; note=%s' % (user_id,collection_name,note_name))

        callback(img)

    def __generate_img_secret(self, user_id, collection_name, note_name):
        return str(abs(hash(str(user_id+collection_name+note_name))))

    @gen.engine
    def __store_temp_image(self, update_img_sharing_action, callback):
        """
        store the img associated with the update image sharing
        action in the cache.
        """
        user_id = update_img_sharing_action.get_user_id()
        collection_name = update_img_sharing_action.get_collection_name()
        note_name = 'thumbnail'
        if update_img_sharing_action.get_action_type() == SharingEvent.UPDATE_NOTE_IMG:
            note_name = update_img_sharing_action.get_note_name()
        img_file = update_img_sharing_action.get_associated_file()

        img_secret = self.__generate_img_secret(user_id, collection_name, note_name)
        update_img_sharing_action.set_img_secret(img_secret)

        self.__cache.set_temp_img(img_secret, img_file, callback=callback)

    @gen.engine
    def __notify_listeners(self, sharing_action, owner=' '):
        #for each primary listener notify the primary listener
        event_type = sharing_action.get_action_type()
        #in the case of the image we cache the image and notify the user
        #of the image, they can then request the temporary cached image
        if event_type == SharingEvent.UPDATE_NOTE_IMG or \
           event_type == SharingEvent.UPDATE_THUMBNAIL:
            yield gen.Task(self.__store_temp_image, sharing_action)

        notified_listeners = set()
        for user_id in self.__listeners:
            if user_id != owner:
                request = self.__listeners[user_id]
                sharing_event = SharingEvent()
                sharing_event.add_event(sharing_action)
                notification_json = sharing_event.convert_to_json_string()
                try:
                    request.write(notification_json)
                    request.set_status(StorageResponse.OK)
                    request.finish()
                #if request is closed, ignore it
                except Exception:
                    pass

                SharingSpaceController.__log.info('SharingSpaceController - notified primary listener %s for sharing event %s - %s' % (user_id, sharing_action.get_action_type(), sharing_action.get_action_resource_name()))

                notified_listeners.add(user_id)

        #now update the backup listeners only for those items that
        #didn't get notified
        for user_id in self.__backup_listeners:
            #the backup listener didn't have a primary listener
            #so it must be in recording state
            if user_id not in notified_listeners and \
               user_id != owner:
                backup_sharing_event = self.__backup_listeners[user_id][1]
                backup_sharing_event.add_event(sharing_action)

                SharingSpaceController.__log.info('SharingSpaceController - stored event for backup listener %s for sharing event %s - %s' % (user_id, sharing_action.get_action_type(), sharing_action.get_action_resource_name()))

        #delete notified user
        for user_id in notified_listeners:
            del self.__listeners[user_id]


    def __process_actions_iterative(self, iteration_count):

        if self.__sharing_queue.is_empty():
            self.__sharing_queue.is_being_processed = False
            self.__log.info('SharingSpaceController - Finished executing all actions')
            return
        else:

            SharingSpaceController.__log.info('SharingSpaceController - Started processing batch of %s actions' % str(iteration_count))
            actions_to_be_executed = []
            for x in range(iteration_count):
                next_sharing_action = self.__sharing_queue.pop_next_action()
                if next_sharing_action is None:
                   break
                #first increment the counters in remaining actions then execute them
                #this will make sure that when any action is being executed the counter
                #won't change
                else:
                    self.__remaining_actions += 1
                    actions_to_be_executed.append(next_sharing_action)
            for action in actions_to_be_executed:
                action_type = action.get_action_type()
                user = action.get_user_id()
                SharingSpaceController.__log.info('SharingSpaceController - executing action %s-%s for user %s' % (action.name,action_type,user))
                action.execute(delegate=self)


    #delegate method from SharingActionDelegate
    @gen.engine
    def actionFinishedExecuting(self, action, response):
        """
        This function is called when an action is finished executing.
        It keeps a count of the remaining actions and when it reaches
        zero it knows that the batch actions are finished and opens up
        the queue for second batch of processing

        -Args:
            -``action``: The SharingAction that got ginished executing
            -``remaining_actions``: The remaining actions to be finished
            before the batch of actions that action was part of is considered
            done
        """
        #becauce of a dropbox bug it seems that some times files don't get submitted
        #this is not an eventual consistency problem, the files don't get submitted
        #even eventually.
        #we try to get the result of the just finished action and if it wasn't there
        #retry the action

        was_successful = yield gen.Task(action.was_successful)
        if was_successful:
            self.__remaining_actions -= 1
            SharingSpaceController.__log.info('SharingSpaceController - finished executing action %s with response %s' % (action.name, str(response)))

        else:
            SharingSpaceController.__log.info('SharingSpaceController - Retrying action %s' % action.name)
            action.execute(delegate=self)

        if not self.__remaining_actions :
            SharingSpaceController.__log.info('Finished executing all the actions in the batch')
            self.__sharing_queue.is_being_processed = False
            self.__process_next_batch_of_queue_actions()

    def clear(self):
        self.__listeners.clear()
        self.__backup_listeners.clear()
        self.__sharing_queue.clear()
