//
//  XoomlAssociation.m
//  Mindcloud
//
//  Created by Ali Fathalian on 8/26/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "XoomlAssociation.h"
#import "AttributeHelper.h"

#define ASSOCIATION_ID @"ID"
#define ASSOCIATON_NAME @"association"
#define ASSOCIATED_ITEM @"associatedItem"
#define DISPLAY_TEXT @"displayText"
#define LOCAL_ITEM @"localItem"
#define ASSOCIATED_XOOML_FRAGMENT @"associatedXooMLFragment"
#define ASSOCIATED_XOOML_DRIVER @"associatedXooMLDriver"
#define CURRENT_FRAGMENT @"./XooML2.xml";
#define GORDON_DRIVER @"Gordon"
#define ASSOCIATION_REF_ID @"refId"

@interface XoomlAssociation()

@property (strong, nonatomic) DDXMLElement * element;
@property BOOL isSelfReferencing;

@end

@implementation XoomlAssociation

-(void) setID:(NSString *)ID
{
    _ID = ID;
    if (self.element)
    {
        DDXMLNode * newId = [DDXMLNode attributeWithName:ASSOCIATION_ID
                                             stringValue:_ID];
        [self.element removeAttributeForName:ASSOCIATION_ID];
        [self.element addAttribute:newId];
    }
}

-(id) initWithAssociatedItem:(NSString *) associatedItem
         andAssociatedItemRefId:(NSString *) refId;
{
    
    self = [self initWithAssociatedItem:associatedItem];
    if (self)
    {
        _refId = refId;
        DDXMLNode * refNode = [DDXMLNode attributeWithName:ASSOCIATION_REF_ID stringValue:refId];
        [self.element addAttribute:refNode];
    }
    return self;
}

-(id) initWithAssociatedItem:(NSString *) associatedItem
{
    self = [super init];
    if (self)
    {
        self.isSelfReferencing = NO;
        _ID  = [AttributeHelper generateUUID];
        _associatedXoomlDriver = GORDON_DRIVER;
        _associatedItem = associatedItem;
        _displayText = associatedItem;
        _localItem = associatedItem;
        _associatedXooMLFragment = [NSString stringWithFormat:@"%@/XooML2.xml", associatedItem];
        DDXMLNode * idNode = [DDXMLNode attributeWithName:ASSOCIATION_ID stringValue:_ID];
        DDXMLNode * associatedItemNode = [DDXMLNode attributeWithName:ASSOCIATED_ITEM stringValue:_associatedItem];
        DDXMLNode * displayTextNode = [DDXMLNode attributeWithName:DISPLAY_TEXT stringValue:_displayText];
        DDXMLNode * localItemNode = [DDXMLNode attributeWithName:LOCAL_ITEM stringValue:_localItem];
        DDXMLNode * associatedXoomlFragmentNode = [DDXMLNode attributeWithName:ASSOCIATED_XOOML_FRAGMENT stringValue:_associatedXooMLFragment];
        DDXMLNode * associatedXooMLDriver = [DDXMLNode attributeWithName:ASSOCIATED_XOOML_DRIVER stringValue:_associatedXoomlDriver];
        self.element = [DDXMLElement elementWithName:ASSOCIATON_NAME];
        [self.element addAttribute:idNode];
        [self.element addAttribute:associatedItemNode];
        [self.element addAttribute:displayTextNode];
        [self.element addAttribute:localItemNode];
        [self.element addAttribute:associatedXoomlFragmentNode];
        [self.element addAttribute:associatedXooMLDriver];
    }
    return self;
    
}
-(id) initSelfReferencingAssociationWithDisplayText:(NSString *) displayText andSelfId:(NSString *)ID
{
    
    self = [super init];
    if (self)
    {
        _ID  = ID;
        self.isSelfReferencing = YES;
        _associatedXoomlDriver = GORDON_DRIVER;
        _associatedItem = @"";
        _displayText = displayText;
        _localItem = @"";
        _refId = ID;
        _associatedXooMLFragment = @"";
        DDXMLNode * idNode = [DDXMLNode attributeWithName:ASSOCIATION_ID stringValue:_ID];
        DDXMLNode * refNode = [DDXMLNode attributeWithName:ASSOCIATION_REF_ID stringValue:_refId];
        DDXMLNode * associatedItemNode = [DDXMLNode attributeWithName:ASSOCIATED_ITEM stringValue:_associatedItem];
        DDXMLNode * displayTextNode = [DDXMLNode attributeWithName:DISPLAY_TEXT stringValue:_displayText];
        DDXMLNode * localItemNode = [DDXMLNode attributeWithName:LOCAL_ITEM stringValue:_localItem];
        DDXMLNode * associatedXoomlFragmentNode = [DDXMLNode attributeWithName:ASSOCIATED_XOOML_FRAGMENT stringValue:_associatedXooMLFragment];
        DDXMLNode * associatedXooMLDriver = [DDXMLNode attributeWithName:ASSOCIATED_XOOML_DRIVER stringValue:_associatedXoomlDriver];
        self.element = [DDXMLElement elementWithName:ASSOCIATON_NAME];
        [self.element addAttribute:idNode];
        [self.element addAttribute:associatedItemNode];
        [self.element addAttribute:displayTextNode];
        [self.element addAttribute:localItemNode];
        [self.element addAttribute:associatedXoomlFragmentNode];
        [self.element addAttribute:associatedXooMLDriver];
        [self.element addAttribute:refNode];
    }
    return self;
}

