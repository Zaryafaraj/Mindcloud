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
        [root addNamespace: [DDXMLNode namespaceWithName:@"xooml" stringValue: XOOML_XMLNS]];
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
        DDXMLNode * namespaceElementID = [DDXMLNode attributeWithName:ID_ATTRIBUTE stringValue:[AttributeHelper generateUUID]];
        [collectionAttributeContainer addAttribute:mindcloudXMLNS];
        [collectionAttributeContainer addAttribute:namespaceElementID];
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

-(void) setFragmentNamespaceElement:(XoomlFragmentNamespaceElement *)newNamespaceElement
{
    
    NSArray * AllNamespaceElems = [self  getXMLFragmentNamespaceElementWithNamespace:newNamespaceElement.namespaceName];
    DDXMLElement * namespaceElem = [AllNamespaceElems firstObject];
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
    NSArray * allFragmentNamespaces = [self getXMLAllFragmentNamespaces];
    if (allFragmentNamespaces != nil)
    {
        for(DDXMLElement * elem in allFragmentNamespaces)
        {
            XoomlFragmentNamespaceElement * namespaceElem = [[XoomlFragmentNamespaceElement alloc] initFromXmlString:elem.description];
            if (namespaceElem.ID)
            {
                result[namespaceElem.ID] = namespaceElem;
            }
        }
    }
    return  result;
}

-(XoomlFragmentNamespaceElement *) getFragmentNamespaceElementWithNamespaceName:(NSString *) namespaceName
                                          thatContainsNamespaceSubElementWithId:(NSString *) namespaceSubElementId
{
    NSArray * allFragmentNamespaceData = [self getXMLFragmentNamespaceElementWithNamespace:namespaceName];
    
    if (allFragmentNamespaceData == nil) return nil;
    
    for (DDXMLElement * element in allFragmentNamespaceData)
    {
        for(DDXMLElement * subElement in element.children)
        {
            NSString * subElementId = [[subElement attributeForName:ITEM_ID] stringValue];
            if ([subElementId isEqualToString:namespaceSubElementId])
            {
                XoomlFragmentNamespaceElement * result = [[XoomlFragmentNamespaceElement alloc] initFromXmlString:element.description];
                return result;
            }
        }
    }
    return nil;
}

#pragma mark - Fragment NamespaceData SubElement

//=====================================================================

-(void) addFragmentNamespaceSubElement:(XoomlNamespaceElement *) subElement
{
    NSString * namespaceName = subElement.parentNamespace;
    
    NSArray * allElems = [self getXMLFragmentNamespaceElementWithNamespace:namespaceName];
    DDXMLElement * fragmentNamespaceElement = nil;
    if (allElems != nil &&
        [allElems count] > 0)
    {
        fragmentNamespaceElement = allElems[0];
    }
    
    if (fragmentNamespaceElement == nil)
    {
        XoomlFragmentNamespaceElement * namespaceData = [[XoomlFragmentNamespaceElement alloc] initWithNamespaceName:namespaceName];
        
        [namespaceData addSubElement:subElement];
        [self addFragmentNamespaceElement:namespaceData];
    }
    else
    {
        [fragmentNamespaceElement addChild:subElement.element];
    }
}

-(void) removeFragmentNamespaceSubElementWithName:(NSString *) subElementName
                                     forNamespace:(NSString *)namespaceName
{
    NSArray * allSubElements = [self getXMLFragmentNamespaceSubElementsWithName:subElementName inNamespace:namespaceName];
    for (DDXMLElement * subElement in allSubElements)
    {
        NSUInteger index = [subElement index];
        DDXMLElement * parent = (DDXMLElement *) subElement.parent;
        [parent removeChildAtIndex:index];
    }
}

-(void) removeFragmentNamespaceSubElementWithId:(NSString *) subElementId
                                        andName:(NSString *) fragmentName
                                  fromNamespace:(NSString *) namespaceName
{
    NSArray * allSubElems = [self getXMLFragmentNAmespaceSubElementsWithId:subElementId
                                                                   andName:fragmentName
                                                             fromNamespace:namespaceName];
    
    DDXMLElement * elem = allSubElems[0];
    
    if (elem)
    {
        NSUInteger index = [elem index];
        DDXMLElement * parent = (DDXMLElement *) elem.parent;
        [parent removeChildAtIndex:index];
    }
}

