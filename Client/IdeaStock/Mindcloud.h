//
//  Mindcloud.h
//  IdeaStock
//
//  Created by Ali Fathalian on 9/22/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionsAction.h"
#import "AuthorizationDelegate.h"
#import "CategoriesAction.h"
#import "CollectionImageAction.h"
#import "CollectionAction.h"
#import "CollectionSubCollectionsAction.h"
#import "SubCollectionAction.h"
#import "SubCollectionImageAction.h"
#import "SharingAction.h"
#import "SubscriptionAction.h"
#import "ListenerAction.h"
#import "TempImageAction.h"
#import "DiffableSerializableObject.h"
#import "CollectionAssetAction.h"
#import "DiffFileAction.h"
#import "SendMessageAction.h"

@interface Mindcloud : NSObject

/*
 Factory method
 */
+(Mindcloud *) getMindCloud;

-(void) authorize:(NSString *) userId
     withDelegate: (id<AuthorizationDelegate>) delegate;

-(void) authorizationDone:(NSString *) userId;

-(void) getAllCollectionsFor:(NSString *) userId
                WithCallback:(get_collections_callback)callback;

-(void) addCollectionFor: (NSString *) userID
                withName: (NSString *) collectionName
            withCallback: (add_collection_callback)callback;

-(void) deleteCollectionFor: (NSString *)userID
                   withName:(NSString *)collectionName
               withCallback:(delete_collection_callback) callback;

-(void) renameCollectionFor:(NSString *)userId
                   withName: (NSString *)collectionName
                withNewName: (NSString *) newCollectionName
               withCallback: (rename_collection_callback) callback;

-(void) getCategories: (NSString *) userId
         withCallback: (get_categories_callback) callback;

-(void) saveCategories: (NSString *) userId
              withData:(NSData *)categoriesData
           andCallback: (save_categories_callback) callback;

-(void) getCollectionImageForUser: (NSString *) userName
                    forCollection: (NSString *) collectionName
                     withCallback:(get_collection_image_callback) callback;

-(void) setCollectionImageForUser: (NSString *) userName
                    forCollection: (NSString *) collectionName
                     andImageData: (NSData *) imgData
                     withCallback: (save_collection_image_callback) callback;

-(void) getCollectionManifestForUser: (NSString *) userName
                       forCollection:(NSString *) collectionName
                        withCallback:(get_collection_callback) callback;

-(void) getAllSubCollectionsForUser:(NSString *) userID
                      forCollection:(NSString *) collectionName
                       withCallback: (get_all_subcollections_callback)callback;


-(void) getSubCollectionManifestforUser:(NSString *)userID
                                forSubCollection: (NSString *) subCollectionName
                         fromCollection:(NSString *) collectionName
                           withCallback: (get_subcollection_callback) callback;

-(void) getSubCollectionImageForUser: (NSString *) userID
                             forSubCollection: (NSString *)subCollectionName
                      fromCollection:(NSString *) collectionName
                        withCallback:(get_subcollection_image_callback) callback;

-(void) updateCollectionManifestForUser: (NSString *) userID
                          forCollection: (NSString *) collectionName
                               withData:(NSData *) data
                           withCallback:(update_collection_callback) callback;

-(void) updateSubCollectionForUser: (NSString *) userID
                     forCollection: (NSString *) collectionName
                  andSubCollection: (NSString *) subCollectionName
                          withData: (NSData *) data
                      withCallback:(add_subcollection_callback) callback;

-(void) updateSubCollectionAndSubCollectionImageForUser: (NSString *) userID
                        forCollection: (NSString *) collectionName
                              andSubCollection: (NSString *) subCollectionName
                         withSubCollectionData: (NSData *) subCollectionData
                         andImageData: (NSData *) imageData
                         withCallback: (add_subcollection_image_callback) callback;

-(void) deleteSubCollectionForUser:(NSString *) userID
            forCollection: (NSString *) collectionName
                  andSubCollection:(NSString *) subCollectionName
             withCallback: (delete_subcollection_callback) callback;


-(void) shareCollection:(NSString *) collectionName
                ForUser:(NSString *) userId
           withCallback:(share_collection_callback) callback;


-(void) unshareCollection:(NSString *) collectionName
                  forUser:(NSString *) userId
             withCallback:(unshare_collection_callback) callback;

-(void) subscribeToCollectionWithSecret:(NSString *) sharingSecret
                                forUser:(NSString *) userId
                           withCallback:(subscribe_to_collection_callback) callback;

-(void) getSharingInfo:(NSString *) collectionName
               forUser:(NSString *) userId
           andCallback:(get_sharing_info_callback) callback;

-(void) addListenerTo:(NSString *) listeningURL
     forSharingSecret:(NSString *) sharingSecret
        andCollection:(NSString *) collectionName
              forUser:(NSString *) userId
         withCallback:(listener_returned_callback) callback;

-(void) sendDiffFileWithName:(NSString *) filename
                     andPath:(NSString *) path
               andCollection:(NSString *) collectionName
                 withContent:(id<DiffableSerializableObject>) content
              toSharingSpace:(NSString *) sharingSpaceURL
            forSharingSecret:(NSString *) sharingSecret;

-(void) closeListenersToURL:(NSString *) listeningURL
           forSharingSecret:(NSString *) sharingSecret
              andCollection:(NSString *) collectionName
                    forUser:(NSString *) userId
               withCallback:(stopped_listenning_callback) callback;

-(void) getTempImageForUser:(NSString *) userId
              andCollection:(NSString *) collectionName
                    andSubCollection:(NSString *) subCollectionName
           andSharingSecret:(NSString *) sharingSecret
             andImageSecret:(NSString *) imgSecret
                 fromBaseUR:(NSString *) baseURL
               withCallback:(get_temp_image_callback) callback;

-(void) saveCollectionAssetForUser:(NSString *) userId
                     andCollection:(NSString *) collectionName
                       withContnet:(id<DiffableSerializableObject>) content
                       andFileName:(NSString *) fileName
                  andSharingSecret:(NSString *) sharingSecret
                       andCallback:(save_collection_asset_callback) callback;

-(void) getCollectionAssetForUser:(NSString *) userId
                    andCollection:(NSString *) collectionName
                      andFileName:(NSString *) fileName
                      andCallback:(get_collection_asset_callback) callback;

-(void) DeleteCollectionAssetForUser:(NSString *) userId
                       andCollection:(NSString *) collectionName
                         andFileName:(NSString *) fileName
                         andCallback:(delete_collection_asset_callback) callback;

-(void) sendDiffFileForUser:(NSString *) userId
              andCollection:(NSString *) collectionName
         andSharingSpaceURL:(NSString *) sharingSpaceURL
           andSharingSecret:(NSString *) sharingSecret
               withFileName:(NSString *) fileName
                    andPath:(NSString *) path
                 andBase64Content:(NSData *) content
                andCallback:(diff_file_sent_callback) callback;

-(void) sendMessageForUser:(NSString *) userId
              andCollection:(NSString *) collectionName
         andSharingSpaceURL:(NSString *) sharingSpaceURL
          andSharingSecret:(NSString *) sharingSecret
                andMessage:(NSString *) message
              andMessageId:(NSString *) messageId
               andCallback:(message_sent_callback) callback;

@end