-(id) initWithXMLString:(NSString *) xmlString
{
    self = [super init];
    
    if (self == nil) return nil;
    
    NSError * err = nil;
    self.element = [[DDXMLElement alloc] initWithXMLString:xmlString error:&err];
    if (self.element == nil)
    {
        NSLog(@"XoomlAssociation - Error creating XoomlAssociation with Error %@", err.description);
        return nil;
    }
    
    DDXMLNode * IdNode = [self.element attributeForName:ASSOCIATION_ID];
    if (IdNode)
    {
        _ID = IdNode.stringValue;
    }
    else
    {
        _ID = [AttributeHelper generateUUID];
        IdNode = [DDXMLNode attributeWithName:ASSOCIATION_ID
                                       stringValue:_ID];
        [self.element addAttribute:IdNode];
    }
    
    DDXMLNode * associatedItemNode = [self.element attributeForName:ASSOCIATED_ITEM];
    if (associatedItemNode)
    {
        _associatedItem = associatedItemNode.stringValue;
        if ([_associatedItem isEqualToString:@""] || [_associatedItem isEqualToString:@"."])
        {
            self.isSelfReferencing = YES;
        }
    }
    else
    {
        _associatedItem = @".";
        self.isSelfReferencing = YES;
        associatedItemNode = [DDXMLNode attributeWithName:ASSOCIATED_ITEM stringValue:_associatedItem];
        [self.element addAttribute: associatedItemNode];
    }
    
    DDXMLNode * displayTextNode = [self.element attributeForName:DISPLAY_TEXT];
    if (displayTextNode) _displayText = displayTextNode.stringValue;
    
    DDXMLNode * localItemNode = [self.element attributeForName:LOCAL_ITEM];
    if (localItemNode) _localItem = localItemNode.stringValue;
    
    DDXMLNode * associatedXooMLFragmentNode = [self.element attributeForName:ASSOCIATED_XOOML_FRAGMENT];
    if (associatedXooMLFragmentNode)
    {
        _associatedXooMLFragment = associatedXooMLFragmentNode.stringValue;
        if ([_associatedXooMLFragment isEqualToString:@""] || [_associatedXooMLFragment isEqualToString:@"."])
        {
            self.isSelfReferencing = YES;
        }
        else
        {
            self.isSelfReferencing = NO;
        }
    }
    
    DDXMLNode * associatedXoomlDriverNode = [self.element attributeForName:ASSOCIATED_XOOML_DRIVER];
    if (associatedXoomlDriverNode) _associatedXoomlDriver = associatedXooMLFragmentNode.stringValue;
    
    return self;
}

-(NSString *) toXMLString
{
    if (self.element)
    {
        return self.element.XMLString;
    }
    return nil;
}

