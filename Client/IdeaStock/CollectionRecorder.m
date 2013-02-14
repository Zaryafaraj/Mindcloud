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

-(void) reset
{
    [self.deletedNotes removeAllObjects];
    [self.updatedStacks removeAllObjects];
    [self.updatedNotes removeAllObjects];
    [self.deletedStacks removeAllObjects];
}

@end
