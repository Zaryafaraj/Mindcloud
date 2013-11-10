//
//  CachedCollectionDataModel.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/8/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CachedMindCloudDataSource.h"
#import "FileSystemHelper.h"
#import "Mindcloud.h"
#import "UserPropertiesHelper.h"
#import "EventTypes.h"
#import "NetworkActivityHelper.h"
#import "XoomlFragment.h"


@interface CachedMindCloudDataSource()
//we make sure that we don't send out an action before another action of the same type on the same
//resource is in progress, because of unreliable TCP/IP the second action might reach the server faster
//and we want to avoid it.
//These indicate whether an action is being in progress
@property NSMutableDictionary * inProgressAssociatedItemUpdates;
@property NSMutableDictionary * inProgressAssociatedItemImageUpdates;
@property BOOL collectionFragmentUpdateInProgress;
//Indicates which thumbnails are in the process of retreival.
//This is because that the collectionView is very anxious and asks
//for thumbnails multiple times before they get cached,
//this way we ask once and ignore the rest of the requests until the first request comes back
@property NSMutableDictionary * isInProgressOfGettingThumbnail;

//dictionaries keyed on the associatedItem name and valued on associatedItemData that contain the last update associatedItem
//that is waiting. In case a new one comes in while the associatedItem update is in progress it just replaces
//the old one
@property NSMutableDictionary * associatedItemUpdateQueue;
@property NSMutableDictionary * associatedItemImageUpdateQueue;
@property NSMutableDictionary * waitingDeleteAssociatedItems;
@property NSData * waitingUpdateManifestData;

// Keyed on asset filename and valued on the assetObj
@property NSMutableDictionary * collectionAssetUploadQueue;
@property BOOL collectionAssetUploadInProgress;

/*
 The idea is that we cache item each time the app is run; ( app going to the background doesn't count). These two dictionaries make sure that we only refresh the cache once
 */

//keyed on collectionName
@property NSMutableDictionary * thumbnailHasUpdatedCache;
@property NSMutableDictionary * collectionHasUpdatedCache;
//keyed on (collectionName + associatedItemName + imgName) and valued on yes/no
//these two are kinda redundant
@property NSMutableDictionary * collectionImagesCache;
//keyed on collection name value is a dictionary keyed on associatedItem name  and image path
@property BOOL isCategoriesUpdated;

@property (nonatomic, strong) NSMutableDictionary * sharedCollections;

@end

@implementation CachedMindCloudDataSource
//singleTone
+(id) getInstance:(NSString *) collectionName
{
    
    static NSMutableDictionary * instances = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instances = [NSMutableDictionary dictionary];
    });
    
    if (!instances[collectionName])
    {
        instances[collectionName] = [[CachedMindCloudDataSource alloc] init];
    }
    return instances[collectionName];
}

-(id) init
{
    self = [super init];
    self.inProgressAssociatedItemImageUpdates = [NSMutableDictionary dictionary];
    self.inProgressAssociatedItemUpdates = [NSMutableDictionary dictionary];
    self.associatedItemImageUpdateQueue = [NSMutableDictionary dictionary];
    self.associatedItemUpdateQueue = [NSMutableDictionary dictionary];
    self.collectionHasUpdatedCache = [NSMutableDictionary dictionary];
    self.collectionImagesCache = [NSMutableDictionary dictionary];
    self.thumbnailHasUpdatedCache = [NSMutableDictionary dictionary];
    self.sharedCollections = [NSMutableDictionary dictionary];
    self.collectionAssetUploadQueue = [NSMutableDictionary dictionary];
    self.isCategoriesUpdated = NO;
    self.collectionAssetUploadInProgress = NO;
    self.isInProgressOfGettingThumbnail = [NSMutableDictionary dictionary];
    return self;
}

-(void) collectionIsShared:(NSString *)collectionName
{
    self.sharedCollections[collectionName] = @YES;
}

-(void) collectionIsNotShared:(NSString *) collectionName
{
    [self.sharedCollections removeObjectForKey:collectionName];
}

-(NSArray *) getAllCollections
{
    
    //try cache
    NSMutableArray * tempAnswer = [[self getAllCollectionsFromDisk] mutableCopy];
    //in any case do another refresh
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    [mindcloud getAllCollectionsFor:userId
                       WithCallback:^(NSArray * collection)
     {
         //make sure to remove stale items from cache
         [self consolidateCache:collection];
         for (NSString * collectionName in collection)
         {
             [self createCollectionToDisk:collectionName];
         }
         if (collection != nil)
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:ALL_COLLECTIONS_LIST_DOWNLOADED_EVENT
                                                                 object:self
                                                               userInfo:@{@"result" : collection}];
         }
     }];
    return tempAnswer;
}

-(void) addCollectionWithName:(NSString *) collectionName
{
    
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    [mindcloud addCollectionFor:userId withName:collectionName withCallback:^{
        //NSLog(@"Collection %@ added", name);
    }];
    [self createCollectionToDisk:collectionName];
}

-(void) renameCollectionWithName:(NSString *) collectionName
                              to:(NSString *) newCollectionName
{
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    [mindcloud renameCollectionFor:userId
                          withName:collectionName
                       withNewName:newCollectionName
                      withCallback:^{
                          ;
                      }];
    [self renameCollectionOnDisk:collectionName to:newCollectionName];
}

