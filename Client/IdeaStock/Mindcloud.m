//
//  Mindcloud.m
//  IdeaStock
//
//  Created by Ali Fathalian on 9/22/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "Mindcloud.h"
#import "AuthenticationAction.h"

@interface Mindcloud()

//This needs to be weak since we want the delegate to get deallocated whenver
//it wants
//TODO maybe this is not the best way to do this. Maybe this is bad design
@property (weak, nonatomic) id<AuthorizationDelegate> authenticationDelegate;

@end

@implementation Mindcloud

static Mindcloud * instance;

+ (Mindcloud *) getMindCloud
{
    if (!instance)
    {
        instance = [[Mindcloud alloc] init];
    }
    return instance;
}

#define ACCOUNT_STATUS_KEY @"account_status"
#define UNAUTHORIZED_STATUS @"unauthorized"
#define AUTHORIZED_STATUS @"authorized"
#define AUTH_URL @"url"
#define MINDCLOUD_CALLBACK @"mindcloud://done"

/**
 Send an authorize request to mindcloud server. If unauthorized get redirected to the dropbox sign in page 
 and then switch back to the app. 
 If authorized do nothing.
 */

-(void) authorize: (NSString *) userId
     withDelegate:(id<AuthorizationDelegate>)delegate
{
    //set the delegate
    self.authenticationDelegate = delegate;
    //prepare the action
    MindcloudBaseAction * action = [[AuthenticationAction alloc] initWithUserId:userId
                                                                    andCallback:^(NSDictionary * results)
                                {
                                    NSString * accountStatus = results[ACCOUNT_STATUS_KEY];
                                    if ([accountStatus isEqualToString:UNAUTHORIZED_STATUS])
                                    {
                                        NSString * urlStr = results[AUTH_URL];
                                        urlStr = [urlStr stringByAppendingFormat:@"&oauth_callback=%@",MINDCLOUD_CALLBACK];
                                        [self.authenticationDelegate didFinishAuthorizing:userId andNeedsAuthenting:YES withURL:urlStr];
                                        //add a call back URL to switch back to app
                                        
                                    }
                                    else
                                    {
                                        NSLog(@"Account Already Auhtorized and ready to use");
                                        //no authentication step remains
                                        [delegate didFinishAuthorizing:userId andNeedsAuthenting:NO
                                                               withURL:nil];
                                        
                                    }
                                }];
                                    
    [action executeGET];
}

-(void) authorizationDone:(NSString *) userId
{
    MindcloudBaseAction * action = [[AuthenticationAction alloc] initWithUserId:userId
                                                                    andCallback:^(NSDictionary * results)
                                    {
                                        if (results == nil)
                                        {
                                            [self.authenticationDelegate authorizationFailed];
                                            return;
                                        }
                                        else
                                        {
                                            //if someone has registered to recieve notification
                                            //call them
                                            if (self.authenticationDelegate)
                                            {
                                            //we are done, no more steps needed
                                            [self.authenticationDelegate didFinishAuthorizing:userId andNeedsAuthenting:NO withURL:nil];
                                            }
                                            NSLog(@"Account Authorized and Saved in Mindcloud");
                                                
                                        }
                                    }];
    
    [action executePOST];

}

-(void) getAllCollectionsFor:(NSString *)userId
                   WithCallback:(get_collections_callback)callback
{
    
    CollectionsAction * action = [[CollectionsAction alloc] initWithUserID: userId];
    action.getCallback = callback;
    [action executeGET];
}

-(void) addCollectionFor:(NSString *)userId
                withName:(NSString *)collectionName
            withCallback:(add_collection_callback)callback
{
    CollectionsAction * action = [[CollectionsAction alloc] initWithUserID:userId];
    action.postCallback = callback;
    action.postArguments = @{@"collectionName" : collectionName};
    [action executePOST];
}

-(void) renameCollectionFor:(NSString *)userId
                   withName: (NSString *)collectionName
                withNewName: (NSString *) newCollectionName
               withCallback: (rename_collection_callback) callback
{
    CollectionAction * action = [[CollectionAction alloc] initWithUserId:userId
                                                           andCollection:collectionName];
    action.putCallback = callback;
    action.putArguments = @{@"collectionName" : newCollectionName};
    [action executePUT];
}

-(void) deleteCollectionFor: (NSString *)userId
                   withName:(NSString *)collectionName
               withCallback:(delete_collection_callback) callback
{
    
    CollectionAction * action = [[CollectionAction alloc] initWithUserId:userId
                                                           andCollection:collectionName];
    action.deleteCallback = callback;
    
    [action executeDELETE];
}

-(void) getCategories: (NSString *) userId
         withCallback: (get_categories_callback) callback
{
    CategoriesAction * action = [[CategoriesAction alloc] initWithUserID:userId];
    action.getCallback = callback;
    [action executeGET];
}

-(void) saveCategories: (NSString *) userId
              withData:(NSData *)categoriesData
           andCallback: (save_categories_callback) callback
{
    CategoriesAction * action = [[CategoriesAction alloc] initWithUserID:userId];
    action.postCallback = callback;
    action.categoriesData = categoriesData;
    [action executePOST];
}

