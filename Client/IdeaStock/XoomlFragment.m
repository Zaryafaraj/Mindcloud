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
#import "XoomlAttributeDefinitions.h"
#import "NamespaceDefinitions.h"

#define XML_HEADER @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"

@interface XoomlFragment()

@property (strong, nonatomic) DDXMLDocument * doc;

@end

@implementation XoomlFragment


#pragma mark - initiation

//=====================================================================

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
        [root addAttribute:[DDXMLNode attributeWithName:SCHEMA_LOCATION_NAME stringValue:XOOML_XMLNS]];
        [root addAttribute:[DDXMLNode attributeWithName:SCHEMA_VERISON_NAME stringValue:SCHEMA_VERSION]];
        NSString * GUID = [AttributeHelper generateUUID];
        [root addAttribute:[DDXMLNode attributeWithName:GUID_NAME stringValue:GUID]];
        
        DDXMLElement * collectionAttributeContainer = [[DDXMLElement alloc] initWithName: FRAGMENT_NAMESPACE_DATA];
        DDXMLNode * mindcloudXMLNS = [DDXMLNode attributeWithName:XMLNS_NAME stringValue:MINDCLOUD_XMLNS];
        [collectionAttributeContainer addAttribute:mindcloudXMLNS];
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


#pragma mark - conversion

//=====================================================================

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

-(NSString *) description
{
    return [self toXmlString];
}

-(DDXMLDocument *) document
{
    return [self.document copy];
}


#pragma mark - Fragment NamespaceData

