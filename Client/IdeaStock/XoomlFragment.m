//
//  XoomlDocument.m
//  Mindcloud
//
//  Created by Ali Fathalian on 8/29/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "XoomlFragment.h"
#import "DDXMLElement.h"
#import "DDXMLDocument.h"
#import "AttributeHelper.h"

#define FRAGMENT_NAME @"fragment"
#define ASSOCIATION_NAME @"association"

#define XML_HEADER @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
#define XOOML_XMLNS @"http://kftf.ischool.washington.edu/xmlns/xooml"
#define XML_XSI @"http://www.w3.org/2001/XMLSchema-instance"
#define MINDCLOUD_XMLNS @"http://mindcloud.io/xmlns/mindcloud"

#define SCHEMA_VERISON_NAME @"schemaVersion"
#define SCHEMA_VERSION @"2"
#define SCHEMA_LOCATION_NAME @"schemaLocation"
#define XOOML_SCHEMA_LOCATION @"http://kftf.ischool.washington.edu/xmlns/xooml"
#define ITEM_DRIVER_NAME @"itemDriver"
#define XOOML_DRIVER_NAME @"xooMLDriver"
#define SYNC_DRIVER_NAME @"syncDriver"
#define ITEM_DESCRIBED_NAME @"itemDescribed"
#define GORDON @"gordon"
#define BANE @"bane"
#define JOKER @"joker"

#define FRAGMENT_NAMESPACE_DATA @"fragmentNamespaceData"

#define GUID_NAME @"GUIDGeneratedOnLastWrite"

@interface XoomlFragment()

@property (strong, nonatomic) DDXMLDocument * doc;

@end

@implementation XoomlFragment

-(id) initWithXMLString:(NSString *) xmlString
{
    self = [super init];
    
    if (self == nil) return nil;
    
    NSError * err = nil;
    self.doc = [[DDXMLDocument alloc] initWithXMLString:xmlString
                                                options:0 error:&err];
    if (self.doc == nil)
    {
        NSLog(@"XoomlFragment - Error creating XoomlAssociationNamespaceElement with Error %@", err.description);
        return nil;
    }
    return self;
}

-(id) initWithDocument:(DDXMLDocument *) document
{
    if (document != nil)
    {
        self = [super init];
        if (self)
        {
            self.doc = document;
        }
    }
    return self;
}

-(id) initAsEmpty
{
    self = [super init];
    if (self)
    {
        DDXMLElement * root = [[DDXMLElement alloc] initWithName:FRAGMENT_NAME];
        [root addNamespace: [DDXMLNode namespaceWithName:@"xmlns" stringValue: XOOML_XMLNS]];
        [root addNamespace: [DDXMLNode namespaceWithName:@"xsi" stringValue: XML_XSI]];
        [root addNamespace: [DDXMLNode namespaceWithName:@"mindcloud" stringValue: MINDCLOUD_XMLNS]];
        [root addAttribute:[DDXMLNode attributeWithName:ITEM_DRIVER_NAME stringValue:BANE]];
        [root addAttribute:[DDXMLNode attributeWithName:XOOML_DRIVER_NAME stringValue:GORDON]];
        [root addAttribute:[DDXMLNode attributeWithName:SYNC_DRIVER_NAME stringValue:JOKER]];
        [root addAttribute:[DDXMLNode attributeWithName:ITEM_DESCRIBED_NAME stringValue:@"."]];
        [root addAttribute:[DDXMLNode attributeWithName:SCHEMA_LOCATION_NAME stringValue:XOOML_SCHEMA_LOCATION]];
        [root addAttribute:[DDXMLNode attributeWithName:SCHEMA_VERISON_NAME stringValue:SCHEMA_VERSION]];
        NSString * GUID = [AttributeHelper generateUUID];
        [root addAttribute:[DDXMLNode attributeWithName:GUID_NAME stringValue:GUID]];
        
        DDXMLElement * collectionAttributeContainer = [[DDXMLElement alloc] initWithName: FRAGMENT_NAMESPACE_DATA];
        [root addChild:collectionAttributeContainer];
        
        NSString *xmlString = [root description];
        NSString *xmlHeader = XML_HEADER;
        xmlString = [xmlHeader stringByAppendingString:xmlString];
        
        NSError * err = nil;
        self.doc = [[DDXMLDocument alloc] initWithXMLString:xmlString
                                                    options:0 error:&err];
        if (self.doc == nil)
        {
            NSLog(@"XoomlFragment - Error creating XoomlAssociationNamespaceElement with Error %@", err.description);
            return nil;
        }
    }
    return self;
}