-(void) deleteCollectionFor:(NSString *) collectionName
{
    
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    self.collectionHasUpdatedCache[collectionName] = @NO;
    //maybe later I will add code here that stop any outstanding items for the collection
    //and remove the interning of this collection
    [mindcloud deleteCollectionFor:userId
                          withName:collectionName
                      withCallback:^{
                          //NSLog(@"Collection %@ Deleted", collectionName);
                      }];
    [self.collectionImagesCache removeObjectForKey:collectionName];
    [self.thumbnailHasUpdatedCache removeObjectForKey:collectionName];
    [self deleteCollectionFromDisk:collectionName];
}

-(void) authorizeUser:(NSString *) userID
withAuthenticationDelegate:(id<AuthorizationDelegate>) del;
{
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    [mindcloud authorize:userID withDelegate:del];
}

-(NSData *) getCategories
{
    NSData * categoriesData = [self readCategoriesFromDisk];
    //return the cached one and update the cache
    if (!self.isCategoriesUpdated)
    {
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userId = [UserPropertiesHelper userID];
        [mindcloud getCategories:userId withCallback:^(NSData * categories)
         {
             if (categories)
             {
                 NSLog(@"Categories Retrieved");
                 [self writeCategoriesToDisk:categories];
                 self.isCategoriesUpdated = YES;
                 [[NSNotificationCenter defaultCenter] postNotificationName:CATEGORIES_RECEIVED_EVENT
                                                                     object:self
                                                                   userInfo:@{@"result" : categories}];
             }
             else{
                 NSLog(@"No Categories Received");
                 [[NSNotificationCenter defaultCenter] postNotificationName:CATEGORIES_RECEIVED_EVENT
                                                                     object:self
                                                                   userInfo:@{}];
             }
         }];
    }
    return categoriesData;
}

-(void) saveCategories:(NSData *) categoriesData
{
    [self writeCategoriesToDisk:categoriesData];
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    [mindcloud saveCategories:userId
                     withData:categoriesData
                  andCallback:^{
                      NSLog(@"Categories synchronized");
                  }];
}

-(BOOL) shouldUpdateThumbnailFor:(NSString *) collectionName
{
    if (self.sharedCollections[collectionName] && self.thumbnailHasUpdatedCache[collectionName]) return YES;
    else if (!self.thumbnailHasUpdatedCache[collectionName]) return YES;
    else return NO;
}
-(NSData *) getThumbnailForCollection:(NSString *) collectionName
{
    
    NSData * thumbnailData = [self getThumbnailFromDiskForCollection:collectionName];
    if ([self shouldUpdateThumbnailFor:collectionName])
    {
        if (!self.isInProgressOfGettingThumbnail[collectionName])
        {
            self.isInProgressOfGettingThumbnail[collectionName] = @YES;
            
            [NetworkActivityHelper addActivityInProgress];
            Mindcloud * mindcloud = [Mindcloud getMindCloud];
            NSString * userID = [UserPropertiesHelper userID];
            
            [mindcloud getCollectionImageForUser:userID
                                   forCollection:collectionName
                                    withCallback:^(NSData * imgData){
                                        
                                        self.isInProgressOfGettingThumbnail[collectionName] = @NO;
                                        NSDictionary * userDict;
                                        if (imgData)
                                        {
                                            [self saveThumbnailToDisk:imgData forCollection:collectionName];
                                            self.thumbnailHasUpdatedCache[collectionName] = @YES;
                                            userDict =
                                            @{
                                              @"result":
                                                  @{
                                                      @"collectionName" : collectionName,
                                                      @"data" : imgData
                                                      }
                                              };
                                        }
                                        else
                                        {
                                            userDict =
                                            @{
                                              @"result":
                                                  @{
                                                      @"collectionName" : collectionName
                                                      }
                                              };
                                        }
                                        [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTION_IMAGE_RECEIVED_EVENT
                                                                                            object:self
                                                                                          userInfo:userDict];
                                        [NetworkActivityHelper removeActivityInProgress];
                                        //in any case send out the notification
                                    }];
            
            
        }
    }
    return thumbnailData;
}

-(void) setThumbnail:(NSData *)thumbnailData
       forCollection:(NSString *)collectionName
{
    
    [self saveThumbnailToDisk:thumbnailData forCollection:collectionName];
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userID = [UserPropertiesHelper userID];
    [mindcloud setCollectionImageForUser:userID
                           forCollection:collectionName
                            andImageData:thumbnailData
                            withCallback:^(void){
                                ;
                            }];
}
#pragma mark - Addition/Update

