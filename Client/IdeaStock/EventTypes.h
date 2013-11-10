// //  EventTypes.h
//  Mindcloud //
//  Created by Ali Fathalian on 1/10/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EventTypes <NSObject>

#define COLLECTION_DOWNLOADED_EVENT @"collectionFilesDownloaded"
#define COLLECTION_DOWNLOADED_EVENT @"collectionFilesDownloaded"
#define COLLECTION_RELOAD_EVENT @"CollectionReloaded"
#define ALL_COLLECTIONS_LIST_DOWNLOADED_EVENT @"allCollectionListDownloaded"
#define CATEGORIES_RECEIVED_EVENT @"categoriesReceivedEvent"
#define COLLECTION_IMAGE_RECEIVED_EVENT @"thumbnailReceivedEvent"
#define IMAGE_DOWNLOADED_EVENT @"imageDownloaded"
#define ASSOCIATION_IMAGE_READY_EVENT @"associationImageReadyEvent"
#define FRAGMENT_MERGE_FINISHED_EVENT @"FragmentMergeFinishedEvent"

//subCollection resolutoin events
#define ASSOCIATION_RESOLVED_EVENT @"associationResolvedEvent"
//Events resulting from an event from the listerner controller to UI
#define ASSOCIATION_UPDATED_EVENT @"associationUpdatedEvent"
#define ASSOCIATION_DELETED_KEY @"AssociationDeletedEvent"
#define ASSOCIATION_ADDED_EVENT @"AssociationAddedEvent"
#define ASSOCIATION_WITH_IMAGE_ADDED_EVENT @"imagesAssociationAdded"
#define STACK_UPDATED_EVENT @"stackUpdated"
#define STACK_DELETED_EVENT @"stackDeleted"
#define STACK_ADDED_EVENT @"stackAdded"
#define ASSOCIATION_CONTENT_UPDATED_EVENT @"AssociationContentUpdated"
#define ASSOCIATION_IMAGE_UPDATED_EVENT @"AssociationImageUpdated"

//Events resulting from something happening to the listener
#define LISTENER_DOWNLOADED_ASSOCIATION @"listenerDownloadedsubCollection"
#define LISTENER_DOWNLOADED_IMAGE @"listenerDownloadedImage"
#define LISTENER_DELETED_ASSOCIATION @"listenerDeletedAssociation"
#define LISTENER_DOWNLOADED_FRAGMENT @"listenerDownloadedFragment"

//Sharing management
#define COLLECTION_SHARED @"collectionShared"
#define COLLECTION_UNSHARED @"collectionUnshared"
#define COLLECTIION_SUBSCRIBER @"collectionSubscribed"
#define SUBSCRIBED_TO_COLLECTION @"subscribedToCollection"

//single collection sharing
#define COLLECTION_IS_SHARED @"collectionIsShared"
#define LISTENER_RETURNED @"listenerReturned"


//Server Failures
#define CONNECTION_FAILED @"connectionFailed"

//Synch events
#define CACHE_IS_IN_SYNCH_WITH_SERVER @"cacheIsInSynch"


//File Managed ment
#define DRAWING_DOWNLOADED_EVENT @"drawingDownloaded"
@end
