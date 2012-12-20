import json

__author__ = 'afathali'

class SharingEvent:
    """
    A representation of a single or multiple sharing event.
    Each instance of this class can only contain one event for each
    sharing event type with only one file associated
    """

    UPDATE_MANIFEST = 'update_manifest'
    UPDATE_NOTE = 'update_note'
    UPDATE_NOTE_IMG = 'update_note_img'

    __event_dictionary = {}
    #determines whether an action was added to this event or not
    __has_update = False

    def add_event(self, sharing_action):
        """
        Adds a sharing event with the given file.
        If an event with the same type already exists the new file will
         replace the existing events file.
        """
        event_type = sharing_action.get_action_type()
        event_file = sharing_action.get_associated_file()
        event_resource_name = sharing_action.get_action_resource_name()
        event_content = None
        if event_type == SharingEvent.UPDATE_NOTE_IMG:
            event_content = sharing_action.get_img_secret()
        else:
            event_content = event_file.read()

        dictionary_value = {'resource' : event_resource_name,
                            'content'  : event_content}

        self.__event_dictionary[event_type] = dictionary_value
        self.__has_update = True

    def has_update(self):
        return self.__has_update

    def convert_to_json_string(self):
        """
        Returns a json representation of all the events the class holds
        """
        return json.dumps(self.__event_dictionary)

