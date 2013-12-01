//
//  MindcloudCollectionGordonDelegate.h
//  Mindcloud
//
//  Created by Ali Fathalian on 8/24/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionNoteAttribute.h"
#import "CollectionStackingAttribute.h"
#import "CollectionRecorder.h"
#import "NotificationContainer.h"
#import "XoomlFragment.h"
#import "DiffableSerializableObject.h"

@protocol MindcloudCollectionGordonDelegate <NSObject>

-(void) collectionThumbnailIsForAssociationWithId:(NSString *) associationId;

//TODO this should not be a CollectionNoteAttribute but be generic attribute that the delegate can pick stuff of of
-(void) collectionFragmentHasAssociationWithId: (NSString *) associationId
                     andAssociatedItemFragment:(XoomlFragment *) associatedItemFragment
                                andAssociation:(XoomlAssociation *) association;

//TODO send actual NSDATA instead od stacking Model
-(void) collectionHasNamespaceElementWithName:(NSString *) associationId
                                   andContent:(XoomlNamespaceElement *) namespaceElement;


-(void) associatedItemPartiallyDownloadedWithId:(NSString *) associationId
                                    andFragment:(XoomlFragment *) associtedItemFragment
                                 andAssociation:(XoomlAssociation *) association;

-(void) eventsOccurredWithNotifications: (NotificationContainer *) notifications;

-(void) eventOccuredWithDownloadingOfAssociatedItemWithId:(NSString *) associationId
                             andAssociatedItemFragment:(XoomlFragment *) associatedItemFragment;

-(void) eventOccuredWithDownloadingOfAssocitedItemImage:(NSString *) associationId
                                          withImagePath:(NSString *) imagePath
                                   andAssociatedItemFragment:(XoomlFragment *) associatedItemFragment;

-(void) eventOccuredWithDownloadingOfCollectionAssetDiff:(NSData *) diffContent
                                             forFileName:(NSString *) fileName;

-(void) eventOccuredWithReceivingOfMessage:(NSString *) message
                             withMessageID:(NSString *) messageId;

-(void) associationWithId:(NSString *) subCollectionId
    downloadedImageWithPath:(NSString *) imagePath;

-(void) savePendingAssets;

-(void) collectionDidDownloadCollectionAsset:(NSData *) asset
                                 forFileName:(NSString *) fileName andAttributeName:(NSString *) attributeName;

@end