- (void) addAssociatedItemWithName: (NSString *) associatedItemName
                andFragmentContent: (NSData *) associatedItem
                      ToCollection: (NSString *) collectionName
{
    
    //If there was a plan to delete this associatedItem just cancel it
    if (self.waitingDeleteAssociatedItems[associatedItemName])
    {
        self.waitingDeleteAssociatedItems[associatedItemName] = @NO;
    }
    
    if ([self.inProgressAssociatedItemUpdates[associatedItemName] isEqual:@YES])
    {
        self.associatedItemUpdateQueue[associatedItemName] = associatedItem;
        return;
    }
    
    else
    {
        self.inProgressAssociatedItemUpdates[associatedItemName] = @YES;
        
        [self saveToDiskAssociatedItemData:associatedItem
                             forCollection:collectionName
                         andAssociatedItem:associatedItemName];
        
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userID = [UserPropertiesHelper userID];
        [mindcloud updateSubCollectionForUser:userID
                                forCollection:collectionName
                             andSubCollection:associatedItemName
                                     withData:associatedItem
                                 withCallback:^(void){
                                     self.inProgressAssociatedItemUpdates[associatedItemName] = @NO;
                                     NSLog(@"Updated AssociatedItem %@ for Collection %@", associatedItemName, collectionName);
                                     
                                     if (self.waitingDeleteAssociatedItems[associatedItemName])
                                     {
                                         [self removeAssociatedItem:associatedItemName FromCollection:collectionName];
                                     }
                                     else if (self.associatedItemUpdateQueue[associatedItemName])
                                     {
                                         NSData * latestAssociatedItemData = self.associatedItemUpdateQueue[associatedItemName];
                                         [self.associatedItemUpdateQueue removeObjectForKey:associatedItemName];
                                         
                                         [self addAssociatedItemWithName:associatedItemName
                                                      andFragmentContent:latestAssociatedItemData
                                                            ToCollection:collectionName];
                                     }
                                 }];
        
    }
}

-(void) saveCollectionAsset:(id<DiffableSerializableObject>) content
               withFileName:(NSString *) fileName
              forCollection:(NSString *) collectionName;
{
    //to something like the method above
    [self saveToDiskCollectionAsset: content
                       withFileName:fileName
                      forCollection:collectionName];
    
    [self uploadCollectionAssetForCollection:collectionName
                                 andFileName:fileName
                                  andContent:content
                             andRetryCounter:0];
    
    
}

-(NSData *) getCollectionAssetWithFilename:(NSString *)filename
                                                   forCollection:(NSString *)collectionName
{
   NSString * path = [FileSystemHelper getPathForCollectionAssetWithName:filename
                                                   forCollectionWithName:collectionName];
    NSData * fileContent = [NSData dataWithContentsOfFile:path];
    return fileContent;
}

#define MAX_FILE_UPLPOAD_RETRY 2
-(void) uploadCollectionAssetForCollection:(NSString *) collectionName
                                   andFileName:(NSString *) fileName
                                    andContent:(id<DiffableSerializableObject>) content
                               andRetryCounter:(int) retryCounter
{
    //if there is something in progress just put it in the queue
    //once the item in progress is done it will pick this back up
    //from the queue
    if (self.collectionAssetUploadInProgress)
    {
        self.collectionAssetUploadQueue[fileName] = content;
    }
    else
    {
        self.collectionFragmentUpdateInProgress = YES;
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userID = [UserPropertiesHelper userID];
        [mindcloud saveCollectionAssetForUser:userID
                                andCollection:collectionName
                                  withContnet:content
                                  andFileName:fileName
                                  andCallback:^(BOOL didFinish){
                                      //If upload failed but we had one more retry chance retry
                                      if (!didFinish && retryCounter < MAX_FILE_UPLPOAD_RETRY)
                                      {
                                          int newRetryCounter = retryCounter + 1;
                                          NSLog(@"retrying upload collection asset for collection %@ and filename %@", collectionName, fileName);
                                          [self uploadCollectionAssetForCollection:collectionName
                                                                           andFileName:fileName
                                                                            andContent:content
                                                                       andRetryCounter:newRetryCounter];
                                      }
                                      //else pick up a new job
                                      else
                                      {
                                          NSLog(@"uploaded collection asset for collection %@ and filename %@", collectionName, fileName);
                                          self.collectionAssetUploadInProgress = NO;
                                          NSArray * remainingUploads = self.collectionAssetUploadQueue.allKeys;
                                          if (remainingUploads.count > 0)
                                          {
                                              NSString * lastFileName = remainingUploads.lastObject;
                                              id<DiffableSerializableObject> lastContent = self.collectionAssetUploadQueue[lastFileName];
                                              [self.collectionAssetUploadQueue removeObjectForKey:lastFileName];
                                              [self uploadCollectionAssetForCollection:collectionName
                                                                               andFileName:lastFileName
                                                                                andContent:lastContent andRetryCounter:0];
                                          }
                                      }
                                  }];
    }

}
-(void) addAssociatedItemWithName: (NSString *) associatedItemName
               andFragmentContent: (NSData *) associatedItem
                         andImage: (NSData *) img
                withImageFileName: (NSString *)imgName
                     toCollection: (NSString *) collectionName;
{
    //If there was a plan to delete this associatedItem just cancel it
    if (self.waitingDeleteAssociatedItems[associatedItemName])
    {
        self.waitingDeleteAssociatedItems[associatedItemName] = @NO;
    }
    
    if ([self.inProgressAssociatedItemImageUpdates[associatedItemName] isEqual:@YES])
    {
        self.associatedItemImageUpdateQueue[associatedItemName] = associatedItem;
        self.associatedItemUpdateQueue[associatedItemName] = img;
    }
    else
    {
        self.inProgressAssociatedItemImageUpdates[associatedItemName] = @YES;
        
        [self saveToDiskAssociatedItemData:associatedItem
                             forCollection:collectionName
                         andAssociatedItem:associatedItemName];
        
        [self saveToDiskAssociatedItemImageData:img
                                  forCollection:collectionName
                              andAssociatedItem:associatedItemName];
        
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userID = [UserPropertiesHelper userID];
        [mindcloud updateSubCollectionAndSubCollectionImageForUser:userID
                                                     forCollection:collectionName
                                                  andSubCollection:associatedItemName
                                             withSubCollectionData:associatedItem
                                                      andImageData:img
                                                      withCallback:^(void) {
                                                          
                                                          self.inProgressAssociatedItemImageUpdates[associatedItemName] = @NO;
                                                          NSLog(@"Updated AssociatedItem img %@ for Collection %@", associatedItemName, collectionName);
                                                          
                                                          if (self.waitingDeleteAssociatedItems[associatedItemName])
                                                          {
                                                              [self removeAssociatedItem:associatedItemName FromCollection:collectionName];
                                                          }
                                                          else if (self.associatedItemUpdateQueue[associatedItemName] && self.associatedItemImageUpdateQueue[associatedItemName])
                                                          {
                                                              NSData * latestImg = self.associatedItemImageUpdateQueue[associatedItemName];
                                                              NSData * latestAssociatedItem = self.associatedItemUpdateQueue[associatedItemName];
                                                              [self.associatedItemUpdateQueue removeObjectForKey:associatedItemName];
                                                              [self.associatedItemImageUpdateQueue removeObjectForKey:associatedItemName];
                                                              [self addAssociatedItemWithName:associatedItemName
                                                                           andFragmentContent:latestAssociatedItem
                                                                                     andImage:latestImg
                                                                            withImageFileName:@"associatedItem.jpg"
                                                                                 toCollection:collectionName];
                                                          }
                                                      }];
    }
}

