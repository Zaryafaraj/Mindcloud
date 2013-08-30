//  BulletinBoardDelegate.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/1/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlFragmentNamespaceElement.h"
#import "XoomlAssociation.h"
#import "XoomlAssociationNamespaceElement.h"
#import "CollectionNoteAttribute.h"
#import "StackingModel.h"

/*
 A higher level representation of the manifest of a collection.
 manifest of a collection describes the collections and its notes
 */

@protocol XoomlProtocol <NSObject>

-(id) initWithXMLString:(NSString *) xmlString;

-(id) initAsEmpty;

-(id) initWithDocument:(DDXMLDocument *) document;

-(id) copy;

-(NSString *) toXmlString;

-(NSData *) data;

-(void) addAssociation:(XoomlAssociation *) association;

-(void) addAssociationNamespaceElement:(XoomlAssociationNamespaceElement *) namespaceElement
                toAssociationWithId:(NSString *) associationId;


-(void) removeFragmentNamespaceElement:(NSString *) namespaceId;

-(void) removeAssociation:(NSString *) associationId;

-(void) removeAssociationNamespaceElementWithAssociationId:(NSString *) associationId
                          andAssociationNamespaceElementId:(NSString *) namespaceId;

-(void) updateFragmentNamespaceElementWith:(NSString *) namespaceElementId
                               withElement:(XoomlFragmentNamespaceElement *) newNamespaceElement;

-(void) updateAssociationWithId:(NSString *) associationId
             withNewAssociation:(XoomlAssociationNamespaceElement *) element;

-(void) updateAssociationNamespaceElementWithAssociationId:(NSString *) associationId
                                     andNamespaceElementId:(NSString *) namespaceElementId
                                            withNewElement:(XoomlAssociationNamespaceElement *) newNamespaceElement;

/*! Keyed on fragmentId and valued on XoomlFragmentNamespaceElement objects
 */
-(NSDictionary *) getAllFragmentNamespaceElements;

-(XoomlFragmentNamespaceElement *) getFragmentNamespaceElementWithId:(NSString *) namespaceId;

/*! Keyed on associationId and valued on Xooml
 */
-(NSDictionary *) getAllAssociations;

-(XoomlAssociation *) getAssociationWithId:(NSString *) associationId;

/*! Keyed on associationNamespace element and valued on XoomlAssociationNamespaceelement
 */
-(NSDictionary *) getAssocationNamespaceElementsForAssocation:(NSString *) associationId;


-(XoomlAssociationNamespaceElement *) getAssocationNamespaceElementWithId:(NSString *) assocationNamespaceId
                                                           forAssociation:(NSString *) associationId;

-(NSString *) description;

-(DDXMLDocument *) document;
@end

