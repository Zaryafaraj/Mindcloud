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

@protocol MindcloudCollectionDelegate<NSObject>

-(void) collectionDidSave;

@end

@interface MindcloudCollection : NSObject <BulletinBoardProtocol,
ThumbnailManagerProtocol,
MindcloudCollectionGordonDelegate>

@property (nonatomic, weak) id<MindcloudCollectionDelegate> delegate;

/*
 Reads and fills up a bulletin board from the external structure of the datamodel
 */
- (id) initCollection: (NSString *) collectionName;
- (void) refresh;
- (void) save;
//temporarily until we implement background synch
- (void) pause;
- (void) promiseSaving;
@end
