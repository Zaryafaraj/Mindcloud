import json
from tornado import gen
from Sharing.DeleteSharedNoteAction import DeleteSharedNoteAction
from Sharing.SharingController import SharingController
from Sharing.SharingEvent import SharingEvent
from Sharing.UpdateSharedManifestAction import UpdateSharedManifestAction
from Sharing.UpdateSharedNoteAction import UpdateSharedNoteAction
from Sharing.UpdateSharedNoteImageAction import UpdateSharedNoteImageAction
from Sharing.UpdateSharedThumbnailAction import UpdateSharedThumbnailAction
from Sharing.SendCustomMessageAction import SendCustomMessageAction
from Sharing.SendDiffFileAction import SendDiffFileAction

__author__ = 'afathali'


class SharingActionFactory():
    __USER_ID_KEY = 'user_id'
    __COLLECTION_NAME_KEY = 'collection_name'
    __NOTE_NAME_KEY = 'note_name'

    @staticmethod
    def from_diff_file_and_user(diff_file, user_id, collection_name, resource_path):
        """
        Returns a sharing action from a diff file sent by a user
        """
        sharing_action = SendDiffFileAction(user_id, collection_name,
                                            diff_file, resource_path)
        return sharing_action

    @staticmethod
    def from_custom_message_and_user(custom_message, msg_id, user_id, collection_name):
        """
        Returns a sharing action for sending a custom message
        """
        sharing_action = SendCustomMessageAction(user_id, msg_id, collection_name, custom_message)
        return sharing_action

    @staticmethod
    def from_json_and_file(json_str, custom_file=None):
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

        try:
            json_obj = json.loads(json_str)
            if SharingEvent.UPDATE_MANIFEST in json_obj:
                if custom_file is None:
                    return None

                details = json_obj[SharingEvent.UPDATE_MANIFEST]
                user_id = details[SharingActionFactory.__USER_ID_KEY]
                collection_name = details[SharingActionFactory.__COLLECTION_NAME_KEY]
                sharing_action = UpdateSharedManifestAction(user_id, collection_name, custom_file)
                return sharing_action

            elif SharingEvent.UPDATE_NOTE in json_obj:
                if custom_file is None:
                    return None
                details = json_obj[SharingEvent.UPDATE_NOTE]
                user_id = details[SharingActionFactory.__USER_ID_KEY]
                collection_name = details[SharingActionFactory.__COLLECTION_NAME_KEY]
                note_name = details[SharingActionFactory.__NOTE_NAME_KEY]
                sharing_action = UpdateSharedNoteAction(user_id, collection_name,
                                                        note_name, custom_file)
                return sharing_action

            elif SharingEvent.UPDATE_NOTE_IMG in json_obj:
                if custom_file is None:
                    return None

                details = json_obj[SharingEvent.UPDATE_NOTE_IMG]
                user_id = details[SharingActionFactory.__USER_ID_KEY]
                collection_name = details[SharingActionFactory.__COLLECTION_NAME_KEY]
                note_name = details[SharingActionFactory.__NOTE_NAME_KEY]
                sharing_action = UpdateSharedNoteImageAction(user_id,
                                                             collection_name, note_name, custom_file)
                return sharing_action

            elif SharingEvent.DELETE_NOTE in json_obj:
                details = json_obj[SharingEvent.DELETE_NOTE]
                user_id = details[SharingActionFactory.__USER_ID_KEY]
                collection_name = details[SharingActionFactory.__COLLECTION_NAME_KEY]
                note_name = details[SharingActionFactory.__NOTE_NAME_KEY]
                sharing_action = DeleteSharedNoteAction(user_id, collection_name,
                                                        note_name)
                return sharing_action
            elif SharingEvent.UPDATE_THUMBNAIL:

                if custom_file is None:
                    return None

                details = json_obj[SharingEvent.UPDATE_THUMBNAIL]
                user_id = details[SharingActionFactory.__USER_ID_KEY]
                collection_name = details[SharingActionFactory.__COLLECTION_NAME_KEY]
                sharing_action = UpdateSharedThumbnailAction(user_id, collection_name, custom_file)
                return sharing_action

            else:
                return None

        except Exception:
            return None

    @staticmethod
    @gen.engine
    def create_related_sharing_actions(sharing_secret, sharing_action, callback=None):
        """
        creates all the sharing actions for all the users that have
        subscribed to sharing_secret

        calls the callback with a list of all the related sharing actions
        """

        #get the sharing record for the secret
        sharing_record = \
            yield gen.Task(SharingController.get_sharing_record_by_secret, sharing_secret)

        if sharing_record is None:
            callback(None)
        else:
            #now get the list of all the subscribers
            subscribers = sharing_record.get_subscribers()
            all_actions = [sharing_action]
            for subscriber_info in subscribers:
                user_id = subscriber_info[0]
                collection_name = subscriber_info[1]
                if user_id != sharing_action.get_user_id():
                    related_action = \
                        sharing_action.clone_for_user_and_collection(user_id,
                                                                     collection_name)
                    all_actions.append(related_action)

            if callback is not None:
                callback(all_actions)