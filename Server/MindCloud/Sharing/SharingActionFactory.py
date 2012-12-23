import json
from Sharing.DeleteSharedNoteAction import DeleteSharedNoteAction
from Sharing.SharingEvent import SharingEvent
from Sharing.UpdateSharedManifestAction import UpdateSharedManifestAction
from Sharing.UpdateSharedNoteAction import UpdateSharedNoteAction
from Sharing.UpdateSharedNoteImageAction import UpdateSharedNoteImageAction

__author__ = 'afathali'

class SharingActionFactory():

    __USER_ID_KEY = 'user_id'
    __COLLECTION_NAME_KEY = 'collection_name'
    __NOTE_NAME_KEY = 'note_name'

    @staticmethod
    def from_json_and_file(json_str, file):
        """

        Returns a sharing action from json string
        A Well formed json:
        {'update_manifest' : {'collection_name':'name',
                                'user_id:'id'] }
        or
        {'update_note' : {'collection_name' : 'name' ,
                          'note_name' :'name',
                           'user_id':'id']}
        """

        json_obj = json.loads(json_str)
        try:
            if SharingEvent.UPDATE_MANIFEST in json_obj:
                if file is None:
                    return None

                details = json_obj[SharingEvent.UPDATE_MANIFEST]
                user_id = details[SharingActionFactory.__USER_ID_KEY]
                collection_name = details[SharingActionFactory.__COLLECTION_NAME_KEY]
                sharing_action = UpdateSharedManifestAction(user_id, collection_name, file)
                return sharing_action

            elif SharingEvent.UPDATE_NOTE in json_obj:
                if file is None:
                    return None
                details = json_obj[SharingEvent.UPDATE_NOTE]
                user_id = details[SharingActionFactory.__USER_ID_KEY]
                collection_name = details[SharingActionFactory.__COLLECTION_NAME_KEY]
                note_name = details[SharingActionFactory.__NOTE_NAME_KEY]
                sharing_action = UpdateSharedNoteAction(user_id, collection_name,
                    note_name, file)
                return sharing_action

            elif SharingEvent.UPDATE_NOTE_IMG in json_obj:
                if file is None:
                   return None

                details = json_obj[SharingEvent.UPDATE_NOTE_IMG]
                user_id = details[SharingActionFactory.__USER_ID_KEY]
                collection_name = details[SharingActionFactory.__COLLECTION_NAME_KEY]
                note_name = details[SharingActionFactory.__NOTE_NAME_KEY]
                sharing_action = UpdateSharedNoteImageAction(user_id,
                    collection_name, note_name, file)
                return sharing_action

            elif SharingEvent.DELETE_NOTE in json_obj:
                details = json_obj[SharingEvent.DELETE_NOTE]
                user_id = details[SharingActionFactory.__USER_ID_KEY]
                collection_name = details[SharingActionFactory.__COLLECTION_NAME_KEY]
                note_name = details[SharingActionFactory.__NOTE_NAME_KEY]
                sharing_action = DeleteSharedNoteAction(user_id, collection_name,
                    note_name)
                return sharing_action
            else:
                return None

        except Exception:
            return None

    @staticmethod
    def create_related_sharing_actions(sharing_secret, sharing_action):
        """
        creates all the sharing actions for all the users that have
        subscribed to sharing_secret

        returns a list of sharing_actions each for a user
        """