-(void) updateCollectionWithName: (NSString *) collectionName
              andFragmentContent: (NSData *) content
{
    if ([content length] == 0)
    {
        return;
    }
    
    if (self.collectionFragmentUpdateInProgress)
    {
        self.waitingUpdateManifestData = content;
    }
    else
    {
        self.collectionFragmentUpdateInProgress = YES;
        
        [self saveToDiskCollectionData:content
                         ForCollection:collectionName];
        
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userID = [UserPropertiesHelper userID];
        [mindcloud updateCollectionManifestForUser:userID forCollection:collectionName withData:content withCallback:^(void){
            self.collectionFragmentUpdateInProgress = NO;
            NSLog(@"Update Manifest for collection %@", collectionName);
            if (self.waitingUpdateManifestData)
            {
                NSData * latestData = self.waitingUpdateManifestData;
                self.waitingUpdateManifestData = nil;
                [self updateCollectionWithName:collectionName andFragmentContent:latestData];
            }
        }];
    }
}

-(void) updateAssociatedItem: (NSString *) associatedItemName
         withFragmentContent: (NSData *) content
                inCollection:(NSString *) collectionName
{
    [self addAssociatedItemWithName:associatedItemName andFragmentContent:content ToCollection:collectionName];
}

- (void) removeAssociatedItem: (NSString *) associatedItemName
               FromCollection: (NSString *) collectionName
{
    //we don't possibly want the delete to reach the server before the add. In that case it will get deleted and added again
    if ([self.inProgressAssociatedItemImageUpdates[associatedItemName] isEqual:@YES] || [self.inProgressAssociatedItemUpdates[associatedItemName] isEqual:@YES])
    {
        self.waitingDeleteAssociatedItems[associatedItemName] = @YES;
        //if there were prior actions that wait to be performed on the deleted associatedItem just cancel them
        if (self.associatedItemImageUpdateQueue[associatedItemName])
        {
            [self.associatedItemImageUpdateQueue removeObjectForKey:associatedItemName];
        }
        if (self.associatedItemUpdateQueue[associatedItemName])
        {
            [self.associatedItemUpdateQueue removeObjectForKey:associatedItemName];
        }
    }
    else
    {
        [self removeFromDiskAssociatedItem:associatedItemName fromCollection:collectionName];
        
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userID = [UserPropertiesHelper userID];
        
        [mindcloud deleteSubCollectionForUser:userID forCollection:collectionName andSubCollection:associatedItemName withCallback:^(void){
            NSLog(@"Deleted AssociatedItem %@ in collection %@", associatedItemName, collectionName);
        }];
    }
}


#pragma mark retreival
-(BOOL) shouldUpdateCacheForCollection:(NSString *) collectionName
{
    if (self.sharedCollections[collectionName] && self.collectionHasUpdatedCache[collectionName]) return YES;
    else if (!self.collectionHasUpdatedCache[collectionName]) return YES;
    else return NO;
}

-(NSData *) getCollectionFromCache:(NSString *)collectionName
{
    NSData * cachedData = [self getCollectionFromDisk:collectionName];
    return cachedData;
}

- (NSData *) getCollection: (NSString *) collectionName
{
    NSData * cachedData = [self getCollectionFromDisk:collectionName];
    if ([self shouldUpdateCacheForCollection:collectionName])
    {
        [self getCollectionFromServer:collectionName];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CACHE_IS_IN_SYNCH_WITH_SERVER
                                                            object:self];
        
    }
    return cachedData;
}

