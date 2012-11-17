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



    def getOwnerCollectionName(self):
        return self.collection_name
