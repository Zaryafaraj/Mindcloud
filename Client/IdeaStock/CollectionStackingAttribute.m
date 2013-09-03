//
//  StackingModel.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionStackingAttribute.h"
#import "XoomlNamespaceElement.h"
#import "BoardsXoomlDefinitions.h"

@implementation CollectionStackingAttribute

-(id) initWithName:(NSString *)name andScale:(NSString *)scale andRefIds:(NSSet *)refIds
{
    self = [super init];
    _refIds = [refIds copy];
    _name = name;
    _scale = scale;
    return self;
}

-(void) addNotes:(NSSet *) notes
{
    NSMutableSet * newRefs = [NSMutableSet set];
    for(NSString * note in notes)
    {
        [newRefs addObject:note];
    }
    for(NSString * note in _refIds)
    {
        [newRefs addObject:note];
    }
    
    _refIds = newRefs;
}

-(void) deleteNotes:(NSSet *) notes
{
    NSMutableSet * newRefs = [NSMutableSet set];
    for (NSString * note in _refIds)
    {
        if (![notes containsObject:note])
        {
            [newRefs addObject:note];
        }
    }
    _refIds = [newRefs copy];
}

-(XoomlNamespaceElement *) toXoomlNamespaceElement
{
    XoomlNamespaceElement * stackingElem = [[XoomlNamespaceElement alloc] initWithName:MINDCLOUD_STACKING_ATTRIBUTE andParentNamespace:MINDCLOUD_BOARDS_NAMESPACE];
    
    [stackingElem addAttributeWithName:MINDCLOUD_SCALE_ATTRIBUTE andValue:self.scale];
    [stackingElem addAttributeWithName:MINDCLOUD_NAME_ATTRIBUTE andValue:self.name];
    for (NSString * noteRefId in self.refIds)
    {
        XoomlNamespaceElement * noteRef = [[XoomlNamespaceElement alloc] initWithName:MINDCLOUD_NOTE_REFID andParentNamespace:MINDCLOUD_BOARDS_NAMESPACE];
        [noteRef addAttributeWithName:MINDCLOUD_REFID_ATTRIBUTE andValue:noteRefId];
        [stackingElem addSubElement:noteRef];
    }
    return stackingElem;
}

+(instancetype) collectionSTackingAttributeFromNamespaceElement:(XoomlNamespaceElement *) element
{
    if (![element.name isEqualToString:MINDCLOUD_STACKING_ATTRIBUTE]) return nil;
    
    NSString * name = [element getAttributeWithName:MINDCLOUD_NAME_ATTRIBUTE];
    NSString * scaling = [element getAttributeWithName:MINDCLOUD_SCALE_ATTRIBUTE];
    NSMutableSet * noteRefIds = [NSMutableSet set];
    NSDictionary * allSubElements = [element getAllSubElements];
    for(XoomlNamespaceElement * possibleNoteRef in allSubElements)
    {
        if ([possibleNoteRef.name isEqualToString:MINDCLOUD_NOTE_REFID])
        {
            NSString * noteRef = [possibleNoteRef getAttributeWithName:MINDCLOUD_REFID_ATTRIBUTE];
            [noteRefIds addObject:noteRef];
        }
    }
    
    if (name == nil || scaling == nil || noteRefIds == nil || [noteRefIds count] == 0)
    {
        return nil;
    }
    
    return [[CollectionStackingAttribute alloc] initWithName:name andScale:scaling andRefIds:noteRefIds];
    
    
}
@end
