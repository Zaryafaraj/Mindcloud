from collections import OrderedDict
from Sharing.SharingEvent import SharingEvent

__author__ = 'afathali'

class SharingQueue:

    """
    An object which holds the latest actions to be performed
     on a specific collection
    """

    #There is only one action on collection manifest and thats updating it
    __update_manifest_action = None

    #A dictionary for note update action keyed on the name of the note
    __update_note_actions = OrderedDict()

    #A dictionary for note image update actions keyed on the name of the note
    __update_note_img_actions = OrderedDict()

    #Public attribute indicating that the SharingActions are being processed
    #its the responsibility of the client to turn this on/off because its
    #the client that uses this not the class internally
    is_being_processed = False

    def push_action(self, sharing_action):
        """
        Add an action to be performed later.
        If an older action exists for the same resource the new action
        will replace it

        -Args:
            -``sharing_action``: An instance of a subclass of sharing_action
            class
        """

        action_type = sharing_action.get_action_type()
        if action_type == SharingEvent.UPDATE_MANIFEST:
            self.__update_manifest_action = sharing_action
        elif action_type == SharingEvent.UPDATE_NOTE:
            note_name = sharing_action.get_note_name()
            self.__update_note_actions[note_name] = sharing_action
        elif action_type == SharingEvent.UPDATE_NOTE_IMG:
            note_name = sharing_action.get_note_name()
            self.__update_note_img_actions[note_name] = sharing_action

    def pop_next_action(self):
        """
        Removes the latest action to be performed and returns it.
        The return object of this method won't be kept in the list of actions
        to be performed.

        Returns None is there is no other action to be performed
        """

        if self.__update_manifest_action is not None:
            manifest_action = self.__update_manifest_action
            self.__update_manifest_action = None
            return manifest_action
        elif len(self.__update_note_actions) > 0:
            #return the value for the last item in the ordered dict
            return self.__update_note_actions.popitem(last=True)[1]
        elif len(self.__update_note_img_actions) > 0:
            return self.__update_note_img_actions.popitem(last=True)[1]
        else:
            self.is_being_processed = False
            return None


    def clear(self):
        self.__update_manifest_action = None
        self.__update_note_actions.clear()
        self.__update_note_img_actions.clear()
        self.is_being_processed = False

    #convinience method
    def is_being_processed(self):
        return self.is_being_processed

