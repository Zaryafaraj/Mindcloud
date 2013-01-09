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

@interface MindcloudCollection : NSObject <BulletinBoardProtocol>

/*
 Creates an internal model for the bulletin board which is empty 
 and updates the data model for to have an external representation of
 the bulletin board. 
 */
- (id)initEmptyBulletinBoardWithDataModel: (id <CollectionDataSource>) dataModel
                                  andName:(NSString *) bulletinBoardName;
/*
 Reads and fills up a bulletin board from the external structure of the datamodel
 */
- (id)initBulletinBoardFromXoomlWithDatamodel: (id <CollectionDataSource>) datamodel 
                                      andName: (NSString *) bulletinBoardName;

-(id) initBulletinBoardFromXoomlWithName:(NSString *)bulletinBoardName;

@end
