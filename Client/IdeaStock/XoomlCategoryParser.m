//
//  XoomlCategoryParser.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/8/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "XoomlCategoryParser.h"
#import "DDXML.h"
#import "XoomlAttributeHelper.h"

@implementation XoomlCategoryParser

#define XSI_NAMESPACE @"http://www.w3.org/2001/XMLSchema-instance"
#define XOOML_NAMESPACE @"http://kftf.ischool.washington.edu/xmlns/xooml"
//TODO change this to point to the real schema location
#define XOOML_SCHEMA_LOCATION @"http://kftf.ischool.washington.edu/xmlns/xooml http://kftf.ischool.washington.edu/XMLschema/0.41/XooML.xsd"
#define MINDCLOUD_NAMESPACE  @"http://www.mindcloud.net/xmlns/mindcloud"
#define MINDCLOUD_SCHEMA_LOCATION @"http://www.mindcloud.net/xmlschema/mindcloud.xsd"

#define XOOML_FRAGMENT @"xooml:fragment"
#define SCHEMA_VERSION @"schemaVersion"
#define ITEM_DESCRIBED @"itemDescribed"
#define ASSOCIATED_FRAGMENT @"associatedXooMLFragment"
#define XOOML_ASSOCIATION @"xooml:association"
#define XML_HEADER @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"

+(NSData *) serializeToXooml:(id<CategoryModelProtocol>) model
{
    DDXMLElement * root = [[DDXMLElement alloc] initWithName: XOOML_FRAGMENT];
    
    [root addNamespace: [DDXMLNode namespaceWithName:@"xsi" stringValue: XSI_NAMESPACE]];
    [root addNamespace: [DDXMLNode namespaceWithName:@"xooml" stringValue: XOOML_NAMESPACE]];
    [root addNamespace: [DDXMLNode namespaceWithName:@"mindcloud" stringValue: MINDCLOUD_NAMESPACE]];
    [root addAttribute: [DDXMLNode attributeWithName:@"xooml:schemaLocation" stringValue: XOOML_SCHEMA_LOCATION]];
    [root addAttribute: [DDXMLNode attributeWithName:@"mindcloud:schemaLocation" stringValue: MINDCLOUD_SCHEMA_LOCATION]];
    
    NSArray * categories = [model getAllSerializableCategories];
    for (NSString * categoryName in categories)
    {
        DDXMLElement * category = [[DDXMLElement alloc] initWithName:XOOML_FRAGMENT];
        [category addAttribute:[DDXMLNode attributeWithName:SCHEMA_VERSION
                                       stringValue:@"2"]];
        [category addAttribute:[DDXMLNode attributeWithName:ITEM_DESCRIBED
                                                stringValue:categoryName]];
        for(NSString * collectionName in [model getSerializableCollectionsForCategory:categoryName])
        {
            DDXMLElement * collection = [[DDXMLElement alloc] initWithName:XOOML_ASSOCIATION];
            [collection addAttribute:[DDXMLNode attributeWithName:@"ID"
                                                       stringValue:[XoomlAttributeHelper generateUUID]]];
            [collection addAttribute:[DDXMLNode attributeWithName:ASSOCIATED_FRAGMENT stringValue:collectionName]];
            
            [category addChild:collection];
        }
        [root addChild:category];
    }
    
    //create the standard xml header
    NSString *xmlString = [root description];
    NSString *xmlHeader = XML_HEADER;
    xmlString = [xmlHeader stringByAppendingString:xmlString];
    
    return [xmlString dataUsingEncoding:NSUTF8StringEncoding];
}


+(NSDictionary *) deserializeXooml: (NSData *) data
{
    //open the XML document
    NSError *err = nil;
    DDXMLDocument * document = [[DDXMLDocument alloc] initWithData:data options:0 error:&err];
    
    //TODO right now im ignoring err. I should use it 
    //to determine the error
    if (document == nil){
        NSLog(@"Error reading the note XML File");
        return nil;
    }
    
    NSString * categoryXpath = @"/xooml:fragment/xooml:fragment";
    NSArray * categories = [document nodesForXPath:categoryXpath error:&err];
    NSMutableDictionary * categoriesTemp = [NSMutableDictionary dictionary];
    for(DDXMLElement * node in categories)
    {
        NSString * categoryName = [[node attributeForName:ITEM_DESCRIBED] stringValue];
        NSMutableArray * collections = [NSMutableArray array];
        for (DDXMLElement * child in [node children])
        {
            NSString * collectionName = [[child attributeForName:ASSOCIATED_FRAGMENT] stringValue];
            [collections addObject:collectionName];
        }
        categoriesTemp[categoryName] = [collections copy];
    }
    return [categoriesTemp copy];
}
@end