-(void) setAssociatedItem:(NSString *)associatedItem
{
    _associatedItem = associatedItem;
    DDXMLNode * newAttNode = [DDXMLNode attributeWithName:ASSOCIATED_ITEM
                                              stringValue:associatedItem];
    [self.element removeAttributeForName:ASSOCIATED_ITEM];
    [self.element addAttribute:newAttNode];
}

-(void) setDisplayText:(NSString *)displayText
{
    _displayText = displayText;
    DDXMLNode * newAttNode = [DDXMLNode attributeWithName:DISPLAY_TEXT
                                              stringValue:displayText];
    [self.element removeAttributeForName:DISPLAY_TEXT];
    [self.element addAttribute:newAttNode];
}

-(void) setLocalItem:(NSString *)localItem
{
    _localItem = localItem;
    DDXMLNode * newAttNode = [DDXMLNode attributeWithName:LOCAL_ITEM
                                              stringValue:localItem];
    [self.element removeAttributeForName:LOCAL_ITEM];
    [self.element addAttribute:newAttNode];
}

-(void) setAssociatedXooMLFragment:(NSString *)associatedXooMLFragment
{
    _associatedXooMLFragment = associatedXooMLFragment;
    DDXMLNode * newAttNode = [DDXMLNode attributeWithName:ASSOCIATED_XOOML_FRAGMENT
                                              stringValue:associatedXooMLFragment];
    [self.element removeAttributeForName:ASSOCIATED_XOOML_FRAGMENT];
    [self.element addAttribute:newAttNode];
}

-(void) setAssociatedXoomlDriver:(NSString *)associatedXoomlDriver
{
    _associatedXoomlDriver = associatedXoomlDriver;
    DDXMLNode * newAttNode = [DDXMLNode attributeWithName:ASSOCIATED_XOOML_DRIVER
                                              stringValue:associatedXoomlDriver];
    [self.element removeAttributeForName:ASSOCIATED_XOOML_DRIVER];
    [self.element addAttribute:newAttNode];
}

/*! Keyed on the AssociationNamespaceElementId and valued on XoomlAssociationNamespaceElement obj
 Immutable.
 */
-(NSDictionary *) getAllAssociationNamespaceElement
{
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    
    if (self.element == nil) return result;
    
    for (DDXMLElement * elem in self.element.children)
    {
        XoomlAssociationNamespaceElement * namespaceElement = [[XoomlAssociationNamespaceElement alloc] initFromXMLString:elem.description];
        result[namespaceElement.ID] = namespaceElement;
    }
    
    return result;
}

/*! Keyed on the id of the XoomlAssociationNamespaceElement and valued on the
 XoomlAssociationNamespaceElement
 */
-(void) addAssociationNamespaceElement:(XoomlAssociationNamespaceElement *) data
{
    if (self.element == nil) return;
    
    DDXMLElement * namespaceElement = [DDXMLElement  elementWithName:ASSOCIATON_NAMESPACE_NAME
                                                         stringValue:[data toXMLString]];
    
    [self.element addChild:namespaceElement];
}

-(XoomlAssociationNamespaceElement *) getAssociationNamespaceElementWithId:(NSString *) namespaceId
{
    if (self.element == nil) return nil;
    
    for (DDXMLElement * elem in self.element.children)
    {
        XoomlAssociationNamespaceElement * namespaceElement = [[XoomlAssociationNamespaceElement alloc] initFromXMLString:elem.description];
        if ([namespaceElement.ID isEqualToString:namespaceId])
        {
            return namespaceElement;
        }
    }
    
    return nil;
}

-(void) removeAssociationNamespaceElementWithId:(NSString *) ID
{
    if (self.element == nil) return;
    
    NSUInteger index;
    BOOL found = NO;
    
    for (DDXMLElement * elem in self.element.children)
    {
        XoomlAssociationNamespaceElement * namespaceElement = [[XoomlAssociationNamespaceElement alloc] initFromXMLString:elem.description];
        if ([namespaceElement.ID isEqualToString:ID])
        {
            found = YES;
            index = elem.index;
        }
    }
    
    if (found)
    {
        [self.element removeChildAtIndex:index];
    }
}

-(BOOL) isSelfReferncing
{
    return _isSelfReferencing;
}

-(NSString *) description
{
    return self.element.stringValue;
}
@end

