//
//  CollectionRecorder.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectionRecorder : NSObject

-(void) recordDeleteAssociation:(NSString *) associationId;
-(void) recordUpdateAssociation:(NSString *) associationId;

-(void) recordDeleteFragmentNamespaceSubElement: (NSString *) namespaceElementId;
-(void) recordUpdateFragmentNamespaceSubElement: (NSString *) namespaceElementId;

-(void) recordDeleteFragmentNamespaceElement: (NSString *) fragmentSubElementId;
-(void) recordUpdateFragmentNamespaceElement: (NSString *) fragmentSubElementId;

-(void) recordUpdateFragmentSubElementsChild:(NSString *) subElementChildId;
-(void) recordDeleteFragmentSubElementsChild:(NSString *) subElementChildId;

-(NSSet *) getDeletedAssociations;
-(NSSet *) getDeletedFragmentNamespaceElements;
-(NSSet *) getDeletedFragmentNamespaceSubElements;
-(NSSet *) getDeletedFragmentSubElementChildren;
-(NSSet *) getUpdatedAssociation;
-(NSSet *) getUpdatedFragmentNamespaceElements;
-(NSSet *) getUpdatedFragmentNamespaceSubElements;
-(NSSet *) getUpdatedFragmentSubElementChildren;

-(BOOL) hasFragmentNamespaceElementBeenTouched:(NSString *) fragmentNamespaceId;
-(BOOL) hasFragmentNamespaceSubElementBeenTouched:(NSString *) subElementId;
-(BOOL) hasFragmentSubElementChildBeenTouched:(NSString *) childId;
-(BOOL) hasAssociationBeenTouched:(NSString *) subCollectionId;
-(BOOL) hasAnythingBeenTouched;
-(void) reset;
@end
