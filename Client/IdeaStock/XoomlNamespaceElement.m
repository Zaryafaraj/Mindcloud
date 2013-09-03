//
//  NamespaceElement.m
//  Mindcloud
//
//  Created by Ali Fathalian on 8/26/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "XoomlNamespaceElement.h"
#import "AttributeHelper.h"

#define NAMESPACE_ID @"ID"

@interface XoomlNamespaceElement()

@property (strong, nonatomic) DDXMLElement * element;
@end

@implementation XoomlNamespaceElement

-(void) setID:(NSString *)ID
{
    _ID = ID;
    if (self.element)
    {
        DDXMLNode * newId = [DDXMLNode attributeWithName:NAMESPACE_ID
                                                 stringValue:_ID];
        [self.element removeAttributeForName:NAMESPACE_ID];
        [self.element addAttribute:newId];
    }
}

-(id) initWithNoImmediateFragmentNamespaceParentAndName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        _name = name;
        _ID = [AttributeHelper generateUUID];
        self.element = [DDXMLElement elementWithName:name];
        DDXMLNode * elementId = [DDXMLNode attributeWithName:NAMESPACE_ID
                                                 stringValue:_ID];
        [self.element addAttribute:elementId];
    }
    return self;
    
}

-(id) initWithName:(NSString *)name
andParentNamespace:(NSString *) parentNamespace
{
    self = [super init];
    if (self)
    {
        _name = name;
        _ID = [AttributeHelper generateUUID];
        _parentNamespace = parentNamespace;
        self.element = [DDXMLElement elementWithName:name];
        DDXMLNode * elementId = [DDXMLNode attributeWithName:NAMESPACE_ID
                                                 stringValue:_ID];
        [self.element addAttribute:elementId];
    }
    return self;
}

-(id) initFromXMLString:(NSString *) xmlString
{
    self = [super init];
    if (self)
    {
        NSError * err = nil;
        self.element = [[DDXMLElement alloc] initWithXMLString:xmlString error:&err];
        if (self.element == nil)
        {
            NSLog(@"NamespaceElement - Error creating NamespaceElement with Error %@", err.description);
            return nil;
        }
        
        DDXMLNode * idAttribute = [self.element attributeForName:NAMESPACE_ID];
        if (idAttribute)
        {
            _ID = idAttribute.stringValue;
        }
        //if we don't have an id generate it
        else
        {
            _ID = [AttributeHelper generateUUID];
            idAttribute = [DDXMLNode attributeWithName:NAMESPACE_ID
                                           stringValue:_ID];
            [self.element addAttribute:idAttribute];
        }
        _name = self.element.name;
    }
    return self;
}

-(NSString *) toXMLString
{
    if (self.element)
    {
        return [self.element stringValue];
    }
    return nil;
}

-(NSDictionary *) getAllAttributes
{
    NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
    
    if (self.element == nil) return attributes;
    
    for(DDXMLNode * attribute in self.element.attributes)
    {
        attributes[attribute.name] = attribute.stringValue;
    }
    
    return attributes;
}

-(NSDictionary *) getAllSubElements
{
    NSMutableDictionary * subelements = [NSMutableDictionary dictionary];
    
    if(self.element == nil) return subelements;
    
    for(DDXMLNode * subElement in self.element.children)
    {
        XoomlNamespaceElement * elem = [[XoomlNamespaceElement alloc] initFromXMLString:subElement.XMLString];
        NSString * elemId = elem.ID;
        if (elemId)
        {
            subelements[elemId] = elem;
        }
    }
    
    return subelements;
}

-(void) addSubElement:(XoomlNamespaceElement *) subElement
{
    if (self.element == nil || subElement == nil || subElement.element == nil) return;
    
    [self.element addChild:subElement.element];
}

-(void) addAttributeWithName:(NSString *) name
                    andValue:(NSString *) value
{
    if (self.element == nil) return;
    
    DDXMLNode * attributeNode = [DDXMLNode attributeWithName:name
                                                 stringValue:value];
    [self.element addAttribute:attributeNode];
}

-(void) removeSubElement:(NSString *) subElementId
{
    NSUInteger index;
    BOOL found = NO;
    if (self.element == nil) return;
    
    for (DDXMLElement * elem in self.element.children)
    {
        NSString * elemId = [elem attributeForName:NAMESPACE_ID].stringValue;
        if (elemId && [elemId isEqualToString:subElementId])
        {
            index = elem.index;
            found = YES;
            break;
        }
    }
    
    if (found) [self.element removeChildAtIndex:index];
}

-(void) removeAttributeNamed:(NSString *) attributeName
{
    if (self.element == nil) return;
    
    if ([self.element attributeForName:attributeName])
    {
        [self.element removeAttributeForName:attributeName];
    }
}

-(XoomlNamespaceElement *) getSubElementWithId:(NSString *) subElementId
{
    if (self.element == nil) return nil;
    
    for (DDXMLElement * elem in self.element.children)
    {
        NSString * elemId = [elem attributeForName:NAMESPACE_ID].stringValue;
        if (elemId && [elemId isEqualToString:subElementId])
        {
            return [[XoomlNamespaceElement alloc] initFromXMLString:elem.stringValue];
        }
    }
    
    return nil;
}

-(NSString *) getAttributeWithName:(NSString *) attributeName
{
    if (self.element == nil) return nil;
    
    return [self.element attributeForName:attributeName].stringValue;
}

-(BOOL) isImmediateChildOfFragmentNamespace
{
    return self.parentNamespace != nil;
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
