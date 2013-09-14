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
#import "XoomlAttributeDefinitions.h"

#define ASSOCIATION_NAMESPACE_ID @"ID"
#define NAMESPACE_NAME @"xmlns"

@interface XoomlAssociationNamespaceElement()

@property (strong, nonatomic) DDXMLElement * element;

@property (strong, nonatomic) NSString * ID;

@property (strong, nonatomic) NSString * namespaceOwner;

@end
@implementation XoomlAssociationNamespaceElement

-(id) initWithNamespaceOwner:(NSString *)namespaceOwner
{
    self = [super init];
    if (self)
    {
        self.ID = [AttributeHelper generateUUID];
        self.namespaceOwner = namespaceOwner;
        self.element = [DDXMLElement elementWithName:ASSOCIATON_NAMESPACE_NAME];
        DDXMLNode * idNode = [DDXMLNode attributeWithName:ASSOCIATION_NAMESPACE_ID
                                              stringValue:self.ID];
        [self.element addAttribute:idNode];
        DDXMLNode * namespaceNode = [DDXMLNode attributeWithName:NAMESPACE_NAME
                                                     stringValue:namespaceOwner];
        [self.element addAttribute:namespaceNode];
    }
    return self;
}

-(id) initFromXMLString:(NSString *) xmlString
{
    self = [super init];
    
    if (self == nil) return nil;
    
    NSError * err = nil;
    self.element = [[DDXMLElement alloc] initWithXMLString:xmlString error:&err];
    if (self.element == nil)
    {
        NSLog(@"XoomlAssociationNamespaceElement - Error creating XoomlAssociationNamespaceElement with Error %@", err.description);
        return nil;
    }
    
    
    DDXMLNode * idAttribute = [self.element attributeForName:ASSOCIATION_NAMESPACE_ID];
    if (idAttribute)
    {
        self.ID = idAttribute.stringValue;
    }
    //if we don't have an id generate it
    else
    {
        self.ID = [AttributeHelper generateUUID];
        idAttribute = [DDXMLNode attributeWithName:ASSOCIATION_NAMESPACE_ID
                                       stringValue:_ID];
        [self.element addAttribute:idAttribute];
    }
   
    NSArray * namespaces = [self.element namespaces];
    if (namespaces == nil || [namespaces count] == 0) return self;
        
    DDXMLNode * namespaceName = namespaces[0];

    if (namespaceName)
    {
        self.namespaceOwner = namespaceName.stringValue;
    }
    
    return self;;
}

-(NSString *) toXMLString
{
    if (self.element)
    {
        return [self.element XMLString];
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
    DDXMLElement * subElementObj = [[DDXMLElement alloc] initWithXMLString:subElementString error:&err];
    if (err)
    {
        NSLog(@"XoomlAssociationNamespaceElement - error parsing xml %@", err);
        return;
    }
    [self.element addChild:subElementObj];
}

-(void) removeSubElement:(NSString *) subElementId
{
    NSUInteger removeIndex ;
    BOOL found = NO;
    for (DDXMLElement * element in self.element.children)
    {
        if ([[[element attributeForName:ASSOCIATION_NAMESPACE_ID] stringValue] isEqualToString:subElementId])
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
