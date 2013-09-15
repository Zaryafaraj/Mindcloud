//
//  XoomlFragmentNamespaceElement.m
//  Mindcloud
//
//  Created by Ali Fathalian on 8/26/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "XoomlFragmentNamespaceElement.h"
#import "AttributeHelper.h"
#import "XoomlAttributeDefinitions.h"


@interface XoomlFragmentNamespaceElement()

@property (strong, nonatomic) NSString * namespaceName;

@property (strong, nonatomic) DDXMLElement * element;

@end

@implementation XoomlFragmentNamespaceElement

-(void) setID:(NSString *)ID
{
    _ID = ID;
    if (self.element)
    {
        DDXMLNode * newId = [DDXMLNode attributeWithName:ID_ATTRIBUTE
                                             stringValue:_ID];
        [self.element removeAttributeForName:ID_ATTRIBUTE];
        [self.element addAttribute:newId];
    }
}

-(id) initWithNamespaceName:(NSString *)namespaceName
{
    self = [super init];
    if (self)
    {
        self.ID = [AttributeHelper generateUUID];
        self.namespaceName = namespaceName;
        self.element = [DDXMLElement elementWithName:ASSOCIATON_NAMESPACE_DATA_NAME];
        
        DDXMLNode * idNode = [DDXMLNode attributeWithName:ID_ATTRIBUTE
                                              stringValue:self.ID];
        [self.element addAttribute:idNode];
        
        DDXMLNode * namespaceNode = [DDXMLNode attributeWithName:XMLNS_NAME
                                                     stringValue:self.namespaceName];
        [self.element addAttribute:namespaceNode];
        
    }
    return self;
}

-(id) initFromXmlString:(NSString *) xmlString
{
    self = [super init];
    
    if (self == nil) return nil;
    
    NSError * err = nil;
    self.element = [[DDXMLElement alloc] initWithXMLString:xmlString error:&err];
    if (self.element == nil)
    {
        NSLog(@"XoomlFragmentNamespaceElement - Error creating XoomlAssociationNamespaceElement with Error %@", err.description);
        return nil;
    }
    
    
    DDXMLNode * idAttribute = [self.element attributeForName:ID_ATTRIBUTE];
    if (idAttribute)
    {
        self.ID = idAttribute.stringValue;
    }
    //if we don't have an id generate it
    else
    {
        self.ID = [AttributeHelper generateUUID];
        idAttribute = [DDXMLNode attributeWithName:ID_ATTRIBUTE
                                       stringValue:_ID];
        [self.element addAttribute:idAttribute];
    }
    
    NSArray * namespaces = [self.element namespaces];
    
    //there is a bug in kiss xml that sometimes picks the namespace and
    //sometimes doesn't. Manully try to get the namespace
    DDXMLNode * namespaceNode = nil;
    if (namespaces == nil || [namespaces count] == 0)
    {
        DDXMLNode * possibleNS = [self.element attributeForName:XMLNS_NAME];
        if (possibleNS != nil)
        {
            namespaceNode = possibleNS;
        }
    }
    else
    {
        namespaceNode = namespaces[0];
    }
    
    
    if (namespaceNode)
    {
        self.namespaceName = namespaceNode.stringValue;
    }
    
    return self;;
}

-(NSString *) toXMLString
{
    if (self.element)
    {
        return self.element.XMLString;
    }
    return nil;
}

/*! Keyed on property. Values are strings of the values for the property
 */
-(NSDictionary *) getXoomlFragmentNamespaceAttributes
{
    NSMutableDictionary * namespaceAttribtues = [NSMutableDictionary dictionary];
    
    if (self.element == nil) return namespaceAttribtues;
    
    for(DDXMLNode * attribute in self.element.attributes)
    {
        NSString * value = attribute.stringValue;
        NSString * name = attribute.name;
        namespaceAttribtues[name] = value;
    }
    return namespaceAttribtues;
}

/*! Keyed on subelement ID valued on XoomlNamespaceElement
 */
-(NSDictionary *) getAllXoomlFragmentsNamespaceSubElements
{
    NSMutableDictionary * namespaceElements = [NSMutableDictionary dictionary];
    
    if (self.element == nil) return namespaceElements;
    
    for (DDXMLNode * element in self.element.children)
    {
        XoomlNamespaceElement * childValue = [[XoomlNamespaceElement alloc] initFromXMLString:element.description];
        if (childValue != nil && childValue.ID != nil)
        {
            NSString * ID = childValue.ID;
            namespaceElements[ID] = childValue;
        }
    }
    return namespaceElements;
}

-(void) addAttributeWithName:(NSString *) attributeName
                    andValue:(NSString *) value
{
    if (self.element == nil) return;
    
    DDXMLNode * attributeNode = [DDXMLNode attributeWithName:attributeName
                                                 stringValue:value];
    [self.element addAttribute:attributeNode];
}

-(void) addSubElement:(XoomlNamespaceElement *) subElement
{
    if (subElement == nil || self.element == nil) return;
    
    NSString * subElementString = [subElement toXMLString];
    NSError * err;
    DDXMLElement * subElementObj =  [[DDXMLElement alloc] initWithXMLString:subElementString error:&err];
    if (err)
    {
        NSLog(@"XoomlFragmentNamespaceElement - error parsing xml string %@", err);
    }
    [self.element addChild:subElementObj];
}

-(void) removeSubElement:(NSString *) subElementId
{
    NSUInteger removeIndex ;
    BOOL found = NO;
    for (DDXMLElement * element in self.element.children)
    {
        if ([[[element attributeForName:ID_ATTRIBUTE] stringValue] isEqualToString:subElementId])
        {
            removeIndex = element.index;
            found = YES;
            break;
        }
    }
    
    if (found) [self.element removeChildAtIndex:removeIndex];
    
}

-(void) removeAttributeWithName:(NSString *) attributeName
{
    if (self.element == nil) return;
    [self.element removeAttributeForName:attributeName];
}

-(NSString *) description
{
    return [self.element description];
}

-(NSString *) debugDescription
{
    return [self.element description];
}
@end
