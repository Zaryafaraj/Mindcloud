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

@interface MindcloudCollectionGordon : NSObject <SynchronizedObject>

-(id) initWithCollectionName: (NSString *) collectionName
                 andDelegate:(id<MindcloudCollectionGordonDelegate>) delegate;

-(NSString *) getImagePathForAssociationWithName:(NSString *) associationName;

#pragma mark - Association

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

-(void) removeAssociationWithId:(NSString *) associationId
                          andAssociatedItemName:(NSString *) associatedItemName;

#pragma mark - FragmentNamespaceElement

-(void) addCollectionFragmentNamespaceElementWithName:(NSString *) namespaceElementName
                             andNamespaceElement:(XoomlNamespaceElement *) namespaceElement;

/*! If the item is there it will update it, if its not it will create a new one
 */
-(void) setCollectionThumbnailWithData:(NSData *) thumbnailData;

/*! If the item is there it will update it, if its not it will create a new one
 */
-(void) setCollectionThumbnailWithImageOfAssociation:(NSString *) associationId;


/*! If the item is there it will update it, if its not it will create a new one
 */
-(void) setCollectionFragmentNamespaceElementWithName:(NSString *) namespaceElementName
                             toNamespaceElement:(XoomlNamespaceElement *) namespaceElement;


-(void) removeThumbnailForAssociationWithId:(NSString *) subCollectionId;


-(void) removeCollectionFragmentNamespaceElementWithName:(NSString *) collectionAttributeName;

/*! Notifies Gordon that there are still parts that the association needs to have downloaded before it can be displayed. 
    Use when there are multiple parts to the associatedITem and you want to show it atomically
 */

#pragma mark - downloading
-(void) associatedItemIsWaitingForImageForAssociationWithId:(NSString *) subCollectionId
                                     andAssociationName:(NSString *) subCollectionName;

/*! Call this before you finish working with Gordon
 */
-(void) cleanup;

@end