-(id) copy
{
    if (self.doc == nil) return nil;
    
    XoomlFragment * prototype = [[XoomlFragment alloc] initWithXMLString:self.doc.XMLString];
    return prototype;
}

-(NSString *) toXmlString
{
    if (self.doc == nil) return nil;
    NSData * xml = self.data;
    return [[NSString alloc] initWithData:xml encoding:NSUTF8StringEncoding];
}

-(NSData *) data
{
    if (self.doc == nil) return nil;
    return [[self.doc XMLData] copy];
}

-(void) addFragmentNamespaceElement:(XoomlFragmentNamespaceElement *) namespaceElement
{
   if (namespaceElement != nil && self.doc != nil && self.doc.rootElement != nil)
   {
       [self.doc.rootElement addChild:namespaceElement.element];
   }
}

-(void) addAssociation:(XoomlAssociation *) association
{
    if (association != nil && self.doc != nil && self.doc
        .rootElement != nil)
    {
        [self.doc.rootElement addChild:association.element];
    }
}

-(void) addAssociationNamespaceElement:(XoomlAssociationNamespaceElement *) namespaceElement
                   toAssociationWithId:(NSString *) associationId
{
    NSString * xpath = [self xPathForAssociationWithId:associationId];
    DDXMLElement * association = [self getSingleElementWithXPath:xpath];
    if (association)
    {
        [association addChild:namespaceElement.element];
    }
}

-(void) removeFragmentNamespaceElement:(NSString *) namespaceId
{
    NSString * xpath = [self xPathForNamespaceFragmentWithId:namespaceId];
    DDXMLElement * namespaceElem = [self getSingleElementWithXPath:xpath];
    if (namespaceElem != nil)
    {
        NSUInteger index = [namespaceElem index];
        DDXMLElement * parent = (DDXMLElement *) namespaceElem.parent;
        [parent removeChildAtIndex:index];
    }
}


-(void) removeAssociation:(NSString *) associationId
{
    NSString * xpath = [self xPathForAssociationWithId:associationId];
    DDXMLElement * associationElem = [self getSingleElementWithXPath:xpath];
    if (associationElem != nil)
    {
        NSUInteger index = [associationElem index];
        DDXMLElement * parent = (DDXMLElement *) associationElem.parent;
        [parent removeChildAtIndex:index];
    }
    
}

-(void) removeAssociationNamespaceElementWithAssociationId:(NSString *) associationId
                          andAssociationNamespaceElementId:(NSString *) namespaceId
{
    NSString * xpath = [self xPathForAssociationNamespaceElementWithAssociationId:associationId
                                                                   andnamespaceId:namespaceId];
    DDXMLElement * associationNamespaceElem = [self getSingleElementWithXPath:xpath];
    if (associationNamespaceElem != nil)
    {
        NSUInteger index = [associationNamespaceElem index];
        DDXMLElement * parent = (DDXMLElement *) associationNamespaceElem.parent;
        [parent removeChildAtIndex:index];
    }
}



-(void) updateFragmentNamespaceElementWith:(NSString *) namespaceId
                               withElement:(XoomlFragmentNamespaceElement *) newNamespaceElement
{
    NSString * xpath = [self xPathForNamespaceFragmentWithId:namespaceId];
    DDXMLElement * namespaceElem = [self getSingleElementWithXPath:xpath];
    if (namespaceElem != nil)
    {
        NSUInteger index = [namespaceElem index];
        DDXMLElement * parent = (DDXMLElement *) namespaceElem.parent;
        [parent removeChildAtIndex:index];
        [parent addChild:newNamespaceElement.element];
    }
    
}

