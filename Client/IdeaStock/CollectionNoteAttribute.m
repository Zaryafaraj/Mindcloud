//
//  XoomlNoteModel.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionNoteAttribute.h"
#import "XoomlAssociationNamespaceElement.h"
#import "XoomlNamespaceElement.h"


@implementation CollectionNoteAttribute

-(instancetype) initWithName:(NSString *) noteName
                    andRefId:(NSString *) refId
                andPositionX:(NSString *) positionX
                andPositionY: (NSString *) positionY
                  andScaling:(NSString *) scaling;
{
    self = [super init];
    _noteName = noteName;
    _positionX = positionX;
    _positionY = positionY;
    _scaling = scaling;
    _referencingNoteId = refId;
    return self;
}

-(XoomlAssociation *) toXoomlAssociation
{
    XoomlNamespaceElement * positionElement = [[XoomlNamespaceElement alloc] initWithName:MINDCLOUD_NOTE_ATTRIBUTE andParentNamespace:MINDCLOUD_BOARDS_NAMESPACE];
    [positionElement addAttributeWithName:MINDCLOUD_TYPE andValue:MINDCLOUD_POSITION_TYPE];
    [positionElement addAttributeWithName:MINDCLOUD_POSITION_X andValue:self.positionX];
    [positionElement addAttributeWithName:MINDCLOUD_POSITION_Y andValue:self.positionY];
    
    
    XoomlNamespaceElement * scaleElement = [[XoomlNamespaceElement alloc] initWithName:MINDCLOUD_NOTE_ATTRIBUTE andParentNamespace:MINDCLOUD_BOARDS_NAMESPACE];
    [scaleElement addAttributeWithName:MINDCLOUD_TYPE andValue:MINDCLOUD_SCALE_TYPE];
    [scaleElement addAttributeWithName:MINDCLOUD_SCALE_ATTRIBUTE andValue:self.scaling];
    
    
    XoomlAssociationNamespaceElement * associationNamespaceElement = [[XoomlAssociationNamespaceElement alloc] initWithNamespaceOwner:MINDCLOUD_BOARDS_NAMESPACE];
    
    [associationNamespaceElement addSubElement:positionElement];
    [associationNamespaceElement addSubElement:scaleElement];
    XoomlAssociation * result = [[XoomlAssociation alloc] initWithAssociatedItem:self.noteName andAssociatedItemRefId:self.referencingNoteId];
    
    [result addAssociationNamespaceElement:associationNamespaceElement];
    return result;
}

+(instancetype) CollectionNoteAttributeFromAssociation:(XoomlAssociation *) association
{
    NSString * noteName = association.associatedItem;
    NSString * refId = association.refId;
    NSString * positionX = @"100";
    NSString * positionY = @"100";
    NSString * scaling = @"1";
    NSDictionary * allNamespaceAssociationData = [association getAllAssociationNamespaceElement];
    for(NSString * associationNamespaceId in allNamespaceAssociationData)
    {
        XoomlAssociationNamespaceElement * namespaceElement = allNamespaceAssociationData[associationNamespaceId];
        if ([namespaceElement.namespaceOwner isEqualToString:MINDCLOUD_BOARDS_NAMESPACE])
        {
            NSDictionary * allAssociationSubElements = [namespaceElement getAllXoomlAssociationNamespaceSubElements];
            for (NSString * associationSubElementId in allAssociationSubElements)
            {
                XoomlNamespaceElement * namespaceElement = allAssociationSubElements[associationSubElementId];
                NSString * type = [namespaceElement getAttributeWithName:MINDCLOUD_TYPE];
                if (type != nil)
                {
                    if ([type isEqualToString:MINDCLOUD_POSITION_TYPE])
                    {
                        positionX = [namespaceElement getAttributeWithName:MINDCLOUD_POSITION_X];
                        positionY = [namespaceElement getAttributeWithName:MINDCLOUD_POSITION_Y];
                    }
                    else if ([type isEqualToString:MINDCLOUD_SCALE_TYPE])
                    {
                        scaling = [namespaceElement getAttributeWithName:MINDCLOUD_SCALE_ATTRIBUTE];
                    }
                }
            }
        }
    }
    
    
    CollectionNoteAttribute * attribute = [[CollectionNoteAttribute alloc] initWithName:noteName
                                                                               andRefId:refId
                                                                           andPositionX:positionX
                                                                           andPositionY:positionY
                                                                             andScaling:scaling];
    return attribute;
}

@end
