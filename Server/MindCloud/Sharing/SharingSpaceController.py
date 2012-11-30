from tornado import gen

__author__ = 'afathali'

class SharingSpaceController():

    #for each listener, there is a request and a json candidate.
    #Each time a sharing action gets executed the sharing candidate gets
    #updated in this sense we have made sure that the queue is finished,
    #everything is up to date and then requests are notified . The
    #notification is then done. Since everything is single threaded hopefully
    #this will work but we are still loosing some info while the user listens
    #again
    __listeners = {}
    __backup_listeners = {}
    __sharing_action_queue = []

    def add_listener(self, user_id, request):
        """
        Adds a listener to the list of the listeners.
        If the user is already existing , the listener will be
        added to the backup listeners.
        It is recommended that each user register a primary listener and
        a backup listener.
        The backup listener won't be used until the primary listener
        is notified. When the primary listener is notified the backup
        listener becomes the primary listener. Then when the user sends a
        another listener that becomes the backup listener.
        The backup listener is never returned.

        This mechanism allows the user to alternate between primary and backup
        listener and always keep a listener.

        Args:
            user_id : The id of the user
            request : A tornado request object that will be returned to the
            user as response
        """

        if user_id in self.__listeners:
            self.__backup_listeners[user_id] = request
        else:
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
        self.__sharing_action_queue.append(sharing_action)
        if len(self.__sharing_action_queue) == 1:
            yield gen.Task(self.__start_processing_queue)

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









