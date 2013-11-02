//
//  MindcloudGordon.h
//  Mindcloud
//
//  Created by Ali Fathalian on 8/24/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MindcloudCollectionGordonDelegate.h"
#import "SynchronizedObject.h"
#import "XoomlAssociation.h"
#import "XoomlFragment.h"
#import "DiffableSerializableObject.h"

@interface MindcloudCollectionGordon : NSObject <SynchronizedObject>

-(id) initWithCollectionName: (NSString *) collectionName
                 andDelegate:(id<MindcloudCollectionGordonDelegate>) delegate;

-(void) connectToCollection:(NSString *) collectionName;

/*===============================================*/
#pragma mark - Association
/*===============================================*/

-(void) addAssociationWithName:(NSString *) associationName
             andAssociatedItem:(XoomlFragment *) content
                andAssociation:(XoomlAssociation *) association;

-(void) addAssociationWithName: (NSString *) associationName
             andAssociatedItem:(XoomlFragment *)content
                andAssociation:(XoomlAssociation *) association
       andAssociationImageData:(NSData *) img
                  andImageName:(NSString *) imgName;

/*! If the item is there it will update it, if its not it will create a new one
 */
-(void) setAssociatedItemWithName:(NSString *) associationName
                 toAssociatedItem:(XoomlFragment *) content;

/*! If the item is there it will update it, if its not it will create a new one
 */
-(void) setAssociationWithId:(NSString *) associationId
               toAssociation:(XoomlAssociation *) association;

-(void) setAssociationWithRefId:(NSString *) associationRefId
               toAssociation:(XoomlAssociation *) association;

-(void) removeAssociationWithId:(NSString *) associationId
          andAssociatedItemName:(NSString *) associatedItemName;

-(void) removeAssociationWithRefId:(NSString *) refId
             andAssociatedItemName:(NSString *) associatedItemName;

-(NSString *) getImagePathForAssociationWithName:(NSString *) associationName;

/*===============================================*/
#pragma mark - FragmentNamespaceElement
/*===============================================*/

-(void) addCollectionFragmentNamespaceSubElement:(XoomlNamespaceElement *) namespaceElement;


/*!
    Convinience method that creates a namespace attribute with attributeName and
    points to a file with filename which its contents should be from the content obj.
    If fixedId is not nil.
 */
-(void) setCollectionFragmentNamespaceFileWithName:(NSString *) filename
                                  andAttributeName:(NSString *) attributeName
                            andParentNamespaceName:(NSString *) namespaceName andFixedId:(NSString *) fixedId
                                andExternalContent:(id<DiffableSerializableObject>) content;

/*! If the item is there it will update it, if its not it will create a new one
 */
-(void) setCollectionThumbnailWithData:(NSData *) thumbnailData;

/*! If the item is there it will update it, if its not it will create a new one
 */
-(void) setCollectionThumbnailWithImageOfAssociation:(NSString *) associationId;


/*! If the item is there it will update it, if its not it will create a new one
 */
-(void) setCollectionFragmentNamespaceSubElementWithNewElement:(XoomlNamespaceElement *) namespaceElement;

-(void) removeThumbnailForCollection;

-(void) removeCollectionFragmentNamespaceSubElementWithId:(NSString *) subElementId
                                            fromNamespace:(NSString *) parentNamespaceName;



/*===============================================*/
#pragma mark - downloading
/*===============================================*/

-(void) associatedItemIsWaitingForImageForAssociationWithId:(NSString *) subCollectionId
                                         andAssociationName:(NSString *) subCollectionName;

/*! Call this before you finish working with Gordon
 */
-(void) cleanup;

@end