-(void) getCollectionFromServer:(NSString * )collectionName
{
    //whatever is cached we try to retreive the collection again
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userID = [UserPropertiesHelper userID];
    [NetworkActivityHelper addActivityInProgress];
    [mindcloud getCollectionManifestForUser:userID
                              forCollection:collectionName
                               withCallback:^(NSData * collectionData, BOOL shouldSynchClient){
                                   if (collectionData)
                                   {
                                       
                                       [self saveToDiskCollectionData:collectionData
                                                        ForCollection:collectionName];
                                       //get the rest of the associatedItems
                                       [self getAllAssociatedItems:collectionName];
                                   }
                                   else
                                   {
                                       [NetworkActivityHelper removeActivityInProgress];
                                       if (shouldSynchClient)
                                       {
                                           //get the rest of the associatedItems
                                           [self getAllAssociatedItems:collectionName];
                                       }
                                   }
                               }];
}
- (void) getAllAssociatedItems:(NSString *) collectionName
{
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userID = [UserPropertiesHelper userID];
    [mindcloud getAllSubCollectionsForUser:userID
                             forCollection:collectionName
                              withCallback:^(NSArray * allAssociatedItems){
                                  int index = 0;
                                  
                                  //we are not going to download all the images in the beginning beccause we don't know what are they
                                  [self getRemainingAssociatedItemAtIndex: index
                                                                fromArray: allAssociatedItems
                                                            forCollection: collectionName
                                                              chainImages:NO ];
                              }];
    
}

-(void) getRemainingAssociatedItemAtIndex:(int) index
                                fromArray:(NSArray *) allAssociatedItems
                            forCollection:(NSString *) collectionName
                              chainImages:(BOOL) chain
{
    if (index < [allAssociatedItems count])
    {
        
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userID = [UserPropertiesHelper userID];
        NSString * associatedItemName = allAssociatedItems[index];
        index++;
        [mindcloud getSubCollectionManifestforUser:userID
                                  forSubCollection:associatedItemName
                                    fromCollection:collectionName withCallback:^(NSData * associatedItemData){
                                        
                                        [self saveToDiskAssociatedItemData:associatedItemData
                                                             forCollection:collectionName
                                                         andAssociatedItem:associatedItemName];
                                        [self getRemainingAssociatedItemAtIndex:index
                                                                      fromArray:allAssociatedItems
                                                                  forCollection:collectionName
                                                                    chainImages:chain];
                                    }];
        
    }
    else
    {
        if (chain)
        {
            [self getRemainingAssociatedItemImagesAtIndex:0
                                                fromArray:allAssociatedItems
                                            forCollection:collectionName
                                     chainAssociatedItems:!chain];
        }
        else
        {
            [self downloadComplete:collectionName];
        }
    }
}

-(void) getRemainingAssociatedItemImagesAtIndex: (int) index
                                      fromArray: (NSArray *) allAssociatedItems
                                  forCollection:(NSString *) collectionName
                           chainAssociatedItems: (BOOL) chain
{
    if (index < [allAssociatedItems count])
    {
        
        index++;
        NSString * associatedItemName = allAssociatedItems[index];
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userID = [UserPropertiesHelper userID];
        [mindcloud getSubCollectionImageForUser:userID
                               forSubCollection:associatedItemName
                                 fromCollection:collectionName withCallback:^(NSData * associatedItemData){
                                     
                                     [self saveToDiskAssociatedItemImageData:associatedItemData
                                                               forCollection:collectionName
                                                           andAssociatedItem:associatedItemName];
                                     [self getRemainingAssociatedItemImagesAtIndex:index
                                                                         fromArray:allAssociatedItems
                                                                     forCollection:collectionName
                                                              chainAssociatedItems:chain];
                                 }];
    }
    else
    {
        if (chain)
        {
            [self getRemainingAssociatedItemAtIndex:0
                                          fromArray:allAssociatedItems
                                      forCollection:collectionName
                                        chainImages:!chain];
        }
        else
        {
            //This means we have downloaded everything
            [self downloadComplete:collectionName];
        }
    }
    
}

-(void) downloadComplete:(NSString *) collectionName
{
    NSLog(@"Download Completed for %@", collectionName);
    //tell the notification center that download has been completed
    self.collectionHasUpdatedCache[collectionName] = @YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTION_DOWNLOADED_EVENT
                                                        object:self];
    [NetworkActivityHelper removeActivityInProgress];
    
}

- (NSData *) getAssociatedItemForTheCollection: (NSString *) collectionName
                                      WithName: (NSString *) associatedItemName
{
    //it is always assumed that the this method is called after a get collection which caches everything
    //so if we get a cache hit we trust that its most uptodate
    NSData * associatedItemData = [self getFromDiskAssociatedItem:associatedItemName fromCollection:collectionName];
    if (!associatedItemData)
    {
        return nil;
    }
    else
    {
        return associatedItemData;
    }
}

