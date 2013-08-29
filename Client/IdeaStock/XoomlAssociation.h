//
//  XoomlAssociation.h
//  Mindcloud
//
//  Created by Ali Fathalian on 8/26/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlAssociationNamespaceElement.h"

@interface XoomlAssociation : NSObject

@property (strong, nonatomic, readonly) NSString * ID;

@property (strong, nonatomic) NSString * associatedItem;

@property (strong, nonatomic) NSString * displayText;

@property (strong, nonatomic) NSString * localItem;

@property (strong, nonatomic) NSString * associatedXooMLFragment;

@property (strong, nonatomic, readonly) NSString * associatedXoomlDriver;


-(id) initWithXMLString:(NSString *) xmlString;

-(NSString *) toXMLString;

/*! Keyed on the AssociationNamespaceElementId and valued on XoomlAssociationNamespaceElement obj
    Immutable.
*/
-(NSDictionary *) getAllAssociationNamespaceElement;

/*! Keyed on the id of the XoomlAssociationNamespaceElement and valued on the 
    XoomlAssociationNamespaceElement
 */
-(NSDictionary *) addAssociationNamespaceElement:(XoomlAssociationNamespaceElement *) data;

-(void) removeAssociationNamespaceElementWithId:(NSString *) ID;

@end
