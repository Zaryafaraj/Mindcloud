//
//  MindcloudCollectionGordonDelegate.h
//  Mindcloud
//
//  Created by Ali Fathalian on 8/24/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionNoteAttribute.h"
#import "StackingModel.h"
#import "CollectionRecorder.h"
#import "NotificationContainer.h"

@protocol MindcloudCollectionGordonDelegate <NSObject>
-(void) collectionHasThumbnailAtSubCollectionWithId:(NSString *) subCollectionId;

//TODO this should not be a CollectionNoteAttribute but be generic attribute that the delegate can pick stuff of of
-(void) collectionHasSubCollectionWithId: (NSString *) subCollectionId
                                 andData:(NSData *) data
                           andAttributes:(CollectionNoteAttribute *) attribute;

//TODO send actual NSDATA instead od stacking Model
-(void) collectionHasCollectionAttributeOfType:(NSString *) subCollectionType
                                       andName:(NSString *) collectionName
                                       andData:(StackingModel *) stackingModel;


-(void) subCollectionPartiallyDownloadedWithId:(NSString *) subCollectionId
                                       andData:(NSData *) subCollectionData
                    andSubCollectionAttributes:(CollectionNoteAttribute *) subCollectionAttribute;;

-(CollectionRecorder *) getEventRecorder;

-(void) eventsOccurredWithNotifications: (NotificationContainer *) notifications;

-(void) eventOccuredWithDownloadingOfSubColection:(NSString *) subCollectionId
                             andSubCollectionData:(NSData *) subCollectionData;

-(void) eventOccuredWithDownloadingOfSubCollectionImage:(NSString *) subCollectionId
                                          withImagePath:(NSString *) imagePath
                                   andSubCollectionData:(NSData *) subCollectionData;

-(void) subCollectionWithId:(NSString *) subCollectionId
    downloadedImageWithPath:(NSString *) imagePath;

@end
