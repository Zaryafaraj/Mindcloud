//
//  XoomlBulletinBoard.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulletinBoardProtocol.h"
#import "CollectionDataSource.h"
#import "CollectionManifestProtocol.h"
#import "CachedCollectionAttributes.h"
#import "SynchronizedObject.h"

#define STACKING @"stacking"
#define GROUPING @"grouping"
#define LINKAGE @"linkage"
#define POSITION @"position"
#define COLLECTION_DOWNLOADED_EVENT @"collectionFilesDownloaded"
#define COLLECTION_RELOAD_EVENT @"CollectionReloaded"

@interface MindcloudCollection : NSObject <BulletinBoardProtocol, SynchronizedObject>

/*
 Reads and fills up a bulletin board from the external structure of the datamodel
 */
- (id) initCollection: (NSString *) collectionName
       withDataSource: (id <CollectionDataSource>) dataSource;
@end
