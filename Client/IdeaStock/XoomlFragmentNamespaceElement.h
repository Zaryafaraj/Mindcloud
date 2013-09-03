//
//  XoomlFragmentNamespaceElement.h
//  Mindcloud
//
//  Created by Ali Fathalian on 8/26/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlNamespaceElement.h"
#import "DDXMLElement.h"

@interface XoomlFragmentNamespaceElement : NSObject

@property (strong, nonatomic)  NSString * ID;

@property (strong, nonatomic, readonly) NSString * namespaceURL;

@property (strong, nonatomic, readonly) DDXMLElement * element;

-(id) initWithNamespaceURL :(NSString *) namespaceURL;

-(id) initFromXmlString:(NSString *) xmlString;

-(NSString *) toXMLString ;

/*! Keyed on property. Values are strings of the values for the property
 */
-(NSDictionary *) getXoomlFragmentNamespaceAttributes;

/*! Keyed on subelement ID valued on XoomlNamespaceElement
 */
-(NSDictionary *) getAllXoomlFragmentsNamespaceSubElements;

-(void) addAttributeWithName:(NSString *) attributeName
                    andValue:(NSString *) value;

-(void) addSubElement:(XoomlNamespaceElement *) subElement;

-(void) removeSubElement:(NSString *) subElementId;

-(void) removeAttributeWithName:(NSString *) attributeName;

@end
