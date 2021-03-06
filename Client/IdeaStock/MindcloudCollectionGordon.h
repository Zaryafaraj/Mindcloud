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

@property (nonatomic,strong) NSString * collectionName;

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


-(BOOL) doesFragmentNamespaceExistWithId:(NSString *) ID
                                 andName: (NSString *) attributeName
                            andNamespace:(NSString *) parentNamespace;

/*!
    Convinience method that creates a namespace attribute with attributeName and
    points to a file with filename which its contents should be saved independently
 */
-(void) setCollectionFragmentNamespaceFileWithName:(NSString *) filename
                                  andAttributeName:(NSString *) attributeName
                            andParentNamespaceName:(NSString *) namespaceName
                                        andFixedId:(NSString *) fixedId;

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

/*! will send out a notification once each asset is ready */
-(void) getAllCollectionAssetsAsynch;

-(void) getCollectionAssetForNamespaceElement:(XoomlNamespaceElement *) namespaceElement;

/*! Call this before you finish working with Gordon
 */
-(void) cleanup;

/*===============================================*/
#pragma mark - files
/*===============================================*/

-(void) saveCollectionAsset:(id<DiffableSerializableObject>) content
               withFileName:(NSString *) fileName;

-(void) sendCollectionDiffFileWithFilename:(NSString *) filename
                                andContent:(id<DiffableSerializableObject>) content;

/*===============================================*/
#pragma mark - message
/*===============================================*/
-(void) sendCustomMessageToEveryone:(NSString *) message
                      withMessageId:(NSString *) messageId;
@end
