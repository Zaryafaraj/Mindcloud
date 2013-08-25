//
//  XoomlBulletinBoard.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulletinBoardProtocol.h"
#import "SynchronizedObject.h"
#import "ThumbnailManagerProtocol.h"
#import "MindcloudCollectionGordonDelegate.h"

#define STACKING @"stacking"
#define GROUPING @"grouping"
#define LINKAGE @"linkage"
#define POSITION @"position"

@interface MindcloudCollection : NSObject <BulletinBoardProtocol,ThumbnailManagerProtocol, MindcloudCollectionGordonDelegate>

/*
 Reads and fills up a bulletin board from the external structure of the datamodel
 */
- (id) initCollection: (NSString *) collectionName;
- (void) refresh;
- (void) save;
//temporarily until we implement background synch
- (void) pause;

@end
