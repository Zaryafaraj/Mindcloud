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
#import "CollectionStackingAttribute.h"

/*! A higher level representation of the manifest of a collection.
 manifest of a collection describes the collections and its notes
 */

@protocol XoomlProtocol <NSObject>

#pragma mark - initiation
-(id) initWithXMLString:(NSString *) xmlString;

-(id) initAsEmpty;

-(id) initWithDocument:(DDXMLDocument *) document;

-(id) copy;




#pragma mark - conversion
-(NSString *) toXmlString;

-(NSData *) data;

-(NSString *) description;

-(DDXMLDocument *) document;






#pragma mark - Fragment NamespaceData
// =============================== Fragment Namespace Data

-(void) addFragmentNamespaceElement:(XoomlFragmentNamespaceElement *) namespaceElement;

-(void) removeFragmentNamespaceElement:(NSString *) namespaceId;


/*! If the item is there it will update it, if its not it will create a new one
 */
-(void) setFragmentNamespaceElementWithId:(NSString *) namespaceElementId
                               withElement:(XoomlFragmentNamespaceElement *) newNamespaceElement;

/*! Keyed on fragmentId and valued on XoomlFragmentNamespaceElement objects
 */
-(NSDictionary *) getAllFragmentNamespaceElements;

-(XoomlFragmentNamespaceElement *) getFragmentNamespaceElementWithId:(NSString *) namespaceId;


-(XoomlFragmentNamespaceElement *) getFragmentNamespaceElementWithNamespaceURL:(NSString *) namespaceName
                   thatContainsNamespaceSubElementWithId:(NSString *) namespaceSubElementId;




#pragma mark - Fragment NamespaceData SubElement
//============================Fragment Namespace Data SubElement

/*! If the namespaceURL doesn't have namespace fragment it will get created
 */
-(void) addFragmentNamespaceSubElement:(XoomlNamespaceElement *) subElement;

-(void) removeFragmentNamespaceSubElementWithName:(NSString *) subElementName
                                  forNamespaceURL:(NSString *) namespaceURL;

/*! If the item is there it will update it, if its not it will create a new one
    If namespaceURL doesn't have namespace fragment. It will get created
 */
-(void) setFragmentNamespaceSubElementWithElement:(XoomlNamespaceElement *) newNamespaceSubElement;


//All the subelements of fragmentNamespaceData that have a specified name
-(NSArray *) getFragmentNamespaceSubElementsWithName:(NSString *) namespaceDataName
                                     forNamespaceURL:(NSString *) namespaceURL;

-(NSArray *) getAllFragmentNamespaceSubElementsForNamespaceURL:(NSString *) namespaceURL;

-(XoomlNamespaceElement *) getFragmentNamespaceSubElementWithId: (NSString *) subElementId
                                                        andName:(NSString *) namespaceDataName
                                               fromNamespaceURL:(NSString *) namespaceURL;






#pragma mark - Association
//============================ Association

-(void) addAssociation:(XoomlAssociation *) association;

-(void) removeAssociation:(NSString *) associationId;

/*! If the item is there it will update it, if its not it will create a new one
 */
-(void) setAssociationWithId:(NSString *) associationId
             withNewAssociation:(XoomlAssociation *) element;

/*! Keyed on associationId and valued on Xooml
 */
-(NSDictionary *) getAllAssociations;

-(XoomlAssociation *) getAssociationWithId:(NSString *) associationId;





#pragma mark - Association NamespaceData
//==================================  Association Namespace Data

-(void) addAssociationNamespaceElement:(XoomlAssociationNamespaceElement *) namespaceElement
                   toAssociationWithId:(NSString *) associationId;

-(void) removeAssociationNamespaceElementWithAssociationId:(NSString *) associationId
                          andAssociationNamespaceElementId:(NSString *) namespaceId;


/*! If the item is there it will update it, if its not it will create a new one
 */
-(void) setAssociationNamespaceElementWithAssociationId:(NSString *) associationId
                                     andNamespaceElementId:(NSString *) namespaceElementId
                                            withNewElement:(XoomlAssociationNamespaceElement *) newNamespaceElement;


/*! Keyed on associationNamespace element and valued on XoomlAssociationNamespaceelement
 */
-(NSDictionary *) getAssocationNamespaceElementsForAssocation:(NSString *) associationId;


-(XoomlAssociationNamespaceElement *) getAssocationNamespaceElementWithId:(NSString *) assocationNamespaceId
                                                           forAssociation:(NSString *) associationId;

@end

