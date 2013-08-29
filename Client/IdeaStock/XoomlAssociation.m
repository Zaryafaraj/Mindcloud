//
//  XoomlAssociation.m
//  Mindcloud
//
//  Created by Ali Fathalian on 8/26/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "XoomlAssociation.h"

#define ASSOCIATION_ID @"ID"

@interface XoomlAssociation()

@property (strong, nonatomic) DDXMLElement * element;
@property (strong, nonatomic) NSString * ID;
@end

@implementation XoomlAssociation

-(id) initWithXMLString:(NSString *) xmlString
{
    self = [super init];
    
    if (self == nil) return nil;
    
    NSError * err = nil;
    DDXMLElement * element = [[DDXMLElement alloc] initWithXMLString:xmlString error:&err];
    if (element == nil)
    {
        NSLog(@"XoomlAssociation - Error creating XoomlAssociation with Error %@", err.description);
        return nil;
    }
    
    DDXMLNode * IdNode = [element attributeForName:ASSOCIATION_ID];
    if (IdNode)
    {
        self.ID = IdNode.stringValue;
    }
    else
    {
        self.ID = 
    }
    if
    for (DDXMLNode * attribute in element.attributes)
    {
        NSString * attributeName = [attribute.stringValue]
    }
    
}

-(NSString *) toXMLString
{
    if (self.element)
    {
        return [self.element stringValue];
    }
    return nil;
}

/*! Keyed on the AssociationNamespaceElementId and valued on XoomlAssociationNamespaceElement obj
 Immutable.
 */
-(NSDictionary *) getAllAssociationNamespaceElement
{
    
}

/*! Keyed on the id of the XoomlAssociationNamespaceElement and valued on the
 XoomlAssociationNamespaceElement
 */
-(NSDictionary *) addAssociationNamespaceElement:(XoomlAssociationNamespaceElement *) data
{
    
}

-(void) removeAssociationNamespaceElementWithId:(NSString *) ID
{
    
}

@end