-(void) updateAssociationWithId:(NSString *) associationId
             withNewAssociation:(XoomlAssociationNamespaceElement *) element
{
    NSString * xpath = [self xPathForAssociationWithId:associationId];
    DDXMLElement * associationElem = [self getSingleElementWithXPath:xpath];
    if (associationElem != nil)
    {
        NSUInteger index = [associationElem index];
        DDXMLElement * parent = (DDXMLElement *) associationElem.parent;
        [parent removeChildAtIndex:index];
        [parent addChild:element.element];
    }
    
}

-(void) updateAssociationNamespaceElementWithAssociationId:(NSString *) associationId
                                     andNamespaceElementId:(NSString *) namespaceId
                                            withNewElement:(XoomlAssociationNamespaceElement *) newNamespaceElement
{
    NSString * xpath = [self xPathForAssociationNamespaceElementWithAssociationId:associationId
                                                                   andnamespaceId:namespaceId];
    DDXMLElement * associationNamespaceElem = [self getSingleElementWithXPath:xpath];
    if (associationNamespaceElem != nil)
    {
        NSUInteger index = [associationNamespaceElem index];
        DDXMLElement * parent = (DDXMLElement *) associationNamespaceElem.parent;
        [parent removeChildAtIndex:index];
        [parent addChild:newNamespaceElement.element];
    }
}

/*! Keyed on fragmentId and valued on XoomlFragmentNamespaceElement objects
 */
-(NSDictionary *) getAllFragmentNamespaceElements
{
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    NSString * xPath = [self xPathForFragmentNamespaces];
    NSArray * allFragmentNamespaces = [self getAllElementsWithXPath:xPath];
    if (allFragmentNamespaces != nil)
    {
        for(DDXMLElement * elem in allFragmentNamespaces)
        {
            XoomlFragmentNamespaceElement * namespaceElem = [[XoomlFragmentNamespaceElement alloc] initFromXmlString:elem.stringValue];
            if (namespaceElem.ID)
            {
                result[namespaceElem.ID] = namespaceElem;
            }
        }
    }
    return  result;
}

-(XoomlFragmentNamespaceElement *) getFragmentNamespaceElementWithId:(NSString *) namespaceId
{
    NSString * xpath = [self xPathForNamespaceFragmentWithId:namespaceId];
    DDXMLElement * namespaceElem = [self getSingleElementWithXPath:xpath];
    if (namespaceElem != nil)
    {
        XoomlFragmentNamespaceElement * elem = [[XoomlFragmentNamespaceElement alloc] initFromXmlString:namespaceElem.stringValue];
        return elem;
    }
    return nil;
}

/*! Keyed on associationId and valued on Xooml
 */
-(NSDictionary *) getAllAssociations
{
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    NSString * xpath = [self xPathForAssociations];
    NSArray * allAssociations = [self getAllElementsWithXPath:xpath];
    if (allAssociations != nil)
    {
       for (DDXMLElement * elem in allAssociations)
       {
           XoomlAssociation * association = [[XoomlAssociation alloc] initWithXMLString:elem.stringValue];
           if (association.ID)
           {
               result[association.ID] = association;
           }
       }
    }
    return result;
}

-(XoomlAssociation *) getAssociationWithId:(NSString *) associationId
{
    NSString * xpath = [self xPathForAssociationWithId:associationId];
    DDXMLElement * associationElem = [self getSingleElementWithXPath:xpath];
    if (associationElem != nil)
    {
        XoomlAssociation * association = [[XoomlAssociation alloc] initWithXMLString:associationElem.stringValue];
        return association;
    }
    return nil;
}

/*! Keyed on associationNamespace element and valued on XoomlAssociationNamespaceelement
 */
