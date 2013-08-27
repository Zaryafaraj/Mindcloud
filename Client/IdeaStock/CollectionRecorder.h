//
//  CollectionRecorder.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectionRecorder : NSObject

-(void) recordDeleteSubCollection:(NSString *) subCollectionId;
-(void) recordUpdateSubCollection:(NSString *) subCollectionId;
-(void) recordDeleteStack:(NSString *) stackId;
-(void) recordUpdateStack:(NSString *) stackId;

-(NSSet *) getDeletedSubCollections;
-(NSSet *) getDeletedStacks;
-(NSSet *) getUpdatedSubCollections;
-(NSSet *) getUpdatedStacks;

-(BOOL) hasStackingBeenTouched:(NSString *) stackingId;
-(BOOL) hasSubCollectionBeenTouched:(NSString *) subCollectionId;
-(BOOL) hasAnythingBeenTouched;
-(void) reset;
@end
