//
//  CollectionRecorder.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionRecorder.h"
@interface CollectionRecorder()
@property (strong, atomic) NSMutableSet * deletedSubCollections;
@property (strong, atomic) NSMutableSet * updatedSubCollections;
@property (strong, atomic) NSMutableSet * deletedStacks;
@property (strong, atomic) NSMutableSet * updatedStacks;
@end
@implementation CollectionRecorder

-(id) init
{
    self = [super init];
    self.deletedSubCollections = [NSMutableSet set];
    self.updatedSubCollections = [NSMutableSet set];
    self.deletedStacks = [NSMutableSet set];
    self.updatedStacks = [NSMutableSet set];
    return self;
}

-(void) recordDeleteSubCollection:(NSString *)subCollectionId
{
    [self.deletedSubCollections addObject:subCollectionId];
}

-(void) recordUpdateSubCollection:(NSString *)subCollectionId
{
    [self.updatedSubCollections addObject:subCollectionId];
}

-(void) recordDeleteStack:(NSString *)stackId
{
    [self.deletedStacks addObject:stackId];
}
-(void) recordUpdateStack:(NSString *)stackId
{
    [self.updatedStacks addObject:stackId];
}

-(NSSet *) getDeletedSubCollections
{
    return [self.deletedSubCollections copy];
}

-(NSSet *) getUpdatedSubCollections
{
    return [self.updatedSubCollections copy];
}

-(NSSet *) getDeletedStacks
{
    return [self.deletedStacks copy];
}

-(NSSet *) getUpdatedStacks
{
    return [self.updatedStacks copy];
}

-(BOOL) hasStackingBeenTouched:(NSString *)stackingId
{
    
    BOOL hasBeenTouched = NO;
    if ([self.updatedStacks containsObject:stackingId] ||
        [self.deletedStacks containsObject:stackingId])
    {
        hasBeenTouched = YES;
    }
    return hasBeenTouched;
}


-(BOOL) hasSubCollectionBeenTouched:(NSString *)subCollectionId
{
    BOOL hasBeenTouched = NO;
    if ([self.updatedSubCollections containsObject:subCollectionId] ||
        [self.deletedSubCollections containsObject:subCollectionId])
    {
        hasBeenTouched = YES;
    }
    return hasBeenTouched;
}

-(BOOL) hasAnythingBeenTouched
{
    if ([self.deletedSubCollections count] == 0 &&
        [self.updatedStacks count] == 0 &&
        [self.updatedSubCollections count] == 0 &&
        [self.deletedStacks count] == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(void) reset
{
    [self.deletedSubCollections removeAllObjects];
    [self.updatedStacks removeAllObjects];
    [self.updatedSubCollections removeAllObjects];
    [self.deletedStacks removeAllObjects];
}

@end
