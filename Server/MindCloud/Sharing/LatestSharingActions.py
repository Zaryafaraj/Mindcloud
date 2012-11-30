from Sharing.SharingEvent import SharingEvent

__author__ = 'afathali'

class LatestSharingActions:

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
        elif action_type == SharingEvent.UPDATE_NOTE_IMG:
            note_name = sharing_action.get_note_name()
            self.__update_note_img_actions[note_name] = sharing_action

    def queue_up_actions(self):
        """
        Returns actions to be performed in the order that they should be
        performed
        """

        queue = []
        if self.__update_manifest_action is not None:
            queue.append(self.__update_manifest_action)
        for note_name, action in self.__update_note_actions:
            queue.append(action)
        for note_name, action in self.__update_note_img_actions:
            queue.append(action)
        return queue


