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

@property (strong, nonatomic) NSString * ID;

@property (strong, nonatomic) NSString * associatedItem;

@property (strong, nonatomic) NSString * displayText;

@property (strong, nonatomic) NSString * localItem;

@property (strong, nonatomic) NSString * associatedXooMLFragment;

@property (strong, nonatomic, readonly) NSString * associatedXoomlDriver;


@property (strong, nonatomic, readonly) NSString * refId;

@property (strong, nonatomic, readonly) DDXMLElement * element;

-(id) initSelfReferencingAssociationWithDisplayText:(NSString *) displayText
                                          andSelfId:(NSString *) ID;

-(id) initWithAssociatedItem:(NSString *) associatedItem
         andAssociatedItemRefId:(NSString *) refId;

-(id) initWithXMLString:(NSString *) xmlString;

-(NSString *) toXMLString;

/*! Keyed on the AssociationNamespaceElementId and valued on XoomlAssociationNamespaceElement obj
    Immutable.
*/
-(NSDictionary *) getAllAssociationNamespaceElement;

/*! Keyed on the id of the XoomlAssociationNamespaceElement and valued on the 
    XoomlAssociationNamespaceElement
 */
-(void) addAssociationNamespaceElement:(XoomlAssociationNamespaceElement *) data;

-(XoomlAssociationNamespaceElement *) getAssociationNamespaceElementWithId:(NSString *) namespaceId;

-(void) removeAssociationNamespaceElementWithId:(NSString *) ID;

/*! Determines whether this association refers to self fragment as opposed to a fragment outside
 */
-(BOOL) isSelfReferncing;
@end
