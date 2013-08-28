//
//  XoomlAssociationNamespaceElement.m
//  Mindcloud
//
//  Created by Ali Fathalian on 8/26/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "XoomlAssociationNamespaceElement.h"
#import "DDXMLDocument.h"
#import "AttributeHelper.h"

#define ID_KEY @"ID"

@interface XoomlAssociationNamespaceElement()

@property (strong, nonatomic) DDXMLElement * element;

@end
@implementation XoomlAssociationNamespaceElement

-(void) setNamespaceName:(NSString *)namespaceName
{
    self.namespaceName = namespaceName;
    self.element = [DDXMLElement elementWithName:namespaceName];
}

-(void) setID:(NSString *)ID
{
    self.ID = ID;
    
    if (self.element == nil) return;
    
    [self.element removeAttributeForName:ID_KEY];
    DDXMLNode * newId = [DDXMLNode attributeWithName:ID_KEY stringValue:ID];
    [self.element addAttribute:newId];
}

-(id) initWithName:(NSString *) name
{
    self = [super init];
    if (self)
    {
        self.ID = [AttributeHelper generateUUID];
        self.namespaceName = name;
        self.element = [[DDXMLElement alloc] init];
        self.element = [DDXMLElement elementWithName:name];
    }
    return self;
}

-(id) initFromXmlString:(NSString *) xmlString
{
    NSError * err = nil;
    DDXMLElement * element = [[DDXMLElement alloc] initWithXMLString:xmlString error:&err];
    if (element == nil)
    {
        NSLog(@"XoomlAssociationNamespaceElement - Error creating XoomlAssociationNamespaceElement with Error %@", err.description);
        return nil;
    }
    return nil;
}

-(NSString *) toXMLString
{
    if (self.element)
    {
        return [self.element stringValue];
    }
    return nil;
}

/*! Keyed on property. Values are strings of the values for the property
 */
-(NSDictionary *) getXoomlAssociationNamespaceAttributes
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
-(NSDictionary *) getAllXoomlAssociationNamespaceSubElements
{
    NSMutableDictionary * namespaceElements = [NSMutableDictionary dictionary];
    
    if (self.element == nil) return namespaceElements;
    
    for (DDXMLNode * element in self.element.children)
    {
        XoomlAssociationNamespaceElement * childValue = [[XoomlAssociationNamespaceElement alloc] initFromXmlString:element.stringValue];
        if (childValue != nil)
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


-(void) addSubElement:(XoomlAssociationNamespaceElement *) subElement
{
    if (subElement == nil || self.element == nil) return;
    
    [self.element addChild:subElement.element];
}

-(void) removeSubElement:(NSString *) subElementId
{
    NSUInteger removeIndex ;
    for (DDXMLElement * element in self.element.children)
    {
        if ([[[element attributeForName:ID_KEY] stringValue] isEqualToString:subElementId])
        {
            removeIndex = element.index;
        }
    }
    
    [self.element removeChildAtIndex:removeIndex];
}

-(void) removeAttributeWithName:(NSString *) attributeName
{
    if (self.element == nil) return;
    [self.element removeAttributeForName:attributeName];
}

-(NSString *) description
{
    return [self.element stringValue];
}

-(NSString *) debugDescription
{
    return [self.element stringValue];
}
@end