-(NSDictionary *) getAssocationNamespaceElementsForAssocation:(NSString *) associationId
{
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    NSString * xpath = [self xPathForAssociationNamespaceElementsForAssociationWithId:associationId];
    NSArray * allAssociationNamespaceElements = [self getAllElementsWithXPath:xpath];
    if (allAssociationNamespaceElements != nil)
    {
       for (DDXMLElement * elem in allAssociationNamespaceElements)
       {
           XoomlAssociationNamespaceElement * namespaceElem = [[XoomlAssociationNamespaceElement alloc] initFromXMLString:elem.stringValue];
           if (namespaceElem.ID)
           {
               result[namespaceElem.ID] = namespaceElem;
           }
       }
    }
    return result;
}

-(XoomlAssociationNamespaceElement *) getAssocationNamespaceElementWithId:(NSString *) namespaceId
                                                           forAssociation:(NSString *) associationId
{
    NSString * xpath = [self xPathForAssociationNamespaceElementWithAssociationId:associationId
                                                                   andnamespaceId:namespaceId];
    DDXMLElement * associationNamespaceElem = [self getSingleElementWithXPath:xpath];
    if (associationNamespaceElem != nil)
    {
        XoomlAssociationNamespaceElement * elem = [[XoomlAssociationNamespaceElement alloc] initFromXMLString:associationNamespaceElem.stringValue];
        return elem;
    }
    return nil;
}

-(NSString *) xPathForFragmentNamespaces
{
    return [NSString stringWithFormat:@"/%@/%@", FRAGMENT_NAME, FRAGMENT_NAMESPACE_DATA];
}

-(NSString *) xPathForAssociations
{
    return [NSString stringWithFormat:@"/%@/%@", FRAGMENT_NAME, ASSOCIATION_NAME];
}

-(NSString *) xPathForAssociationWithId:(NSString *) associationId
{
    return [NSString stringWithFormat:@"/%@/%@[@ID = \"%@\"]", FRAGMENT_NAME, ASSOCIATION_NAME, associationId];
}

-(NSString *) xPathForNamespaceFragmentWithId:(NSString *) namespaceId
{
    
    return [NSString stringWithFormat:@"/%@/%@[@ID = \"%@\"]", FRAGMENT_NAME, FRAGMENT_NAMESPACE_DATA, namespaceId];
}

-(NSString *) xPathForAssociationNamespaceElementsForAssociationWithId:(NSString *) associationId
{
    return [NSString stringWithFormat:@"/%@/%@[@ID = \"%@\"]/%@", FRAGMENT_NAME, ASSOCIATION_NAME, associationId, ASSOCIATON_NAMESPACE_NAME];
}

-(NSString *) xPathForAssociationNamespaceElementWithAssociationId:(NSString *) associationId
                                                    andnamespaceId:(NSString *) namespaceId
{
    return [NSString stringWithFormat:@"/%@/%@[@ID = \"%@\"]/%@[@ID = \"%@\"]", FRAGMENT_NAME, ASSOCIATION_NAME, associationId, ASSOCIATON_NAMESPACE_NAME, namespaceId];
}

-(DDXMLElement *) getSingleElementWithXPath:(NSString *) xpath
{
    
    NSArray * elements = [self getAllElementsWithXPath:xpath];
    if (elements)
    {
        return [elements lastObject];
    }
    return nil;
}

-(NSArray *) getAllElementsWithXPath:(NSString *) xpath
{
    NSError * err;
    NSArray *elements = [self.doc.rootElement nodesForXPath: xpath error: &err];
    
    if (elements == nil){
        NSLog(@"XoomlFragment-Error reading the content from XML");
        return nil;
    }
    
    if ([elements count] == 0 ){
        NSLog(@"XoomlFragment- No element found for item with xpath");
        return nil;
    }
    return elements;
}
-(NSString *) description
{
    return [self toXmlString];
}

-(DDXMLDocument *) document
{
    return [self.document copy];
}

@end
