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
#define THUMBNAIL_RECEIVED_EVENT @"thumbnailReceivedEvent"
#define IMAGE_DOWNLOADED_EVENT @"imageDownloaded"
#define NOTE_IMAGE_READY_EVENT @"noteImageReadyEvent"

@end
