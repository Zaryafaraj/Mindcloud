//
//  CollectionRecorder.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionRecorder.h"
@interface CollectionRecorder()
@property (strong, atomic) NSMutableSet * deletedAssociations;
@property (strong, atomic) NSMutableSet * updatedAssociations;
@property (strong, atomic) NSMutableSet * deletedNamespaceElements;
@property (strong, atomic) NSMutableSet * updatedNamespaceElements;
@property (strong, atomic) NSMutableSet * deletedNamespaceSubElements;
@property (strong, atomic) NSMutableSet * updatedNamespaceSubElements;
@property (strong, atomic) NSMutableSet * deletedSubElementChildren;
@property (strong, atomic) NSMutableSet * updatedSubElementChildren;
@end

@implementation CollectionRecorder

-(id) init
{
    self = [super init];
    self.deletedAssociations = [NSMutableSet set];
    self.updatedAssociations = [NSMutableSet set];
    self.deletedNamespaceElements = [NSMutableSet set];
    self.updatedNamespaceElements = [NSMutableSet set];
    self.deletedNamespaceSubElements = [NSMutableSet set];
    self.updatedNamespaceSubElements = [NSMutableSet set];
    self.deletedSubElementChildren = [NSMutableSet set];
    self.updatedSubElementChildren = [NSMutableSet set];
    return self;
}

-(void) recordDeleteAssociation:(NSString *)associationId
{
    [self.deletedAssociations addObject:associationId];
}

-(void) recordUpdateAssociation:(NSString *)associationId
{
    [self.updatedAssociations addObject:associationId];
}

-(void) recordDeleteFragmentNamespaceElement: (NSString *) namespaceElementId
{
    [self.deletedNamespaceElements addObject:namespaceElementId];
}

-(void) recordUpdateFragmentNamespaceElement: (NSString *) namespaceElementId
{
    [self.updatedNamespaceElements addObject:namespaceElementId];
}

-(void) recordDeleteFragmentNamespaceSubElement: (NSString *) fragmentSubElementId
{
    [self.deletedNamespaceSubElements addObject:fragmentSubElementId];
}

-(void) recordUpdateFragmentNamespaceSubElement: (NSString *) fragmentSubElementId
{
    [self.updatedNamespaceSubElements addObject:fragmentSubElementId];
}

-(void) recordUpdateFragmentSubElementsChild:(NSString *) subElementChildId
{
    [self.updatedSubElementChildren addObject:subElementChildId];
}

-(void) recordDeleteFragmentSubElementsChild:(NSString *) subElementChildId
{
    [self.deletedSubElementChildren addObject:subElementChildId];
}

-(NSSet *) getDeletedAssociations
{
    return [self.deletedAssociations copy];
}

-(NSSet *) getUpdatedAssociation
{
    return [self.updatedAssociations copy];
}

-(NSSet *) getDeletedFragmentNamespaceElements
{
    return [self.deletedNamespaceElements copy];
}

-(NSSet *) getUpdatedFragmentNamespaceElements
{
    return [self.updatedNamespaceElements copy];
}

-(NSSet *) getDeletedFragmentNamespaceSubElements
{
    return [self.deletedNamespaceSubElements copy];
}

-(NSSet *) getUpdatedFragmentNamespaceSubElements
{
    return [self.updatedNamespaceSubElements copy];
}

-(NSSet *) getDeletedFragmentSubElementChildren
{
    return [self.deletedSubElementChildren copy];
}

-(NSSet *) getUpdatedFragmentSubElementChildren
{
    return [self.updatedSubElementChildren copy];
}

-(BOOL) hasFragmentNamespaceElementBeenTouched:(NSString *) elementId
{
    
    BOOL hasBeenTouched = NO;
    if ([self.updatedNamespaceElements containsObject: elementId] ||
        [self.deletedNamespaceElements containsObject: elementId])
    {
        hasBeenTouched = YES;
    }
    return hasBeenTouched;
}

-(BOOL) hasFragmentNamespaceSubElementBeenTouched:(NSString *) subElementId
{
    BOOL hasBeenTouched = NO;
    if ([self.updatedNamespaceSubElements containsObject:subElementId] ||
        [self.deletedNamespaceSubElements containsObject:subElementId])
    {
        hasBeenTouched = YES;
    }
    return hasBeenTouched;
}

-(BOOL) hasFragmentSubElementChildBeenTouched:(NSString *) childId
{
    BOOL hasBeenTouched = NO;
    if ([self.updatedSubElementChildren containsObject:childId] ||
        [self.deletedSubElementChildren containsObject:childId])
    {
        hasBeenTouched = YES;
    }
    return hasBeenTouched;
    
}
-(BOOL) hasAssociationBeenTouched:(NSString *)subCollectionId
{
    BOOL hasBeenTouched = NO;
    if ([self.updatedAssociations containsObject:subCollectionId] ||
        [self.deletedAssociations containsObject:subCollectionId])
    {
        hasBeenTouched = YES;
    }
    return hasBeenTouched;
}

-(BOOL) hasAnythingBeenTouched
{
    if ([self.deletedAssociations count] == 0 &&
        [self.updatedNamespaceElements count] == 0 &&
        [self.updatedAssociations count] == 0 &&
        [self.deletedNamespaceElements count] == 0 &&
        [self.updatedNamespaceSubElements count] == 0 &&
        [self.deletedNamespaceSubElements count] == 0 &&
        [self.updatedSubElementChildren count] == 0 &&
        [self.deletedSubElementChildren count] == 0)
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
    [self.deletedAssociations removeAllObjects];
    [self.updatedNamespaceElements removeAllObjects];
    [self.updatedAssociations removeAllObjects];
    [self.deletedNamespaceElements removeAllObjects];
    [self.updatedNamespaceSubElements removeAllObjects];
    [self.deletedNamespaceSubElements removeAllObjects];
    [self.updatedSubElementChildren removeAllObjects];
    [self.deletedSubElementChildren removeAllObjects];
}

@end
