from collections import OrderedDict
from Sharing.SharingEvent import SharingEvent

__author__ = 'afathali'

class SharingQueue:

    """
    An object which holds the latest actions to be performed
     on a specific collection
    """

    #There is only one action per user on collection manifest and thats updating it
    #A dictionary keyed on user_id that holds the latest manifest update
    __update_manifest_action = OrderedDict()

    #A dictionary for note update action keyed on the user_id
    #Each user can have many note updates
    #each value is another OrderedDict valued on the name of the note
    __update_note_actions = OrderedDict()

    #A dictionary for note image update actions keyed on the name of the note
    #Each user can have many note updates
    #each value is another OrderedDict valued on the name of the note
    __update_note_img_actions = OrderedDict()

    #Public attribute indicating that the SharingActions are being processed
    #its the responsibility of the client to turn this on/off because its
    #the client that uses this not the class internally
    is_being_processed = False

    __action_count = 0

    def is_empty(self):
        if self.__action_count > 0 :
            return False
        else:
            return True

    def push_action(self, sharing_action):
        """
        Add an action to be performed later.
        If an older action exists for the same resource the new action
        will replace it

        -Args:
            -``sharing_action``: An instance of a subclass of sharing_action
            class
        """

        if sharing_action is None:
            return

        action_type = sharing_action.get_action_type()
        action_user_id = sharing_action.get_user_id()
        if action_type == SharingEvent.UPDATE_MANIFEST:
            if action_user_id not in self.__update_manifest_action:
                self.__action_count += 1
            self.__update_manifest_action[action_user_id] = sharing_action
        elif action_type == SharingEvent.UPDATE_NOTE:
            if action_user_id not in self.__update_note_actions:
                self.__update_note_actions[action_user_id] = OrderedDict()
            note_name = sharing_action.get_note_name()
            if note_name not in self.__update_note_actions[action_user_id]:
                self.__action_count += 1
            self.__update_note_actions[action_user_id][note_name] = sharing_action
        elif action_type == SharingEvent.UPDATE_NOTE_IMG:
            if action_user_id not in self.__update_note_img_actions:
                self.__update_note_img_actions[action_user_id] = OrderedDict()
            note_name = sharing_action.get_note_name()
            if note_name not in self.__update_note_img_actions[action_user_id]:
                self.__action_count += 1
            self.__update_note_img_actions[action_user_id][note_name] = sharing_action

    def pop_next_action(self):
        """
        Removes the latest action to be performed and returns it.
        The return object of this method won't be kept in the list of actions
        to be performed.

        Returns None is there is no other action to be performed
        """

        if len(self.__update_manifest_action) > 0:
            #the index is because pop item returns a key value tuple
            manifest_action = self.__update_manifest_action.popitem(last=True)[1]
            self.__action_count -= 1
            return manifest_action
        elif len(self.__update_note_actions) > 0:
            #get the update note actions that were made by the last user
            #who had the latest activity
            user_note_action_tuple =\
                self.__update_note_actions.popitem(last=True)
            user_id = user_note_action_tuple[0]
            #now get all of the actions that that user has in queue
            user_note_actions = user_note_action_tuple[1]
            #get the latest of those actions
            next_action = user_note_actions.popitem(last=True)[1]
            #if there are more actions left for the user put the user actions
            #back
            if len(user_note_actions) :
                self.__update_note_actions[user_id] = user_note_actions
            self.__action_count -= 1
            return next_action

        elif len(self.__update_note_img_actions) > 0:
            #same as above
            user_img_actions_tuple =\
                self.__update_note_img_actions.popitem(last=True)
            user_id = user_img_actions_tuple[0]
            user_img_actions = user_img_actions_tuple[1]
            next_action = user_img_actions.popitem(last=True)[1]
            if len(user_img_actions):
                self.__update_note_img_actions[user_id] = user_img_actions
            self.__action_count -= 1
            return next_action
        else:
            #just to be sure
            #these should be dynamically set to zero and False
            self.is_being_processed = False
            self.__action_count = 0
            return None


    def clear(self):
        self.__update_manifest_action.clear()
        self.__update_note_actions.clear()
        self.__update_note_img_actions.clear()
        self.is_being_processed = False
        self.__action_count = 0

    #convinience method
    def is_being_processed(self):
        return self.is_being_processed

