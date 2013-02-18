//
//  CollectionRecorder.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionRecorder.h"
@interface CollectionRecorder()
@property (strong, atomic) NSMutableSet * deletedNotes;
@property (strong, atomic) NSMutableSet * updatedNotes;
@property (strong, atomic) NSMutableSet * deletedStacks;
@property (strong, atomic) NSMutableSet * updatedStacks;
@end
@implementation CollectionRecorder

-(id) init
{
    self = [super init];
    self.deletedNotes = [NSMutableSet set];
    self.updatedNotes = [NSMutableSet set];
    self.deletedStacks = [NSMutableSet set];
    self.updatedStacks = [NSMutableSet set];
    return self;
}

-(void) recordDeleteNote:(NSString *)noteId
{
    [self.deletedNotes addObject:noteId];
}

-(void) recordUpdateNote:(NSString *)noteId
{
    [self.updatedNotes addObject:noteId];
}

-(void) recordDeleteStack:(NSString *)stackId
{
    [self.deletedStacks addObject:stackId];
}
-(void) recordUpdateStack:(NSString *)stackId
{
    [self.updatedStacks addObject:stackId];
}

-(NSSet *) getDeletedNotes
{
    return [self.deletedNotes copy];
}

-(NSSet *) getUpdatedNotes
{
    return [self.updatedNotes copy];
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


-(BOOL) hasNoteBeenTouched:(NSString *)noteId
{
    BOOL hasBeenTouched = NO;
    if ([self.updatedNotes containsObject:noteId] ||
        [self.deletedNotes containsObject:noteId])
    {
        hasBeenTouched = YES;
    }
    return hasBeenTouched;
}

-(BOOL) hasAnythingBeenTouched
{
    if ([self.deletedNotes count] == 0 &&
        [self.updatedStacks count] == 0 &&
        [self.updatedNotes count] == 0 &&
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
    [self.deletedNotes removeAllObjects];
    [self.updatedStacks removeAllObjects];
    [self.updatedNotes removeAllObjects];
    [self.deletedStacks removeAllObjects];
}

@end
