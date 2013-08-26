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

-(void) getCollectionImageForUser: (NSString *) userName
                 forCollection: (NSString *) collectionName
                  withCallback:(get_collection_image_callback) callback
{
    CollectionImageAction * action = [[CollectionImageAction alloc] initWithUserID:userName
                                                               andCollection:collectionName];
    action.getCallback = callback;
    [action executeGET];
}

-(void) setCollectionImageForUser: (NSString *) userName
                 forCollection: (NSString *) collectionName
                  andImageData: (NSData *) imgData
                  withCallback: (save_collection_image_callback) callback
{
    CollectionImageAction * action = [[CollectionImageAction alloc] initWithUserID:userName
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

-(void) getAllSubCollectionsForUser:(NSString *) userID
             forCollection:(NSString *) collectionName
              withCallback: (get_all_subcollections_callback)callback
{
    CollectionSubCollectionsAction * action = [[CollectionSubCollectionsAction alloc] initWithUserID:userID andCollectionName:collectionName];
    
    action.getCallback = callback;
    [action executeGET];
    
}

-(void) getSubCollectionManifestforUser:(NSString *)userID
                       forSubCollection: (NSString *) subCollection
                fromCollection:(NSString *) collectionName
                  withCallback: (get_subcollection_callback) callback
{
    SubCollectionAction * action = [[SubCollectionAction alloc] initWithUserId: userID
                                               andCollection:collectionName
                                                     andSubCollection:subCollection];
    action.getCallback = callback;
    [action executeGET];
}

-(void) getSubCollectionImageForUser: (NSString *) userID
                    forSubCollection: (NSString *)subCollection
             fromCollection:(NSString *) collectionName
               withCallback:(get_subcollection_image_callback) callback
{
    SubCollectionImageAction * action = [[SubCollectionImageAction alloc] initWithUserId:userID
                                                         andCollection:collectionName
                                                               andSubCollection:subCollection];
    
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

#define SUBCOLLECTION_NAME_KEY @"noteName"

-(void) updateSubCollectionForUser: (NSString *) userID
            forCollection: (NSString *) collectionName
                  andSubCollection: (NSString *) subCollection
                 withData: (NSData *) data
             withCallback:(add_subcollection_callback) callback
{
    CollectionSubCollectionsAction * action = [[CollectionSubCollectionsAction alloc] initWithUserID:userID
                                                                 andCollectionName:collectionName];
    action.postCallback = callback;
    action.postArguments = @{SUBCOLLECTION_NAME_KEY:subCollection};
    action.postData = data;
    
    [action executePOST];
}

-(void) updateSubCollectionAndSubCollectionImageForUser: (NSString *) userID
                        forCollection: (NSString *) collectionName
                              andSubCollection: (NSString *) subCollection
                         withSubCollectionData: (NSData *) subCollectionData
                         andImageData: (NSData *) imageData
                         withCallback: (add_subcollection_image_callback) callback
{
    
    CollectionSubCollectionsAction * action = [[CollectionSubCollectionsAction alloc] initWithUserID:userID
                                                                 andCollectionName:collectionName];
    action.postCallback = ^(void){
        //now upload image
        SubCollectionImageAction * imgAction = [[SubCollectionImageAction alloc] initWithUserId:userID
                                                                andCollection:collectionName
                                                                      andSubCollection:subCollection];
        imgAction.postData = imageData;
        imgAction.postCallback = callback;
        
        [imgAction executePOST];
    };
    
    action.postArguments = @{SUBCOLLECTION_NAME_KEY:subCollection};
    action.postData = subCollectionData;
    
    [action executePOST];
    
}

-(void) deleteSubCollectionForUser:(NSString *) userID
            forCollection: (NSString *) collectionName
                  andSubCollection:(NSString *) subCollection
             withCallback: (delete_subcollection_callback) callback
{
    SubCollectionAction * action = [[SubCollectionAction alloc] initWithUserId:userID
                                               andCollection:collectionName
                                                     andSubCollection:subCollection];
    
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

-(void) getSharingInfo:(NSString *) collectionName
               forUser:(NSString *) userId
           andCallback:(get_sharing_info_callback) callback
{
    SharingAction * action = [[SharingAction alloc] initWithUserId:userId
                                                 andCollectionName:collectionName];
    
    action.getCallback = callback;
    
    [action executeGET];
    
}

-(void) subscribeToCollectionWithSecret:(NSString *) sharingSecret
                                forUser:(NSString *) userId
                           withCallback:(subscribe_to_collection_callback) callback
{
    SubscriptionAction * action = [[SubscriptionAction alloc] initWithUserId:userId
                                                            andSharingSecret:sharingSecret];
    
    action.postCallback = callback;
    
    [action executePOST];
}

-(void) addListenerTo:(NSString *) listeningURL
     forSharingSecret:(NSString *) sharingSecret
        andCollection:(NSString *) collectionName
              forUser:(NSString *) userId
         withCallback:(listener_returned_callback) callback;
{
    ListenerAction * action = [[ListenerAction alloc] initWithUserId:userId
                                                   andCollectionName:collectionName
                                                    andSharingSecret:sharingSecret
                                                  andSharingSpaceURL:listeningURL];
    action.postCallback = callback;
    
    [action executePOST];
}

-(void) closeListenersToURL:(NSString *) listeningURL
           forSharingSecret:(NSString *) sharingSecret
              andCollection:(NSString *) collectionName
                    forUser:(NSString *) userId
               withCallback:(stopped_listenning_callback) callback
{
    ListenerAction * action = [[ListenerAction alloc] initWithUserId:userId
                                                   andCollectionName:collectionName
                                                    andSharingSecret:sharingSecret
                                                  andSharingSpaceURL:listeningURL];
    action.deleteCallback = callback;
    
    [action executeDELETE];
}

//super ugly !
-(void) getTempImageForUser:(NSString *) userId
              andCollection:(NSString *) collectionName
                    andSubCollection:(NSString *) subCollection
           andSharingSecret:(NSString *) sharingSecret
             andImageSecret:(NSString *) imgSecret
                 fromBaseUR:(NSString *) baseURL
               withCallback:(get_temp_image_callback) callback
{
    TempImageAction * action = [[TempImageAction alloc] initWithUserId:userId
                                                         andCollection:collectionName
                                                               andSubCollection:subCollection
                                                         andTempSecret:imgSecret
                                                                andURL:baseURL andSharingSecret:sharingSecret];
    
    action.getCallback = callback;
    
    [action executeGET];
}

@end