- (NSString *) getImagePathForAssociatedItem: (NSString *) associatedItemName
                               andCollection: (NSString *) collectionName;
{
    //we retreive the images all the time. Only methods that sure there is an image should call this to stop making extra calls to the server
    NSData * imgData = [self getFromDiskAssociatedItemImageForAssociatedItem:associatedItemName andCollection: collectionName];
    NSString * path = nil;
    if (imgData)
    {
        
        path = [FileSystemHelper getPathForAssociatedItemImageforAssociatedItemName:associatedItemName
                                                                       inCollection:collectionName];
    }
    //images are always cached whether for shared or unshared collections
    if (!self.collectionImagesCache[collectionName][associatedItemName])
    {
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userID = [UserPropertiesHelper userID];
        [mindcloud getSubCollectionImageForUser:userID
                               forSubCollection:associatedItemName
                                 fromCollection:collectionName withCallback:^(NSData * associatedItemData){
                                     
                                     if (associatedItemData)
                                     {
                                         [self saveToDiskAssociatedItemImageData:associatedItemData
                                                                   forCollection:collectionName
                                                               andAssociatedItem:associatedItemName];
                                         if (!self.collectionImagesCache[collectionName])
                                         {
                                             self.collectionImagesCache[collectionName] = [NSMutableDictionary dictionary];
                                         }
                                         self.collectionImagesCache[collectionName][associatedItemName] = @YES;
                                         
                                         NSDictionary * userDict =
                                         @{
                                           @"result":
                                               @{
                                                   @"collectionName" : collectionName,
                                                   @"associatedItemName" : associatedItemName
                                                   }
                                           };
                                         
                                         [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_DOWNLOADED_EVENT
                                                                                             object:self
                                                                                           userInfo:userDict];
                                     }
                                 }];
        
    }
    return path;
}

#pragma mark - Disk Cache helpers

-(NSArray *) getAllCollectionsFromDisk
{
    NSString * path = [FileSystemHelper getPathForAllCollections];
    NSError * err;
    NSArray * firstAnser =  [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path
                                                                                error:&err];
    NSMutableArray * tempAnswer = [firstAnser mutableCopy];
    //for debugging on a mac
    [tempAnswer removeObject:@".DS_Store"];
    [tempAnswer removeObject:@"categories.xml"];
    return [tempAnswer copy];
}
- (NSData *) getCollectionFromDisk: (NSString *) collectionName{
    
    NSString * path = [FileSystemHelper getPathForCollectionWithName: collectionName];
    NSError * err;
    NSString *data = [NSString stringWithContentsOfFile:path
                                               encoding:NSUTF8StringEncoding
                                                  error:&err];
    if (!data){
        return nil;
    }
    
    return [data dataUsingEncoding:NSUTF8StringEncoding];
}

-(void) createCollectionToDisk:(NSString *) collectionName
{
    NSData * emptyCollectionFile = [[[[XoomlFragment alloc] initAsEmpty] toXmlString] dataUsingEncoding:NSUTF8StringEncoding];
    [self saveToDiskCollectionData:emptyCollectionFile
                     ForCollection:collectionName];
}