-(void) getPreviewImageForUser: (NSString *) userName
                 forCollection: (NSString *) collectionName
                  withCallback:(get_preview_callback) callback
{
    PreviewImageAction * action = [[PreviewImageAction alloc] initWithUserID:userName
                                                               andCollection:collectionName];
    action.getCallback = callback;
    [action executeGET];
}

-(void) setPreviewImageForUser: (NSString *) userName
                 forCollection: (NSString *) collectionName
                  andImageData: (NSData *) imgData
                  withCallback: (save_preview_callback) callback
{
    PreviewImageAction * action = [[PreviewImageAction alloc] initWithUserID:userName
                                                               andCollection:collectionName];
    action.postCallback = callback;
    action.previewData = imgData;
    [action executePOST];
}

-(void) getCollectionManifestForUser: (NSString *) userName
                       forCollection:(NSString *) collectionName
                        withCallback:(get_collection_callback) callback
{
    CollectionAction * action = [[CollectionAction alloc] initWithUserId:userName
                                                           andCollection:collectionName];
    action.getCallback = callback;
    [action executeGET];
}

-(void) getAllNotesForUser:(NSString *) userID
             forCollection:(NSString *) collectionName
                    withCallback: (get_all_notes_callback)callback
{
    CollectionNotesAction * action = [[CollectionNotesAction alloc] initWithUserID:userID andCollectionName:collectionName];
    
    action.getCallback = callback;
    [action executeGET];
    
}

-(void) getNoteManifestforUser:(NSString *)userID
                       forNote: (NSString *) noteName
                fromCollection:(NSString *) collectionName
                  withCallback: (get_note_callback) callback
{
    NoteAction * action = [[NoteAction alloc] initWithUserId: userID
                                               andCollection:collectionName
                                                     andNote:noteName];
    action.getCallback = callback;
    [action executeGET];
}

-(void) getNoteImageForUser: (NSString *) userID
                       forNote: (NSString *)noteName
             fromCollection:(NSString *) collectionName
               withCallback:(get_note_image_callback) callback
{
    NoteImageAction * action = [[NoteImageAction alloc] initWithUserId:userID
                                                         andCollection:collectionName
                                                               andNote:noteName];
    
    action.getCallback = callback;
    [action executeGET];
}


-(void) updateCollectionManifestForUser: (NSString *) userID
                          forCollection: (NSString *) collectionName
                               withData:(NSData *) data
                           withCallback:(update_collection_callback) callback
{
    CollectionAction * action = [[CollectionAction alloc] initWithUserId:userID
                                                           andCollection:collectionName];
    
    action.postCallback = callback;
    action.postData = data;
    [action executePOST];
}

#define NOTE_NAME_KEY @"noteName"

-(void) updateNoteForUser: (NSString *) userID
            forCollection: (NSString *) collectionName
                  andNote: (NSString *) noteName
                 withData: (NSData *) data
             withCallback:(add_note_callback) callback
{
    CollectionNotesAction * action = [[CollectionNotesAction alloc] initWithUserID:userID
                                                                 andCollectionName:collectionName];
    action.postCallback = callback;
    action.postArguments = @{NOTE_NAME_KEY:noteName};
    action.postData = data;
    
    [action executePOST];
}

-(void) updateNoteAndNoteImageForUser: (NSString *) userID
                        forCollection: (NSString *) collectionName
                              andNote: (NSString *) noteName
                         withNoteData: (NSData *) noteData
                         andImageData: (NSData *) imageData
                         withCallback: (add_note_image_callback) callback
{
    
    CollectionNotesAction * action = [[CollectionNotesAction alloc] initWithUserID:userID
                                                                 andCollectionName:collectionName];
    action.postCallback = ^(void){
        //now upload image
        NoteImageAction * imgAction = [[NoteImageAction alloc] initWithUserId:userID
                                                                andCollection:collectionName
                                                                      andNote:noteName];
        imgAction.postData = imageData;
        imgAction.postCallback = callback;
        
        [imgAction executePOST];
    };
    
    action.postArguments = @{NOTE_NAME_KEY:noteName};
    action.postData = noteData;
    
    [action executePOST];
    
}

-(void) deleteNoteForUser:(NSString *) userID
            forCollection: (NSString *) collectionName
                  andNote:(NSString *) noteName
             withCallback: (delete_note_callback) callback
{
    NoteAction * action = [[NoteAction alloc] initWithUserId:userID
                                               andCollection:collectionName
                                                     andNote:noteName];
    
    action.deleteCallback = callback;
    
    [action executeDELETE];
}

-(void) shareCollection:(NSString *) collectionName
                ForUser:(NSString *) userId
           withCallback:(share_collection_callback) callback
{
    SharingAction * action = [[SharingAction alloc] initWithUserId:userId
                                                 andCollectionName:collectionName];
    
    action.postCallback = callback;
    
    [action executePOST];
}

-(void) unshareCollection:(NSString *) collectionName
                  forUser:(NSString *) userId
             withCallback:(unshare_collection_callback) callback
{
    
    SharingAction * action = [[SharingAction alloc] initWithUserId:userId
                                                 andCollectionName:collectionName];
    
    action.deleteCallback = callback;
    
    [action executeDELETE];
}
@end
