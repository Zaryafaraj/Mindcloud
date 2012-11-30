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

    def add_event(self, event_type, event_file):
        """
        Adds a sharing event with the given file.
        If an event with the same type already exists the new file will
         replace the existing events file.
        """
        self.__event_dictionary[event_type] = event_file.read()

    def convert_to_json_string(self):
        """
        Returns a json representation of all the events the class holds
        """
        return json.dumps(self.__event_dictionary)