-(void) setFragmentNamespaceSubElementWithElement:(XoomlNamespaceElement *) newNamespaceSubElement
{
    
    NSString * namespaceName = newNamespaceSubElement.parentNamespace;
    NSString * namespaceSubElementName = newNamespaceSubElement.name;
    NSArray * allElems = [self getXMLFragmentNamespaceElementWithNamespace:namespaceName];
    DDXMLElement * fragmentNamespaceElement = allElems[0];
    
    if (fragmentNamespaceElement == nil)
    {
        XoomlFragmentNamespaceElement * namespaceData = [[XoomlFragmentNamespaceElement alloc] initWithNamespaceName:namespaceName];
        [namespaceData addSubElement:newNamespaceSubElement];
        [self addFragmentNamespaceElement:namespaceData];
    }
    else
    {
        NSArray * subElements = [self getXMLFragmentNamespaceSubElementsWithName:namespaceSubElementName
                                                                     inNamespace:namespaceName];
        if (subElements != nil && [subElements count] > 0)
        {
            for (DDXMLElement * subElement in subElements)
            {
                NSString * subElementId = [subElement attributeForName:ITEM_ID].stringValue;
                
                if ([subElementId isEqualToString:newNamespaceSubElement.ID])
                {
                    
                    
                    NSUInteger index = [subElement index];
                    DDXMLElement * parent = (DDXMLElement *) subElement.parent;
                    
                    //ensue the id preserves
                    
                    DDXMLElement * newElement = newNamespaceSubElement.element;
                    [newElement removeAttributeForName:ITEM_ID];
                    DDXMLNode * IDAttribute = [DDXMLNode attributeWithName:ITEM_ID stringValue:subElementId];
                    [newElement addAttribute:IDAttribute];
                    [parent removeChildAtIndex:index];
                    [newElement detach];
                    [parent addChild:newElement];
                }
            }
        }
        else if (subElements == nil || [subElements count] == 0)
        {
            
            NSUInteger index = newNamespaceSubElement.element.index;
            DDXMLElement * parent = (DDXMLElement *) newNamespaceSubElement.element.parent;
            if (parent != nil)
            {
                [parent removeChildAtIndex:index];
            }
            [fragmentNamespaceElement addChild:newNamespaceSubElement.element];
        }
    }
}

-(NSArray *) getFragmentNamespaceSubElementsWithName:(NSString *) subElementName
                                        forNamespace:(NSString *) namespaceName
{
    NSArray * allSubElement = [self getXMLFragmentNamespaceSubElementsWithName:subElementName
                                                                   inNamespace:namespaceName];
    NSMutableArray * result = [NSMutableArray array];
    
    if (allSubElement == nil) return result;
    
    for (DDXMLElement * subElement in allSubElement)
    {
        XoomlNamespaceElement * elem = [[XoomlNamespaceElement alloc] initFromXMLString:subElement.description];
        [result addObject:elem];
    }
    return result;
}

-(NSArray *) getAllFragmentNamespaceSubElementsForNamespace:(NSString *) namespaceName
{
    NSArray * allElems = [self getXMLFragmentNamespaceElementWithNamespace:namespaceName];
    NSMutableArray * result = [NSMutableArray array];
    if (allElems == nil || [allElems count] == 0) return result;
    
    DDXMLElement * fragmentNamespaceData = allElems[0];
    

    
    if (fragmentNamespaceData == nil) return result;
    for (DDXMLElement * subElement in fragmentNamespaceData.children)
    {
        XoomlNamespaceElement * elem = [[XoomlNamespaceElement alloc] initFromXMLString:subElement.description];
        [result addObject:elem];
    }
    return result;
}

-(XoomlNamespaceElement *) getFragmentNamespaceSubElementWithId: (NSString *) subElementId
                                                        andName:(NSString *) namespaceDataName
                                                  fromNamespace:(NSString *) namespaceName
{
    NSArray * allSubElems = [self getXMLFragmentNAmespaceSubElementsWithId:subElementId
                                                                   andName:namespaceDataName
                                                             fromNamespace:namespaceName];
    
    DDXMLElement * elem = [allSubElems firstObject];
    if (elem == nil) return nil;
    
    XoomlNamespaceElement * result = [[XoomlNamespaceElement alloc] initFromXMLString:elem.description];
    return result;
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
    NSArray * associations = [self getXMLAssociationWithId:associationId];
    
    if (associations == nil || [associations count] ==0) return;
    
    DDXMLElement * associationElem = associations[0];
    if (associationElem != nil)
    {
        NSUInteger index = [associationElem index];
        DDXMLElement * parent = (DDXMLElement *) associationElem.parent;
        [parent removeChildAtIndex:index];
    }
}

