//
//  XoomlAssociation.h
//  Mindcloud
//
//  Created by Ali Fathalian on 8/26/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlAssociationNamespaceData.h"

@interface XoomlAssociation : NSObject

@property (strong, nonatomic, readonly) NSString * id;

@property (strong, nonatomic) NSString * associatedItem;

@property (strong, nonatomic) NSString * displayText;

@property (strong, nonatomic) NSString * localItem;

@property (strong, nonatomic) NSString * associatedXooMLFragment;

@property (strong, nonatomic, readonly) NSString * associatedXoomlDriver;


-(id) initWithXMLString:(NSString *) xmlString;

-(NSString *) toXMLString;

/*! Keyed on the AssociationNamespaceDataId and valued on XoomlAssociationNamespaceData obj
    Immutable.
*/
-(NSDictionary *) getAllAssociationNamespaceData;

/*! Keyed on the id of the XoomlAssociationNamespaceData and valued on the 
    XoomlAssociationNamespaceData
 */
-(NSDictionary *) addAssociationNameSpaceData:(XoomlAssociationNamespaceData *) data;

-(void) removeAssociationNameSpaceDataWithId:(NSString *) ID;

@end
