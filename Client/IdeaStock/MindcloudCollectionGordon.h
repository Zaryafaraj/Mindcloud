//
//  MindcloudGordon.h
//  Mindcloud
//
//  Created by Ali Fathalian on 8/24/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MindcloudCollectionGordonDelegate.h"
#import "SynchronizedObject.h"

@interface MindcloudCollectionGordon : NSObject <SynchronizedObject>

-(id) initWithCollectionName: (NSString *) collectionName
                 andDelegate:(id<MindcloudCollectionGordonDelegate>) delegate;

-(NSString *) getImagePathForSubCollectionWithName:(NSString *) subCollectionName;

-(void) addSubCollectionContentWithId: (NSString *) subCollectionId
                          withContent:(NSData *) content
              andCollectionAttributes:(CollectionNoteAttribute *) attributes;

-(void) addSubCollectionContentWithId:(NSString *)subCollectionId
                          withContent:(NSData *)content
                             andImage:(NSData *) img
                         andImageName:(NSString *) imgName
              andCollectionAttributes:(CollectionNoteAttribute *)attributes;

-(void) addCollectionAttributeWithName:(NSString *) stackingName
                             withModel:(StackingModel *)stackingModel;

-(void) setCollectionThumbnailWithData:(NSData *) thumbnailData;

-(void) updateCollectionThumbnailWithImageOfSubCollection:(NSString *) subCollectionId;

-(void) updateSubCollectionContentofSubCollectionWithName:(NSString *) subCollectionName
                                              withContent:(NSData *) content;

-(void) updateCollectionAttributesForSubCollection:(NSString *) subCollectionId
                          withCollectionAttributes:(CollectionNoteAttribute *) collectionAttribute;

-(void) updateCollectionAttributeWithName:(NSString *) attributeName
                             withNewModel:(StackingModel *)stackingModel;

-(void) removeSubCollectionWithId:(NSString *) subCollectionId
                          andName:(NSString *) subCollectionName;

-(void) removeSubCollectionThumbnailForSubCollection:(NSString *) subCollectionId;

-(void) removeSubCollectionWithId:(NSString *) subCollectionId
       forCollectionAttributeOfName:(NSString *) collectionAttributeName;

-(void) removeCollectionAttributeOfName:(NSString *) collectionAttributeName;

-(void) subCollectionisWaitingForImageWithSubCollectionId:(NSString *) subCollectionId
                                                  andSubCollectionName:(NSString *) subCollectionName;
-(void) cleanup;

@end
