//
//  XoomlFragment.h
//  Mindcloud
//
//  Created by Ali Fathalian on 8/26/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlAssociation.h"
#import "XoomlFragmentNamespaceData.h"
@interface XoomlFragment : NSObject

//Gordon
@property (strong, nonatomic) NSString * xoomlDriver;
//Joker
@property (strong, nonatomic, readonly) NSString * syncDriver;
//Bane
@property (strong, nonatomic, readonly) NSString * itemDriver;

@property (strong, nonatomic, readonly) NSString * lastWriteGUID;

//relative path to the item described
@property (strong, nonatomic) NSString * itemDescribed;

/*! Keyed on associationId and value is XoomlAssociation object
 */
-(NSDictionary *) getAllAssociations;

-(XoomlAssociation *) getAssociationWithId:(NSString *) associationId;

-(void) removeAssociationWithId:(NSString *) associationId;

/*! Keyed on fragmentNamespaceData Id and valued on XoomlFragmentNameSpaceData
 */
-(NSDictionary *) getAllFragmentNamespaceData;

-(XoomlFragmentNamespaceData *) getFragmentNamespaceDataWithId:(NSString *) namespaceDataId;

-(void) removeFragmentNamespaceDataWithId:(NSString *) namespaceData;
@end
