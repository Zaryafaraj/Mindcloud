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
    __update_note_actions = {}

    #A dictionary for note image update actions keyed on the name of the note
    __update_note_img_actions = {}

    #A queue that determines the latest note action to be performed
    #its elements are refrences to the update_notes and update_note_img
    # actions
    __notes_queue = []

    #Public attribute indicating that the SharingActions are being processed
    #its the responsibility of the client to turn this on/off because its
    #the client that uses this not the class internally
    is_being_processed = False

    def add_action(self, sharing_action):
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
            self.__update_manifest_action= action_type
        elif action_type == SharingEvent.UPDATE_NOTE:
            note_name = sharing_action.get_note_name()
            self.__update_note_actions[note_name] = sharing_action
            self.__notes_queue.append(sharing_action)
        elif action_type == SharingEvent.UPDATE_NOTE_IMG:
            note_name = sharing_action.get_note_name()
            self.__update_note_img_actions[note_name] = sharing_action
            self.__notes_queue.append(sharing_action)

    def peak_next_action(self):
        """
        Returns the best action to be performed at a given point in time.
        However, it doesn't remove it from the list of actions to be performed

        Returns None is there is no other action to be performed
        """
        if self.__update_manifest_action is not None:
            return self.__update_manifest_action
        elif len(self.__notes_queue) > 0:
            #last element of the list
            return self.__notes_queue[-1]
        else:
            return None

    def pop_next_action(self):
        """
        Removes the latest action to be performed and returns it.
        The return object of this method won't be kept in the list of actions
        to be performed.

        Returns None is there is no other action to be performed
        """
        popped_action = None
        if self.__update_manifest_action is not None:
            popped_action = self.__update_manifest_action
            self.__update_manifest_action = None
        elif len(self.__notes_queue) > 0 :
            popped_action = self.__notes_queue[-1]
            del self.__notes_queue[-1]

        #if there were no popped actions set, meaning all items have been
        #processed
        if popped_action is None:
            #just to make sure that this gets self
            self.is_being_processed = False
        return popped_action

    def clear(self):
        self.__update_manifest_action = None
        self.__update_note_actions.clear()
        self.__update_note_img_actions.clear()
        self.is_being_processed = False

    #convinience method
    def is_being_processed(self):
        return self.is_being_processed

