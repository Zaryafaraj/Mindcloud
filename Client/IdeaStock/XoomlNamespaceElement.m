//
//  NamespaceElement.m
//  Mindcloud
//
//  Created by Ali Fathalian on 8/26/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "XoomlNamespaceElement.h"

@interface XoomlNamespaceElement()

@property (strong, nonatomic) NSMutableDictionary * subElements;

@property (strong, nonatomic) NSMutableDictionary * attributes;

@end

@implementation XoomlNamespaceElement


-(id) init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

-(id) initFromXMLString:(NSString *) xmlString
{
    self = [self init];
    return self;
}

-(NSString *) toXMLString
{
    return @"";
}

-(NSDictionary *) getAllAttributes
{
    return self.attributes;
}
-(NSDictionary *) getAllSubElements
{
    return self.subElements;
}

-(void) addSubElement:(XoomlNamespaceElement *) subElement
{
    
}

-(void) addAttributeWithName:(NSString *) name
                    andValue:(NSString *) value
{
    
}

-(void) removeSubElement:(NSString *) subElementId
{
    
}

-(void) removeAttributeNamed:(NSString *) attributeName
{
    
}

-(XoomlNamespaceElement *) getSubElementWithId:(NSString *) subElementId
{
    
}

-(NSString *) getAttributeWithName:(NSString *) attributeName
{
    
}
@end