-(void) renameCollectionOnDisk:(NSString *) oldName to:(NSString *) newName
{
    NSString *oldDirectoryPath = [[FileSystemHelper getPathForCollectionWithName:oldName] stringByDeletingLastPathComponent];
    
    NSArray *tempArrayForContentsOfDirectory =[[NSFileManager defaultManager] contentsOfDirectoryAtPath:oldDirectoryPath error:nil];
    
    NSString *newDirectoryPath = [[oldDirectoryPath stringByDeletingLastPathComponent]stringByAppendingPathComponent:newName];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:newDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    for (int i = 0; i < [tempArrayForContentsOfDirectory count]; i++)
    {
        
        NSString *newFilePath = [newDirectoryPath stringByAppendingPathComponent:tempArrayForContentsOfDirectory[i]];
        
        NSString *oldFilePath = [oldDirectoryPath stringByAppendingPathComponent:tempArrayForContentsOfDirectory[i]];
        
        [[NSFileManager defaultManager] moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
    }
    [[NSFileManager defaultManager] removeItemAtPath:oldDirectoryPath error:&error];
}

-(void) deleteCollectionFromDisk:(NSString *)collectionName
{
    NSString * path = [[FileSystemHelper getPathForCollectionWithName:collectionName] stringByDeletingLastPathComponent];
    NSError * error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

-(NSData *) readCategoriesFromDisk
{
    NSString * path = [FileSystemHelper getPathForCategories];
    NSError * error;
    NSData * categoriesData =[NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
    return categoriesData;
}

-(void) writeCategoriesToDisk:(NSData *) categoriesData
{
    NSString * path = [FileSystemHelper getPathForCategories];
    [categoriesData writeToFile:path atomically:NO];
}

-(NSData *) getThumbnailFromDiskForCollection:(NSString *) collectionName
{
    NSString * path = [FileSystemHelper getPathForThumbnailForCollectionWithName:collectionName];
    NSData * result = [NSData dataWithContentsOfFile:path];
    return result;
}

-(void) saveThumbnailToDisk:(NSData *) imgData forCollection:(NSString *) collectionName
{
    NSString * path = [FileSystemHelper getPathForThumbnailForCollectionWithName:collectionName];
    [imgData writeToFile:path atomically:NO];
}

-(BOOL) saveToDiskCollectionAsset:(id<DiffableSerializableObject>) assetData
                     withFileName:(NSString *) fileName
                    forCollection:(NSString *) collectionName
{
    NSString * path = [FileSystemHelper getPathForCollectionAssetWithName:fileName
                                                    forCollectionWithName:collectionName];
    BOOL didSerialize = [assetData serializeToFile:path];
    if(!didSerialize)
    {
        NSLog(@"Failed to write the file");
    }
    return didSerialize;
}

- (BOOL) saveToDiskCollectionData:(NSData *) data
                    ForCollection:(NSString *) collectionName
{
    
    NSString * path = [FileSystemHelper getPathForCollectionWithName: collectionName];
    [FileSystemHelper createMissingDirectoryForPath:path];
    NSError * err;
    BOOL didWrite = [data writeToFile:path options:NSDataWritingAtomic error:&err];
    if(!didWrite)
    {
        NSLog(@"Failed to write the file to %@ because : %@", path, err);
    }
    return didWrite;
}

-(BOOL) saveToDiskAssociatedItemData:(NSData *) data
                       forCollection:(NSString *) collectionName
                   andAssociatedItem: (NSString *)associatedItemName
{
    NSString * path = [FileSystemHelper getPathForAssociatedItemWithName:associatedItemName
                                                    inCollectionWithName:collectionName];
    [FileSystemHelper createMissingDirectoryForPath:path];
    NSError * err;
    BOOL didWrite = [data writeToFile:path options:NSDataWritingAtomic error:&err];
    if(!didWrite)
    {
        
        NSLog(@"Failed to write the file to %@ because : %@", path, err);
    }
    return didWrite;
}

-(BOOL) saveToDiskAssociatedItemImageData:(NSData *) data
                            forCollection:(NSString *) collectionName
                        andAssociatedItem:(NSString *) associatedItemName
{
    NSString * path = [FileSystemHelper getPathForAssociatedItemImageforAssociatedItemName:associatedItemName
                                                                              inCollection:collectionName];
    
    NSError * err;
    BOOL didWrite = [data writeToFile:path options:NSDataWritingAtomic error:&err];
    if(!didWrite)
    {
        NSLog(@"Failed to write the file to %@ because : %@", path, err);
    }
    return didWrite;
}

-(BOOL) removeFromDiskAssociatedItem: (NSString *) associatedItemName
                      fromCollection: (NSString *) collectionName;
{
    BOOL result = [FileSystemHelper removeAssociation:associatedItemName fromCollection:collectionName];
    return result;
}

-(BOOL) removeFromDiskCollection:(NSString *) collectionName
{
    BOOL result = [FileSystemHelper removeCollection:collectionName];
    return result;
}

-(NSData *) getFromDiskAssociatedItem: (NSString *) associatedItemName fromCollection:(NSString *) collectionName
{
    
    NSString * path = [FileSystemHelper getPathForAssociatedItemWithName:associatedItemName inCollectionWithName:collectionName];
    NSError * err;
    NSString *data = [NSString stringWithContentsOfFile:path  encoding:NSUTF8StringEncoding error:&err];
    if (!data){
        NSLog(@"Failed to read associatedItem %@", err);
        NSLog(@"%@", path);
        return nil;
    }
    
    return [data dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSData *) getFromDiskAssociatedItemImageForAssociatedItem:(NSString *) associatedItem
                                              andCollection: (NSString *) collectionName
{
    
    NSString * path = [FileSystemHelper getPathForAssociatedItemImageforAssociatedItemName:associatedItem
                                                                              inCollection:collectionName];
    
    NSData * data = [NSData dataWithContentsOfFile:path];
    if (!data){
        return nil;
    }
    
    return data;
}

-(void) consolidateCache:(NSArray *) currentCollections
{
    NSSet * availableCollections = [NSSet setWithArray:currentCollections];
    NSArray * cachedCollections = [self getAllCollectionsFromDisk];
    for(NSString * collectionName in cachedCollections)
    {
        if (![availableCollections containsObject:collectionName])
        {
            [self deleteCollectionFromDisk:collectionName];
        }
    }
}
#pragma mark - Cached Object methods
-(void) refreshCacheForKey:(NSString *)collectionName
{
    self.collectionHasUpdatedCache[collectionName] = @NO;
    [self getCollectionFromServer:collectionName];
}

-(BOOL) cacheHasBeenUpdatedLocalyForKey:(NSString *)collectionName
{
    return self.collectionHasUpdatedCache[collectionName] ? YES: NO;
}

#pragma mark - NotificationHandler

-(void) associatedItemUpdatesReceivedForCollectionNamed: (NSString *) collectionName
                                     andAssociatedItems:(NSDictionary *) associatedItemDataMap
{
    
    for(NSString * associatedItemName in associatedItemDataMap)
    {
        NSString * associatedItemDataStr = associatedItemDataMap[associatedItemName];
        NSData * associatedItemData = [associatedItemDataStr dataUsingEncoding:NSUTF8StringEncoding];
        //first save it to disk
        [self saveToDiskAssociatedItemData:associatedItemData
                             forCollection:collectionName
                         andAssociatedItem:associatedItemName];
        
    }
    
    //send out a notification that the associatedItem is available to use
    NSDictionary * result = @{@"collectionName" : collectionName,
                              @"associatedItems" : associatedItemDataMap.allKeys};
    
    NSDictionary * userInfo = @{@"result" : result};
    [[NSNotificationCenter defaultCenter] postNotificationName:LISTENER_DOWNLOADED_ASSOCIATION
                                                        object:self
                                                      userInfo:userInfo];
}

-(void) associatedItemImageUpdateReceivedForCollectionName:(NSString *)collectionName
                                    andAssociatedItemNamed:(NSString *)associatedItemName
                               withAssociatedItemImageData:(NSData *)imageData
{
    [self saveToDiskAssociatedItemImageData:imageData
                              forCollection:collectionName
                          andAssociatedItem:associatedItemName];
    
    if (!self.collectionImagesCache[collectionName][associatedItemName])
    {
        if (!self.collectionImagesCache[collectionName])
        {
            self.collectionImagesCache[collectionName] = [NSMutableDictionary dictionary];
        }
        self.collectionImagesCache[collectionName][associatedItemName] = @YES;
    }
    
    NSDictionary * result = @{@"collectionName" : collectionName,
                              @"associatedItemName" : associatedItemName};
    
    NSDictionary * userInfo = @{@"result" : result};
    [[NSNotificationCenter defaultCenter] postNotificationName:LISTENER_DOWNLOADED_IMAGE
                                                        object:self
                                                      userInfo:userInfo];
}

-(void) associatedItemDeletesReceivedForCollectionName:(NSString *) collectionName
                                     andAssociatedItem:(NSDictionary *) associatedItemDataMap;
{
    for(NSString * associatedItemName in associatedItemDataMap)
    {
        [self removeFromDiskAssociatedItem:associatedItemName
                            fromCollection:collectionName];
    }
    
    NSDictionary * result = @{@"collectionName" : collectionName,
                              @"associatedItems" : associatedItemDataMap.allKeys};
    
    NSDictionary * userInfo = @{@"result" : result};
    [[NSNotificationCenter defaultCenter] postNotificationName:LISTENER_DELETED_ASSOCIATION
                                                        object:self
                                                      userInfo:userInfo];
}

-(void) collectionFragmentReceivedForCollectionName:(NSString *)collectionName
                                           withData:(NSData *) manifestData
{
    [self saveToDiskCollectionData:manifestData
                     ForCollection:collectionName];
    
    self.collectionHasUpdatedCache[collectionName] = @YES;
    NSDictionary * result = @{@"collectionName" : collectionName};
    
    NSDictionary * userInfo = @{@"result" : result};
    [[NSNotificationCenter defaultCenter] postNotificationName:LISTENER_DOWNLOADED_FRAGMENT
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - CollectionSharingAdapterDelegate
-(void) collectionFragmentGotUpdated:(NSString *)manifestContent
                       ForCollection:(NSString *)collectionName
{
    NSData * fragmentData =[manifestContent dataUsingEncoding:NSUTF8StringEncoding];
    [self collectionFragmentReceivedForCollectionName:collectionName
                                             withData:fragmentData];
}

-(void) associatedItemGotUpdated:(NSDictionary *)associatedItemUpdateDict
               forCollectionName:(NSString *)collectionName
{
    [self associatedItemUpdatesReceivedForCollectionNamed:collectionName andAssociatedItems:associatedItemUpdateDict];
}

-(void) associatedItemImagesGotUpdated:(NSDictionary *)associatedItemImagesDict
                     forCollectionName:(NSString *)collectionName
                     withSharingSecret:(NSString *) sharingSecret
                            andBaseURL:(NSString *) baseURL
{
    for(NSString * associatedItemName in associatedItemImagesDict)
    {
        NSString * imageKey = associatedItemImagesDict[associatedItemName];
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userID = [UserPropertiesHelper userID];
        NSString * associatedItemNameClosure = associatedItemName;
        [mindcloud getTempImageForUser:userID
                         andCollection:collectionName
                      andSubCollection:associatedItemName
                      andSharingSecret:sharingSecret
                        andImageSecret:imageKey
                            fromBaseUR:baseURL
                          withCallback:^(NSData * imgData){
                              NSLog(@"Received empty temp image");
                              if (imgData)
                              {
                                  NSLog(@"Received temp image for associatedItem %@", associatedItemName);
                                  [self associatedItemImageUpdateReceivedForCollectionName:collectionName
                                                                    andAssociatedItemNamed:associatedItemNameClosure
                                                               withAssociatedItemImageData:imgData];
                              }
                          }];
        
    }
}

-(void) associatedItemGotDeleted:(NSDictionary *)associatedItemDeleteDict
               forCollectionName:(NSString *)collectionName
{
    [self associatedItemDeletesReceivedForCollectionName:collectionName andAssociatedItem:associatedItemDeleteDict];
}

-(void) thumbnailGotUpdated:(NSString *) thumbnailPath
          forCollectionName:(NSString *) collectionName
          withSharingSecret:(NSString *) sharingSecret
                 andBaseURL:(NSString *) baseURL
{
    
    //we will figure out the thumbnail based on the actual associatedItem images that are received
    //no need for this
    //        Mindcloud * mindcloud = [Mindcloud getMindCloud];
    //        NSString * userID = [UserPropertiesHelper userID];
    //        [mindcloud getTempImageForUser:userID
    //                         andCollection:collectionName
    //                               andAssociatedItem:THUMBNAIL_NOTE_NAME_KEY
    //                      andSharingSecret:sharingSecret
    //                        andImageSecret:thumbnailPath
    //                            fromBaseUR:baseURL
    //                          withCallback:^(NSData * imgData){
    //                              if (imgData)
    //                              {
    //                              }
    //                          }];
    
}

@end
