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
#import "PreviewImageAction.h"
#import "CollectionAction.h"
#import "CollectionNotesAction.h"
#import "NoteAction.h"
#import "NoteImageAction.h"
#import "SharingAction.h"
#import "SubscriptionAction.h"

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

-(void) getPreviewImageForUser: (NSString *) userName
                 forCollection: (NSString *) collectionName
                  withCallback:(get_preview_callback) callback;

-(void) setPreviewImageForUser: (NSString *) userName
                 forCollection: (NSString *) collectionName
                  andImageData: (NSData *) imgData
                  withCallback: (save_preview_callback) callback;

-(void) getCollectionManifestForUser: (NSString *) userName
                       forCollection:(NSString *) collectionName
                        withCallback:(get_collection_callback) callback;

-(void) getAllNotesForUser:(NSString *) userID
             forCollection:(NSString *) collectionName
                    withCallback: (get_all_notes_callback)callback;


-(void) getNoteManifestforUser:(NSString *)userID
                       forNote: (NSString *) noteName
                fromCollection:(NSString *) collectionName
                  withCallback: (get_note_callback) callback;

-(void) getNoteImageForUser: (NSString *) userID
                       forNote: (NSString *)noteName
             fromCollection:(NSString *) collectionName
               withCallback:(get_note_image_callback) callback;

-(void) updateCollectionManifestForUser: (NSString *) userID
                          forCollection: (NSString *) collectionName
                               withData:(NSData *) data
                           withCallback:(update_collection_callback) callback;

-(void) updateNoteForUser: (NSString *) userID
            forCollection: (NSString *) collectionName
                  andNote: (NSString *) noteName
                 withData: (NSData *) data
             withCallback:(add_note_callback) callback;

-(void) updateNoteAndNoteImageForUser: (NSString *) userID
                        forCollection: (NSString *) collectionName
                              andNote: (NSString *) noteName
                         withNoteData: (NSData *) noteData
                         andImageData: (NSData *) imageData
                         withCallback: (add_note_image_callback) callback;

-(void) deleteNoteForUser:(NSString *) userID
            forCollection: (NSString *) collectionName
                  andNote:(NSString *) noteName
             withCallback: (delete_note_callback) callback;
    

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
@end
