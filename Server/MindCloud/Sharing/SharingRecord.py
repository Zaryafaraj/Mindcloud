import json

__author__ = 'afathali'

class SharingRecord:

    SECRET_KEY = 'secret'
    OWNER_KEY = 'owner'
    SUBSCIRBERS_KEY = 'subscribers'
    COLLECTION_NAME_KEY = 'collection_name'

    def __init__(self, sharing_secret, owner_id, collection_name, subscribers):
        """
        Args:
            -``sharing_secret`` : 8 Byte secret ID
            -``owner_id`` : the UUID belonging to the user who initiated the sharing
            -``collection_name``: Name of the collection as it appears in the
            owners account
            - ``subscribers``: A list of (user_id, collection_name) .
            The user_id is the id of the subscriber to the shared space
            the collection_name is the name of the collection as it
            appears in the subscribers account
             """
        self.sharing_secret = sharing_secret
        self.owner_id = owner_id
        self.collection_name = collection_name
        self.subscribers = subscribers

    def toDictionary(self):
         return {SharingRecord.SECRET_KEY : self.sharing_secret,
                          SharingRecord.OWNER_KEY : self.owner_id,
                          SharingRecord.COLLECTION_NAME_KEY : self.collection_name,
                          SharingRecord.SUBSCIRBERS_KEY : self.subscribers}

    def toJson(self):
        dict = self.toDictionary()
        return json.dumps(dict)

    @classmethod
    def fromJson(cls, json_str):
        json_obj = json.loads(json_str)
        sharing_secret = json_obj[SharingRecord.SECRET_KEY]
        owner = json_obj[SharingRecord.OWNER_KEY]
        owner_collection = json_obj[SharingRecord.COLLECTION_NAME_KEY]
        subscribers = json_obj[SharingRecord.SUBSCIRBERS_KEY]
        return SharingRecord(sharing_secret, owner, owner_collection,
            subscribers)

    def get_sharing_secret(self):
        return self.sharing_secret

    def get_owner_collection_name(self):
        return self.collection_name

    def set_owner_collection_name(self, new_collection_name):
        self.collection_name = new_collection_name

    def get_owner_user_id(self):
        return self.owner_id

    def set_collection_name(self, new_name):
        self.collection_name = new_name

    def rename_subscriber_collection_name(self, subscriber_id, old_name, new_name):
        self.remove_subscriber(subscriber_id, old_name)
        self.add_subscriber(subscriber_id, new_name)

    def add_subscriber(self, subscriber_id, subscriber_collection_name):
        subscriber_record = (subscriber_id, subscriber_collection_name)
        if [subscriber_id, subscriber_collection_name] not in self.subscribers:
            self.subscribers.append(subscriber_record)

    def remove_subscriber(self, subscriber_id, collection_name):
        if [subscriber_id,collection_name] in self.subscribers:
            self.subscribers.remove([subscriber_id, collection_name])

    def get_subscribers(self):
        #create a copy of the subscribers so that the user can't modify it
        return list(self.subscribers)

    def get_collection_name_for_subscriber(self, user_id):

        result_list = [ x[1] for x in self.subscribers if x[0] == user_id ]
        if len(result_list) > 0 :
            return result_list[0]
        else:
            return None