-(void) removeAllAssociationsWithAssociatedFragmentName:(NSString *) associatedFragmentName
{
    NSArray * allAssociations = [self getXMLAllAssociations];
    for(DDXMLElement * association in allAssociations)
    {
        NSString * currentAssociatedFragmentName = [association attributeForName:ASSOCIATED_ITEM].stringValue;
        if ([currentAssociatedFragmentName isEqualToString:associatedFragmentName])
        {
            NSUInteger index = [association index];
            DDXMLElement * parent = (DDXMLElement *) association.parent;
            [parent removeChildAtIndex:index];
        }
    }
}

-(void) setAssociation:(XoomlAssociation *) association;
{
    NSString * associationId = association.ID;
    NSArray * associations = [self getXMLAssociationWithId:associationId];
    
    if (associations == nil || [associations count] == 0)
    {
        [self addAssociation:association];
        
    }
    else
    {
        DDXMLElement * associationElem = associations[0];
        if (associationElem != nil)
        {
            NSUInteger index = [associationElem index];
            DDXMLElement * parent = (DDXMLElement *) associationElem.parent;
            
            //ensue the id preserves
            NSString * oldAssociationId = [associationElem attributeForName:ITEM_ID].stringValue;
            DDXMLElement * newElement = association.element;
            [newElement removeAttributeForName:ITEM_ID];
            DDXMLNode * IDAttribute = [DDXMLNode attributeWithName:ITEM_ID stringValue:oldAssociationId];
            [newElement addAttribute:IDAttribute];
            
            [parent removeChildAtIndex:index];
            [parent addChild:newElement];
        }
    }
}

/*! Keyed on associationId and valued on Xooml
 */