//=====================================================================
-(void) addFragmentNamespaceElement:(XoomlFragmentNamespaceElement *) namespaceElement
{
   if (namespaceElement != nil && self.doc != nil && self.doc.rootElement != nil)
   {
       [self.doc.rootElement addChild:namespaceElement.element];
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

-(void) setFragmentNamespaceElementWithId:(NSString *) namespaceId
                               withElement:(XoomlFragmentNamespaceElement *) newNamespaceElement
{
    NSString * xpath = [self xPathForNamespaceFragmentWithId:namespaceId];
    DDXMLElement * namespaceElem = [self getSingleElementWithXPath:xpath];
    
    if (namespaceElem != nil)
    {
        NSUInteger index = [namespaceElem index];
        DDXMLElement * parent = (DDXMLElement *) namespaceElem.parent;
        //ensue the id preserves
        NSString * namespaceElemId = [namespaceElem attributeForName:ITEM_ID].stringValue;
        DDXMLElement * newElement = newNamespaceElement.element;
        [newElement removeAttributeForName:ITEM_ID];
        DDXMLNode * IDAttribute = [DDXMLNode attributeWithName:ITEM_ID stringValue:namespaceElemId];
        [newElement addAttribute:IDAttribute];
        
        [parent removeChildAtIndex:index];
        [parent addChild:newElement];
    }
    else
    {
        [self addFragmentNamespaceElement:newNamespaceElement];
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


-(XoomlFragmentNamespaceElement *) getFragmentNamespaceElementWithNamespaceURL:(NSString *) namespaceName
                   thatContainsNamespaceSubElementWithId:(NSString *) namespaceSubElementId
{
    NSString * xpath  = [self xpathForFragmentNamespaceElementWithNamespaceURL:namespaceName];
    NSArray * allFragmentNamespaceData = [self getAllElementsWithXPath:xpath];
    
    if (allFragmentNamespaceData == nil) return nil;
    
    for (DDXMLElement * element in allFragmentNamespaceData)
    {
        for(DDXMLElement * subElement in element.children)
        {
            NSString * subElementId = [[subElement attributeForName:ITEM_ID] stringValue];
            if ([subElementId isEqualToString:namespaceSubElementId])
            {
                XoomlFragmentNamespaceElement * result = [[XoomlFragmentNamespaceElement alloc] initFromXmlString:element.stringValue];
                return result;
            }
        }
    }
    return nil;
}

-(NSString *) xPathForFragment
{
    return [NSString stringWithFormat:@"/%@", FRAGMENT_NAME];
}

-(NSString *) xPathForFragmentNamespaces
{
    return [NSString stringWithFormat:@"/%@/%@", FRAGMENT_NAME, FRAGMENT_NAMESPACE_DATA];
}

-(NSString *) xpathForFragmentNamespaceElementWithNamespaceURL:(NSString *) namespaceURL
{
    return [NSString stringWithFormat:@"/%@/%@[@xmlns = \"%@\"]", FRAGMENT_NAME, FRAGMENT_NAMESPACE_DATA, namespaceURL];
}

-(NSString *) xPathForNamespaceFragmentWithId:(NSString *) namespaceId
{
    
    return [NSString stringWithFormat:@"/%@/%@[@ID = \"%@\"]", FRAGMENT_NAME, FRAGMENT_NAMESPACE_DATA, namespaceId];
}

#pragma mark - Fragment NamespaceData SubElement

//=====================================================================

-(void) addFragmentNamespaceSubElement:(XoomlNamespaceElement *) subElement
{
    NSString * namespaceURL = subElement.parentNamespace;
    NSString * xpath = [self xPathForFragmentNamespaceDataForNamespaceURL:namespaceURL];
    DDXMLElement * fragmentNamespaceElement = [self getSingleElementWithXPath:xpath];
    
    if (fragmentNamespaceElement == nil)
    {
        XoomlFragmentNamespaceElement * namespaceData = [[XoomlFragmentNamespaceElement alloc] initWithNamespaceURL:namespaceURL];
        [namespaceData addSubElement:subElement];
        [self addFragmentNamespaceElement:namespaceData];
    }
    else
    {
        [fragmentNamespaceElement addChild:subElement.element];
    }
}

-(void) removeFragmentNamespaceSubElementWithName:(NSString *) subElementName
                                  forNamespaceURL:(NSString *)namespaceURL
{
    NSString * xpath = [self xPathForNamespaceFragmentSubElementWithName:subElementName forNamespace:namespaceURL];
    NSArray * allSubElements = [self getAllElementsWithXPath:xpath];
    for (DDXMLElement * subElement in allSubElements)
    {
        NSUInteger index = [subElement index];
        DDXMLElement * parent = (DDXMLElement *) subElement.parent;
        [parent removeChildAtIndex:index];
    }
}

-(void) setFragmentNamespaceSubElementWithElement:(XoomlNamespaceElement *) newNamespaceSubElement
{
    
    NSString * namespaceURL = newNamespaceSubElement.parentNamespace;
    NSString * namespaceSubElementName = newNamespaceSubElement.name;
    NSString * xpath = [self xPathForFragmentNamespaceDataForNamespaceURL:namespaceURL];
    DDXMLElement * fragmentNamespaceElement = [self getSingleElementWithXPath:xpath];
    
    if (fragmentNamespaceElement == nil)
    {
        XoomlFragmentNamespaceElement * namespaceData = [[XoomlFragmentNamespaceElement alloc] initWithNamespaceURL:namespaceURL];
        [namespaceData addSubElement:newNamespaceSubElement];
        [self addFragmentNamespaceElement:namespaceData];
    }
    else
    {
        xpath  = [self xPathForNamespaceFragmentSubElementWithName:namespaceSubElementName forNamespace:namespaceURL];
        NSArray * subElements = [self getAllElementsWithXPath:xpath];
        if (subElements != nil && [subElements count] > 0)
        {
            for (DDXMLElement * subElement in subElements)
            {
                NSUInteger index = [subElement index];
                DDXMLElement * parent = (DDXMLElement *) subElement.parent;
                
                //ensue the id preserves
                NSString * subElementId = [subElement attributeForName:ITEM_ID].stringValue;
                DDXMLElement * newElement = newNamespaceSubElement.element;
                [newElement removeAttributeForName:ITEM_ID];
                DDXMLNode * IDAttribute = [DDXMLNode attributeWithName:ITEM_ID stringValue:subElementId];
                [newElement addAttribute:IDAttribute];
                
                [parent removeChildAtIndex:index];
                [parent addChild:newElement];
            }
        }
        else if (subElements == nil || [subElements count] == 0)
        {
            [fragmentNamespaceElement addChild:newNamespaceSubElement.element];
        }
    }
}

-(NSArray *) getFragmentNamespaceSubElementsWithName:(NSString *) subElementName
                                     forNamespaceURL:(NSString *) namespaceURL
{
    NSString * xpath = [self xPathForNamespaceFragmentSubElementWithName:subElementName forNamespace:namespaceURL];
    NSArray * allSubElement = [self getAllElementsWithXPath:xpath];
    NSMutableArray * result = [NSMutableArray array];
    
    if (allSubElement == nil) return result;
    
    for (DDXMLElement * subElement in allSubElement)
    {
        XoomlNamespaceElement * elem = [[XoomlNamespaceElement alloc] initFromXMLString:subElement.stringValue];
        [result addObject:elem];
    }
    return result;
}

-(NSArray *) getAllFragmentNamespaceSubElementsForNamespaceURL:(NSString *) namespaceURL
{
    NSString * xpath = [self xPathForFragmentNamespaceDataForNamespaceURL:namespaceURL];
    DDXMLElement * fragmentNamespaceData = [self getSingleElementWithXPath:xpath];
    NSMutableArray * result = [NSMutableArray array];
    
    if (fragmentNamespaceData == nil) return result;
    for (DDXMLElement * subElement in fragmentNamespaceData.children)
    {
        XoomlNamespaceElement * elem = [[XoomlNamespaceElement alloc] initFromXMLString:subElement.stringValue];
        [result addObject:elem];
    }
    return result;
}

-(XoomlNamespaceElement *) getFragmentNamespaceSubElementWithId: (NSString *) subElementId
                                                        andName:(NSString *) namespaceDataName
                                               fromNamespaceURL:(NSString *) namespaceURL
{
    NSString * xpath = [self xPathForNamespaceFragmentSubElementWithId:subElementId andName:namespaceDataName forNamespaceURL:namespaceURL];
    DDXMLElement * elem = [self getSingleElementWithXPath:xpath];
    if (elem == nil) return nil;
    
    XoomlNamespaceElement * result = [[XoomlNamespaceElement alloc] initFromXMLString:elem.stringValue];
    return result;
}


-(NSString *) xPathForNamespaceFragmentSubElementWithName:(NSString *) fragmentNamespaceSubelementName
                                             forNamespace:(NSString *) namespaceURL
{
    return [NSString stringWithFormat:@"/%@/%@[@xmlns = \"%@\"]/%@", FRAGMENT_NAME, FRAGMENT_NAMESPACE_DATA, namespaceURL, fragmentNamespaceSubelementName];
}

-(NSString *) xPathForNamespaceFragmentSubElementWithId:(NSString *) fragmentNamespaceSubElementId
                                                andName:(NSString *) fragmentNamespaceSubElementName
                                        forNamespaceURL:(NSString *) namespaceURL
{
    return [NSString stringWithFormat:@"/%@/%@[@xmlns = \"%@\"]/%@[@ID = \"%@\"]", FRAGMENT_NAME, FRAGMENT_NAMESPACE_DATA, namespaceURL, fragmentNamespaceSubElementName, fragmentNamespaceSubElementId];
    
}

-(NSString *) xPathForFragmentNamespaceDataForNamespaceURL:(NSString *) namespaceURL
{
    return [NSString stringWithFormat:@"/%@/%@[@xmlns = \"%@\"]", FRAGMENT_NAME, FRAGMENT_NAMESPACE_DATA, namespaceURL];
}


#pragma mark - Association

//=====================================================================

-(void) addAssociation:(XoomlAssociation *) association
{
    if (association != nil && self.doc != nil && self.doc
        .rootElement != nil)
    {
        [self.doc.rootElement addChild:association.element];
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

-(void) setAssociationWithId:(NSString *) associationId
             withNewAssociation:(XoomlAssociation *) element
{
    NSString * xpath = [self xPathForAssociationWithId:associationId];
    DDXMLElement * associationElem = [self getSingleElementWithXPath:xpath];
    if (associationElem != nil)
    {
        NSUInteger index = [associationElem index];
        DDXMLElement * parent = (DDXMLElement *) associationElem.parent;
        
        //ensue the id preserves
        NSString * oldAssociationId = [associationElem attributeForName:ITEM_ID].stringValue;
        DDXMLElement * newElement = element.element;
        [newElement removeAttributeForName:ITEM_ID];
        DDXMLNode * IDAttribute = [DDXMLNode attributeWithName:ITEM_ID stringValue:oldAssociationId];
        [newElement addAttribute:IDAttribute];
        
        [parent removeChildAtIndex:index];
        [parent addChild:newElement];
    }
    else
    {
        [self addAssociation:element];
    }
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

-(NSString *) xPathForAssociations
{
    return [NSString stringWithFormat:@"/%@/%@", FRAGMENT_NAME, ASSOCIATION_NAME];
}

-(NSString *) xPathForAssociationWithId:(NSString *) associationId
{
    return [NSString stringWithFormat:@"/%@/%@[@ID = \"%@\"]", FRAGMENT_NAME, ASSOCIATION_NAME, associationId];
}




#pragma mark - Association NamespaceData

//=====================================================================

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

-(void) setAssociationNamespaceElementWithAssociationId:(NSString *) associationId
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
        
        //ensue the id preserves
        NSString * oldId = [associationNamespaceElem attributeForName:ITEM_ID].stringValue;
        DDXMLElement * newElement = newNamespaceElement.element;
        [newElement removeAttributeForName:ITEM_ID];
        DDXMLNode * IDAttribute = [DDXMLNode attributeWithName:ITEM_ID stringValue:oldId];
        [newElement addAttribute:IDAttribute];
 
        [parent removeChildAtIndex:index];
        [parent addChild:newElement];
    }
    else
    {
        [self addAssociationNamespaceElement:newNamespaceElement
                         toAssociationWithId:associationId];
    }
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

-(NSString *) xPathForAssociationNamespaceElementsForAssociationWithId:(NSString *) associationId
{
    return [NSString stringWithFormat:@"/%@/%@[@ID = \"%@\"]/%@", FRAGMENT_NAME, ASSOCIATION_NAME, associationId, ASSOCIATON_NAMESPACE_NAME];
}

-(NSString *) xPathForAssociationNamespaceElementWithAssociationId:(NSString *) associationId
                                                    andnamespaceId:(NSString *) namespaceId
{
    return [NSString stringWithFormat:@"/%@/%@[@ID = \"%@\"]/%@[@ID = \"%@\"]", FRAGMENT_NAME, ASSOCIATION_NAME, associationId, ASSOCIATON_NAMESPACE_NAME, namespaceId];
}


#pragma mark -  Helpers

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
@end
