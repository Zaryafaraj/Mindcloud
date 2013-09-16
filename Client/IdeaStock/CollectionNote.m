//
//  XoomlNote.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CollectionNote.h"
#import "AttributeHelper.h"

#define DEFAULT_IMAGE_NAME @"img.jpg"
@implementation CollectionNote

@synthesize noteText = _noteText;
@synthesize noteId = _noteID;
@synthesize image = _image;
@synthesize name = _name;

-(CollectionNote *) initEmptyNoteWithID: (NSString *) noteID
                                andName:(NSString *) noteName{
    self = [[CollectionNote alloc] init];
    self.noteId = noteID;
    self.name = noteName;
    return self;
}

-(CollectionNote *) initEmptyNoteWithID:(NSString *)noteID 
                                   andDate: (NSString *)date{
    self = [[CollectionNote alloc] init];
    self.noteId = noteID;
    return self;
}

-(CollectionNote *) initWithText: (NSString *) text{

    self = [[CollectionNote alloc] init];
    self.noteId = [AttributeHelper generateUUID];
    self.noteText = text;
    return  self;
}

-(CollectionNote *) initWithText:(NSString *)text
                       andNoteId:(NSString *) noteId
{
    self = [[CollectionNote alloc] init];
    self.noteId = noteId;
    self.noteText = text;
    return  self;
}

- (NSString *) description{
    return self.noteText;
}

-(void) setImageAsDefaultFragmentImage
{
    self.image = DEFAULT_IMAGE_NAME;
}

-(CollectionNote *) initWithXoomlFragment:(XoomlFragment *) fragment
{
    NSDictionary * allAssociations = [fragment getAllAssociations];
    for(NSString * associationId in allAssociations)
    {
        XoomlAssociation * association = allAssociations[associationId];
        if ([association isSelfReferncing])
        {
            NSString * displayText = association.displayText;
            NSString * noteID = association.ID;
            NSString * noteImg = nil;
            NSString * noteName = nil;
            NSDictionary * allAssociationNamespaceElements = [association getAllAssociationNamespaceElement];
            for (NSString * associationNamespaceElementId in allAssociationNamespaceElements)
            {
                XoomlAssociationNamespaceElement * associationNamespaceElement = allAssociationNamespaceElements[associationNamespaceElementId];
                if ([associationNamespaceElement.namespaceOwner isEqualToString:MINDCLOUD_BOARDS_NAMESPACE])
                {
                    NSDictionary * allSubElements = [associationNamespaceElement getAllXoomlAssociationNamespaceSubElements];
                    for (NSString * subElementId in allSubElements)
                    {
                        XoomlNamespaceElement * elem = allSubElements[subElementId];
                        if([elem.name isEqualToString:MINDCLOUD_NOTE_NAME_ATTRIBUTE])
                        {
                            noteName = [elem getAttributeWithName:MINDCLOUD_NOTE_NAME];
                        }
                        if ([elem.name isEqualToString:MINDCLOUD_NOTE_IMAGE_ATTRIBUTE])
                        {
                            noteImg = [elem getAttributeWithName:MINDCLOUD_NOTE_IMAGE];
                        }
                    }
                }
            }
            CollectionNote * note = [[CollectionNote alloc] initWithText:displayText
                                                               andNoteId:noteID];
            if (noteImg)
            {
                note.image = noteImg;
            }
            if (noteName)
            {
                note.name = noteName;
            }
            
            return note;
        }
    }
    return nil;
}

-(instancetype) prototype
{
    CollectionNote * prototype = [[CollectionNote alloc] initWithText:self.noteText andNoteId:self.noteId];
    prototype.name = self.name;
    prototype.image = self.image;
    return prototype;
}

-(XoomlFragment *) toXoomlFragment
{
    XoomlFragment * fragment = [[XoomlFragment alloc] initAsEmpty];
    
    XoomlAssociation * association = [[XoomlAssociation alloc] initSelfReferencingAssociationWithDisplayText:self.noteText
                                                                                                   andSelfId:self.noteId];
    
    XoomlAssociationNamespaceElement * associationNamespaceData = [[XoomlAssociationNamespaceElement alloc] initWithNamespaceOwner:MINDCLOUD_BOARDS_NAMESPACE];
    
    if (self.name)
    {
        XoomlNamespaceElement * namespaceElement = [[XoomlNamespaceElement alloc] initWithName:MINDCLOUD_NOTE_NAME_ATTRIBUTE andParentNamespace:MINDCLOUD_BOARDS_NAMESPACE];
        
        [namespaceElement addAttributeWithName:MINDCLOUD_NOTE_NAME andValue:self.name];
        [associationNamespaceData addSubElement:namespaceElement];
    }
    
    if (self.image)
    {
        XoomlNamespaceElement * namespaceElement = [[XoomlNamespaceElement alloc] initWithName:MINDCLOUD_NOTE_IMAGE_ATTRIBUTE andParentNamespace:MINDCLOUD_BOARDS_NAMESPACE];
        
        [namespaceElement addAttributeWithName:MINDCLOUD_NOTE_IMAGE andValue:self.image];
        [associationNamespaceData addSubElement:namespaceElement];
        
    }
    
    [association addAssociationNamespaceElement:associationNamespaceData];
    [fragment addAssociation:association];
    
    return fragment;
}

@end
