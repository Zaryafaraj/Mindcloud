//
//  XoomlAssociationNamespaceElement.h
//  Mindcloud
//
//  Created by Ali Fathalian on 8/26/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlNamespaceElement.h"
#import "DDXMLElement.h"

@interface XoomlAssociationNamespaceElement : NSObject

@property (strong, nonatomic) NSString * ID;
@property (strong, nonatomic) NSString * namespaceName;

-(id) initWithName:(NSString *) name;

-(id) initFromXmlString:(NSString *) xmlString;

-(NSString *) toXMLString ;

/*! Keyed on property. Values are strings of the values for the property
 */
-(NSDictionary *) getXoomlAssociationNamespaceAttributes;

/*! Keyed on subelement ID valued on XoomlNamespaceElement
 */
-(NSDictionary *) getAllXoomlAssociationNamespaceSubElements;

-(void) addAttributeWithName:(NSString *) attributeName
                    andValue:(NSString *) value;
-(void) addSubElement:(XoomlAssociationNamespaceElement *) subElement;

-(void) removeSubElement:(NSString *) subElementId;

-(void) removeAttributeWithName:(NSString *) attributeName;

-(NSString *) description;

@end
