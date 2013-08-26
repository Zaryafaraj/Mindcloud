//
//  EventTypes.h
//  Mindcloud
//
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
#define SUBCOLLECTION_IMAGE_READY_EVENT @"subCollectionImageReadyEvent"
#define MANIFEST_MERGE_FINISHED_EVENT @"manifestMergeFinished"

//subCollection resolutoin events
#define SUB_COLLECTION_RESOLVED_EVENT @"subCollectionResolvedEvent"
//Events resulting from an event from the listerner controller to UI
#define SUBCOLLECTION_UPDATED_EVENT @"subCollectionUpdatedEvent"
#define SUBCOLLECTION_DELETED_KEY @"subCollectionDeletedEvent"
#define SUBCOLLECTION_ADDED_EVENT @"subCollectionAddedEvent"
#define SUBCOLLECTION_WITH_IMAGE_ADDED_EVENT @"imagesubCollectionAdded"
#define STACK_UPDATED_EVENT @"stackUpdated"
#define STACK_DELETED_EVENT @"stackDeleted"
#define STACK_ADDED_EVENT @"stackAdded"
#define SUBCOLLECTION_CONTENT_UPDATED_EVENT @"subCollectionContentUpdated"
#define SUBCOLLECTION_IMAGE_UPDATED_EVENT @"subCollectionImageUpdated"

//Events resulting from something happening to the listener
#define LISTENER_DOWNLOADED_SUBCOLLECTION @"listenerDownloadedsubCollection"
#define LISTENER_DOWNLOADED_IMAGE @"listenerDownloadedImage"
#define LISTENER_DELETED_SUBCOLLECTION @"listenerDeletedImage"
#define LISTENER_DOWNLOADED_MANIFEST @"listenerDownloadedManifest"

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
@end