-(NSDictionary *) getAllAssociations
{
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    NSArray * allAssociations = [self getXMLAllAssociations];
    if (allAssociations != nil)
    {
        for (DDXMLElement * elem in allAssociations)
        {
            XoomlAssociation * association = [[XoomlAssociation alloc] initWithXMLString:elem.XMLString];
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
    
    NSArray * associations = [self getXMLAssociationWithId:associationId];
    
    if (associations == nil && [associations count] == 0) return nil;
        
    DDXMLNode * associationElem = associations[0];
    
    if (associationElem != nil)
    {
        XoomlAssociation * association = [[XoomlAssociation alloc] initWithXMLString:associationElem.XMLString];
        return association;
    }
    return nil;
}

-(XoomlAssociation *) getAssociationWithRefId:(NSString *) associationRefId
{
    NSArray * associations = [self getXMLAssociationWithRefId:associationRefId];
    
    if (associations == nil || [associations count] == 0) return nil;
    
    DDXMLNode * associationElem = associations[0];
    
    if (associationElem != nil)
    {
        XoomlAssociation * association = [[XoomlAssociation alloc] initWithXMLString:associationElem.XMLString];
        return association;
    }
    return nil;
}

-(NSArray *) getAssociationsWithAssociatedItem:(NSString *) associatedItem
{
    NSArray * associations = [self getXMLAssociationWithAssociatedItem:associatedItem];
    NSMutableArray * result = [NSMutableArray array];
    for (DDXMLElement * associationElem in associations)
    {
        XoomlAssociation * association = [[XoomlAssociation alloc] initWithXMLString:associationElem.XMLString];
        [result addObject:association];
    }
    return result;
}
#pragma mark - Association NamespaceData

//=====================================================================

-(void) addAssociationNamespaceElement:(XoomlAssociationNamespaceElement *) namespaceElement
                   toAssociationWithId:(NSString *) associationId
{
    NSArray * associations = [self getXMLAssociationWithId:associationId];
    DDXMLElement * association = associations[0];
    if (association)
    {
        [association addChild:namespaceElement.element];
    }
}

-(void) removeAssociationNamespaceElementWithAssociationId:(NSString *) associationId
                          andAssociationNamespaceElementId:(NSString *) namespaceId
{
    NSArray * allSubElemens = [self getXMLASsociationNamespaceElementsForAssociationWithId:associationId
                                                                          andNamespaceName:namespaceId];
    DDXMLElement * associationNamespaceElem = allSubElemens[0];
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
    NSArray * allSubElemens = [self getXMLASsociationNamespaceElementsForAssociationWithId:associationId
                                                                          andNamespaceName:namespaceId];
    DDXMLElement * associationNamespaceElem = allSubElemens[0];
    
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
    
    NSArray * allAssociationNamespaceElements = [self getXMLAssociationNamespaceElementsForAssociationWithId:associationId];
    if (allAssociationNamespaceElements != nil)
    {
        for (DDXMLElement * elem in allAssociationNamespaceElements)
        {
            XoomlAssociationNamespaceElement * namespaceElem = [[XoomlAssociationNamespaceElement alloc] initFromXMLString:elem.XMLString];
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
    NSArray * allSubElemens = [self getXMLASsociationNamespaceElementsForAssociationWithId:associationId
                                                                          andNamespaceName:namespaceId];
    DDXMLElement * associationNamespaceElem = allSubElemens[0];
    if (associationNamespaceElem != nil)
    {
        XoomlAssociationNamespaceElement * elem = [[XoomlAssociationNamespaceElement alloc] initFromXMLString:associationNamespaceElem.XMLString];
        return elem;
    }
    return nil;
}

#pragma mark -  Helpers

-(DDXMLElement *) getXMLFragment
{
    return self.doc.rootElement;
}

-(NSArray *) getXMLAllFragmentNamespaces
{
    NSMutableArray * result = [NSMutableArray array];
    for (DDXMLElement * child in self.doc.rootElement.children)
    {
        if ([child.name isEqualToString:FRAGMENT_NAMESPACE_DATA])
        {
            [result addObject:child];
        }
    }
    return result;
}

-(NSArray *) getXMLFragmentNamespaceElementWithNamespace:(NSString *) namespaceName
{
    NSMutableArray * result = [NSMutableArray array];
    for (DDXMLElement * child in self.doc.rootElement.children)
    {
        if ([child.name isEqualToString:FRAGMENT_NAMESPACE_DATA])
        {
            NSArray * namespaces = [child namespaces];
            if (namespaces == nil || [namespaces count] == 0) continue;
            
            DDXMLNode * childNamespaceNode = namespaces[0];
            if (childNamespaceNode != nil &&
                [childNamespaceNode.stringValue isEqualToString:namespaceName])
            {
                [result addObject:child];
            }
        }
    }
    return result;
}

-(NSArray *) getXMLFragmentNamespaceSubElementsWithName: (NSString *) name
                                            inNamespace:(NSString *) namespaceName
{
    NSMutableArray * result = [NSMutableArray array];
    NSArray * allChildren = [self.doc.rootElement.children copy];
    for (DDXMLElement * child in allChildren)
    {
        if ([child.name isEqualToString:FRAGMENT_NAMESPACE_DATA])
        {
            NSArray * namespaces = [child namespaces];
            if (namespaces == nil || [namespaces count] == 0) continue;
            
            DDXMLNode * childNamespaceNode = namespaces[0];
            if (childNamespaceNode != nil &&
                [childNamespaceNode.stringValue isEqualToString:namespaceName])
            {
                NSArray * subElementChildren = child.children;
                for(DDXMLElement * subElementChild in subElementChildren)
                {
                    if ([subElementChild.name isEqualToString:name])
                    {
                        [result addObject:subElementChild];
                    }
                }
            }
        }
    }
    return result;
}

-(NSArray *) getXMLFragmentNAmespaceSubElementsWithId:(NSString *) subElementId
                                              andName:(NSString *) subElementName
                                        fromNamespace:(NSString *) namespaceName
{
    NSMutableArray * result = [NSMutableArray array];
    for (DDXMLElement * child in self.doc.rootElement.children)
    {
        if ([child.name isEqualToString:FRAGMENT_NAMESPACE_DATA])
        {
            NSArray * namespaces = [child namespaces];
            if (namespaces == nil || [namespaces count] == 0) continue;
            
            DDXMLNode * childNamespaceNode = namespaces[0];
            if (childNamespaceNode != nil &&
                [childNamespaceNode.stringValue isEqualToString:namespaceName])
            {
                for(DDXMLElement * subElementChild in child.children)
                {
                    DDXMLNode * idAttributeNode = [subElementChild attributeForName:ID_ATTRIBUTE];
                    
                    if ([subElementChild.name isEqualToString:subElementName] &&
                        idAttributeNode != nil &&
                        [idAttributeNode.stringValue isEqualToString:subElementId])
                    {
                        [result addObject:subElementChild];
                    }
                }
            }
        }
    }
    return result;
}

-(NSArray *) getXMLAllAssociations
{
    NSMutableArray * result = [NSMutableArray array];
    for (DDXMLElement * child in self.doc.rootElement.children)
    {
        if ([child.name isEqualToString:ASSOCIATION_NAME])
        {
            [result addObject:child];
        }
    }
    return result;
}

-(NSArray *) getXMLAssociationWithId:(NSString *) associationId
{
    NSMutableArray * result = [NSMutableArray array];
    for (DDXMLElement * child in self.doc.rootElement.children)
    {
        if ([child.name isEqualToString:ASSOCIATION_NAME])
        {
            DDXMLNode * childIdNode = [child attributeForName:ID_ATTRIBUTE];
            if (childIdNode != nil &&
                [childIdNode.stringValue isEqualToString:associationId])
            {
                [result addObject:child];
                
            }
            
        }
    }
    return result;
}

-(NSArray *) getXMLAssociationWithRefId:(NSString *) refId
{
    NSMutableArray * result = [NSMutableArray array];
    for (DDXMLElement * child in self.doc.rootElement.children)
    {
        if ([child.name isEqualToString:ASSOCIATION_NAME])
        {
            DDXMLNode * childRefIdNode = [child attributeForName:REF_ID];
            if (childRefIdNode != nil &&
                [childRefIdNode.stringValue isEqualToString:refId])
            {
                [result addObject:child];
                
            }
            
        }
    }
    return result;
}

-(NSArray *)  getXMLAssociationWithAssociatedItem:(NSString *) associatedItem
{
    NSMutableArray * result = [NSMutableArray array];
    for (DDXMLElement * child in self.doc.rootElement.children)
    {
        if ([child.name isEqualToString:ASSOCIATION_NAME])
        {
            DDXMLNode * childIdNode = [child attributeForName:ASSOCIATED_ITEM];
            if (childIdNode != nil &&
                [childIdNode.stringValue isEqualToString:associatedItem])
            {
                [result addObject:child];
                
            }
        }
    }
    return result;
    
}

-(NSArray *) getXMLAssociationNamespaceElementsForAssociationWithId:(NSString *) associationId
{
    NSMutableArray * result = [NSMutableArray array];
    for (DDXMLElement * child in self.doc.rootElement.children)
    {
        if ([child.name isEqualToString:ASSOCIATION_NAME])
        {
            DDXMLNode * childIDNode = [child attributeForName:ID_ATTRIBUTE];
            if (childIDNode != nil &&
                [childIDNode.stringValue isEqualToString:associationId])
            {
                if (child.children != nil)
                {
                    [result addObjectsFromArray:child.children];
                    return result;
                }
            }
        }
    }
    return result;
}

-(NSArray *) getXMLASsociationNamespaceElementsForAssociationWithId:(NSString *) associationId
                                                   andNamespaceName:(NSString *) namespaceName
{
    NSMutableArray * result = [NSMutableArray array];
    for (DDXMLElement * child in self.doc.rootElement.children)
    {
        if ([child.name isEqualToString:ASSOCIATION_NAME])
        {
            DDXMLNode * childIDNode = [child attributeForName:ID_ATTRIBUTE];
            if (childIDNode != nil &&
                [childIDNode.stringValue isEqualToString:associationId])
            {
                for (DDXMLElement * childSubElement in child.children)
                {
                    NSArray * namespaces = [child namespaces];
                    if (namespaces == nil || [namespaces count] == 0) continue;
                    
                    DDXMLNode * namespaceNode = namespaces[0];
                    if (namespaceNode != nil &&
                        [namespaceNode.stringValue isEqualToString:namespaceName])
                    {
                        [result addObject:childSubElement];
                    }
                }
                
                return result;
            }
        }
    }
    return result;
}
@end
