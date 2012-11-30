import json

__author__ = 'afathali'

class SharingEvent:

    UPDATE_MANIFEST = 'update_manifest'
    UPDATE_NOTE = 'update_note'
    UPDATE_NOTE_IMG = 'update_note_img'

    __event_dictionary = {}

    def add_update_manifest_event(self, manifest_file):
        """
        Adds an update manifest even with the given file.
        If an even for update manifest already existed this new event
        will replace that.
        """
        self.__event_dictionary[SharingEvent.UPDATE_MANIFEST] = manifest_file.read()

    def add_update_note_event(self, note_file):
        self.__event_dictionary[SharingEvent.UPDATE_NOTE] = note_file.read()

    def add_update_img_event(self, img_file):
        self.__event_dictionary[SharingEvent.UPDATE_NOTE_IMG] = img_file.read()

    def convert_to_json_string(self):
        return json.dumps(self.__event_dictionary)

