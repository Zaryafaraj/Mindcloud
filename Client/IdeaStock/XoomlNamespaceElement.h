//
//  NamespaceElement.h
//  Mindcloud
//
//  Created by Ali Fathalian on 8/26/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XoomlNamespaceElement : NSObject

@property (strong, nonatomic) NSString * ID;

@property (strong, nonatomic) NSString * namespaceName;

-(id) initWithName:(NSString *) name;

-(id) initFromXMLString:(NSString *) xmlString;

/*! keyed on attribute name valued on attribtue value string
    returns immutable objects
 */
-(NSDictionary *) getAllAttributes;

/*! all the subElements keyed on elementId and valued on NamespaceElement Object
   returns immutable objects
 */
-(NSDictionary *) getAllSubElements;

-(NSString *) toXMLString;

-(void) addSubElement:(XoomlNamespaceElement *) subElement;

-(void) addAttributeWithName:(NSString *) name
                    andValue:(NSString *) value;

-(void) removeSubElement:(NSString *) subElementId;

-(void) removeAttributeNamed:(NSString *) attributeName;

-(XoomlNamespaceElement *) getSubElementWithId:(NSString *) subElementId;

-(NSString *) getAttributeWithName:(NSString *) attributeName;


@end
