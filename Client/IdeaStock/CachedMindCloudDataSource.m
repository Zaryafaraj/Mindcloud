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
#import "XoomlCategoryParser.h"

@interface CachedMindCloudDataSource()
//we make sure that we don't send out an action before another action of the same type on the same
//resource is in progress, because of unreliable TCP/IP the second action might reach the server faster
//and we want to avoid it.
//These indicate whether an action is being in progress
@property NSMutableDictionary * inProgressNoteUpdates;
@property NSMutableDictionary * inProgressNoteImageUpdates;
@property BOOL manifestUpdateInProgress;
//dictionaries keyed on the note name and valued on noteData that contain the last update note
//that is waiting. In case a new one comes in while the note update is in progress it just replaces
//the old one
@property NSMutableDictionary * noteUpdateQueue;
@property NSMutableDictionary * noteImageUpdateQueue;
@property NSMutableDictionary * waitingDeleteNotes;
@property NSData * waitingUpdateManifestData;
@property NSMutableDictionary * hasCachedVersion;

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
    self.inProgressNoteImageUpdates = [NSMutableDictionary dictionary];
    self.inProgressNoteUpdates = [NSMutableDictionary dictionary];
    self.noteImageUpdateQueue = [NSMutableDictionary dictionary];
    self.noteUpdateQueue = [NSMutableDictionary dictionary];
    self.hasCachedVersion = [NSMutableDictionary dictionary];
    return self;
}

-(NSArray *) getAllCollections
{
    
    //try cache
    NSMutableArray * tempAnswer = [[self getAllCollectionsFromDisk] mutableCopy];
    //for debugging on a mac
    [tempAnswer removeObject:@".DS_Store"];
    [tempAnswer removeObject:@"categories.xml"];
    //return an immutable object
    tempAnswer = [tempAnswer copy];
    //in any case do another refresh
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    [mindcloud getAllCollectionsFor:userId
                       WithCallback:^(NSArray * collection)
     {
         for (NSString * collectionName in collection)
         {
             [self createCollectionToDisk:collectionName];
         }
         [[NSNotificationCenter defaultCenter] postNotificationName:ALL_COLLECTIONS_LIST_DOWNLOADED_EVENT
                                                             object:self
                                                           userInfo:@{@"result" : collection}];
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
    [mindcloud deleteCollectionFor:userId
                          withName:collectionName
                      withCallback:^{
                          //NSLog(@"Collection %@ Deleted", collectionName);
                      }];
    [self deleteCollectionFromDisk:collectionName];
}

-(NSDictionary *) getCategories
{
    NSData * categoriesData = [self readCategoriesFromDisk];
    NSDictionary * categoriesDict = [XoomlCategoryParser deserializeXooml:categoriesData];
    //return the cached one and update the cache
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    [mindcloud getCategories:userId withCallback:^(NSData * categories)
     {
         if (categories)
         {
             NSLog(@"Categories Retrieved");
             NSDictionary * dict = [XoomlCategoryParser deserializeXooml:categories];
             [[NSNotificationCenter defaultCenter] postNotificationName:CATEGORIES_RECEIVED_EVENT
                                                                 object:self
                                                               userInfo:@{@"result" : dict}];
             [self writeCategoriesToDisk:categories];
         }
         else{
             NSLog(@"No Categories Received");
         }
     }];
    return categoriesDict;
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

-(NSData *) getThumbnailForCollection:(NSString *) collectionName
{
    
    NSData * thumbnailData = [self getThumbnailFromDiskForCollection:collectionName];
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userID = [UserPropertiesHelper userID];
    [mindcloud getPreviewImageForUser:userID
                        forCollection:collectionName
                         withCallback:^(NSData * imgData){
                             
                             NSDictionary * userDict;
                             if (imgData)
                             {
                                 [self saveThumbnailToDisk:imgData forCollection:collectionName];
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
                             [[NSNotificationCenter defaultCenter] postNotificationName:THUMBNAIL_RECEIVED_EVENT
                                                                                 object:self
                                                                               userInfo:userDict];
                             //in any case send out the notification
                         }];
    return thumbnailData;
 }

-(void) setThumbnail:(NSData *)thumbnailData
          forCollection:(NSString *)collectionName
{
    
    [self saveThumbnailToDisk:thumbnailData forCollection:collectionName];
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userID = [UserPropertiesHelper userID];
    [mindcloud setPreviewImageForUser:userID
                        forCollection:collectionName
                         andImageData:thumbnailData
                         withCallback:^(void){
                             ;
    }];
}
#pragma mark - Addition/Update

- (void) addNote: (NSString *)noteName
     withContent: (NSData *) note 
    ToCollection: (NSString *) collectionName
{
    
    //If there was a plan to delete this note just cancel it
    if (self.waitingDeleteNotes[noteName])
    {
        self.waitingDeleteNotes[noteName] = @NO;
    }
    
    if (self.inProgressNoteUpdates[noteName])
    {
        self.noteUpdateQueue[noteName] = note;
        return;
    }
    
    else
    {
        self.inProgressNoteUpdates[noteName] = @YES;
        
        [self saveToDiskNoteData:note
                   forCollection:collectionName
                         andNote:noteName];
    
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userID = [UserPropertiesHelper userID];
        [mindcloud updateNoteForUser:userID
                       forCollection:collectionName
                             andNote:noteName
                            withData:note
                        withCallback:^(void){
                            self.inProgressNoteUpdates[noteName] = @NO;
                            NSLog(@"Updated Note %@ for Collection %@", noteName, collectionName);
                            
                            if (self.waitingDeleteNotes[noteName])
                            {
                                [self removeNote:noteName FromCollection:collectionName];
                            }
                            else if (self.noteUpdateQueue[noteName])
                            {
                                NSData * latestNoteData = self.noteUpdateQueue[noteName];
                                [self.noteUpdateQueue removeObjectForKey:noteName];
                                
                                [self addNote:noteName
                                  withContent:latestNoteData
                                 ToCollection:collectionName];
                            }
        }];
        
    }
}

-(void) addImageNote: (NSString *) noteName
     withNoteContent: (NSData *) note 
            andImage: (NSData *) img 
   withImageFileName: (NSString *)imgName
     toCollection: (NSString *) collectionName;
{
    //If there was a plan to delete this note just cancel it
    if (self.waitingDeleteNotes[noteName])
    {
        self.waitingDeleteNotes[noteName] = @NO;
    }
    
    if (self.inProgressNoteImageUpdates[noteName])
    {
        self.noteImageUpdateQueue[noteName] = note;
        self.noteUpdateQueue[noteName] = img;
    }
    else
    {
        self.inProgressNoteImageUpdates[noteName] = @YES;
        
        [self saveToDiskNoteData:note
                   forCollection:collectionName
                         andNote:noteName];
        
        [self saveToDiskNoteImageData:img
                        forCollection:collectionName
                              andNote:noteName];
        
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userID = [UserPropertiesHelper userID];
        [mindcloud updateNoteAndNoteImageForUser:userID
                                   forCollection:collectionName
                                         andNote:noteName
                                    withNoteData:note
                                    andImageData:img
                                    withCallback:^(void) {
                                        
                                    self.inProgressNoteImageUpdates[noteName] = @NO;
                                        NSLog(@"Updated Note img %@ for Collection %@", noteName, collectionName);
                                        
                                        if (self.waitingDeleteNotes[noteName])
                                        {
                                            [self removeNote:noteName FromCollection:collectionName];
                                        }
                                        else if (self.noteUpdateQueue[noteName] && self.noteImageUpdateQueue[noteName])
                                        {
                                            NSData * latestImg = self.noteImageUpdateQueue[noteName];
                                            NSData * latestNote = self.noteUpdateQueue[noteName];
                                            [self.noteUpdateQueue removeObjectForKey:noteName];
                                            [self.noteImageUpdateQueue removeObjectForKey:noteName];
                                            [self addImageNote:noteName
                                               withNoteContent:latestNote
                                                      andImage:latestImg
                                             withImageFileName:@"note.jpg"
                                                  toCollection:collectionName];
                                        }
        }];
    }
}

-(void) updateCollectionWithName: (NSString *) collectionName
               andContent: (NSData *) content
{
    if ([content length] == 0)
    {
        return;
    }
    
    if (self.manifestUpdateInProgress)
    {
        self.waitingUpdateManifestData = content;
    }
    else
    {
        self.manifestUpdateInProgress = YES;
        
        [self saveToDiskCollectionData:content
                         ForCollection:collectionName];
        
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userID = [UserPropertiesHelper userID];
        [mindcloud updateCollectionManifestForUser:userID forCollection:collectionName withData:content withCallback:^(void){
            self.manifestUpdateInProgress = NO;
            NSLog(@"Update Manifest for collection %@", collectionName);
            if (self.waitingUpdateManifestData)
            {
                NSData * latestData = self.waitingUpdateManifestData;
                self.waitingUpdateManifestData = nil;
                [self updateCollectionWithName:collectionName andContent:latestData];
            }
        }];
    }
}

-(void) updateNote: (NSString *) noteName 
       withContent: (NSData *) content
   inCollection:(NSString *) collectionName
{
    [self addNote:noteName withContent:content ToCollection:collectionName];
}

- (void) removeNote: (NSString *) noteName
  FromCollection: (NSString *) collectionName
{
    //we don't possibly want the delete to reach the server before the add. In that case it will get deleted and added again
    if (self.inProgressNoteImageUpdates[noteName] || self.inProgressNoteUpdates[noteName])
    {
        self.waitingDeleteNotes[noteName] = @YES;
        //if there were prior actions that wait to be performed on the deleted note just cancel them
        if (self.noteImageUpdateQueue[noteName])
        {
            [self.noteImageUpdateQueue removeObjectForKey:noteName];
        }
        if (self.noteUpdateQueue[noteName])
        {
            [self.noteUpdateQueue removeObjectForKey:noteName];
        }
    }
    else
    {
        [self removeFromDiskNote:noteName fromCollection:collectionName];
        
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userID = [UserPropertiesHelper userID];
        
        [mindcloud deleteNoteForUser:userID forCollection:collectionName andNote:noteName withCallback:^(void){
            NSLog(@"Deleted Note %@ in collection %@", noteName, collectionName);
        }];
    }
}


#pragma mark retreival
- (NSData *) getCollection: (NSString *) collectionName
{
    NSData * cachedData = [self getCollectionFromDisk:collectionName];
    if (!self.hasCachedVersion[collectionName])
    {
        //whatever is cached we try to retreive the collection again
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userID = [UserPropertiesHelper userID];
        [NetworkActivityHelper addActivityInProgress];
        [mindcloud getCollectionManifestForUser:userID
                                  forCollection:collectionName
                                   withCallback:^(NSData * collectionData){
                                       if (collectionData)
                                       {
                                           
                                          NSLog(@"Collection Retreived");
                                           BOOL didWrite = [self saveToDiskCollectionData:collectionData
                                                                           ForCollection:collectionName];
                                            //get the rest of the notes
                                            if (didWrite)
                                            {
                                            [self getAllNotes:collectionName];
                                            }
                                        }
                                   }];
    }
    return cachedData;
}

- (void) getAllNotes:(NSString *) collectionName
{
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userID = [UserPropertiesHelper userID];
    [mindcloud getAllNotesForUser:userID
                    forCollection:collectionName
                     withCallback:^(NSArray * allNotes){
                               int index = 0;
                               [self getRemainingNoteAtIndex: index
                                                   fromArray: allNotes
                                               forCollection: collectionName
                                                 chainImages:YES ];
    }];
    
}

-(void) getRemainingNoteAtIndex:(int) index
                      fromArray:(NSArray *) allNotes
                  forCollection:(NSString *) collectionName
                    chainImages:(BOOL) chain
{
   if (index < [allNotes count])
   {
       
       Mindcloud * mindcloud = [Mindcloud getMindCloud];
       NSString * userID = [UserPropertiesHelper userID];
       NSString * noteName = allNotes[index];
       index++;
       [mindcloud getNoteManifestforUser:userID
                                 forNote:noteName
                          fromCollection:collectionName withCallback:^(NSData * noteData){
                              
                              BOOL didWrite = [self saveToDiskNoteData:noteData
                                                         forCollection:collectionName
                                                               andNote:noteName];
                              if (didWrite)
                              {
                                  [self getRemainingNoteAtIndex:index
                                                      fromArray:allNotes
                                                  forCollection:collectionName
                                                    chainImages:chain];
                              }
                              
       }];
       
   }
   else
   {
       if (chain)
       {
           [self getRemainingNoteImagesAtIndex:0
                                     fromArray:allNotes
                                 forCollection:collectionName
                                    chainNotes:!chain];
       }
       else
       {
           [self downloadComplete:collectionName];
       }
   }
}

-(void) getRemainingNoteImagesAtIndex: (int) index
                            fromArray: (NSArray *) allNotes
    forCollection:(NSString *) collectionName
                           chainNotes: (BOOL) chain
{
    if (index < [allNotes count])
    {
        
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userID = [UserPropertiesHelper userID];
        NSString * noteName = allNotes[index];
        index++;
        [mindcloud getNoteImageForUser:userID
                                  forNote:noteName
                           fromCollection:collectionName withCallback:^(NSData * noteData){
                               
                               BOOL didWrite = YES;
                               if (noteData)
                               {
                                   didWrite = [self saveToDiskNoteImageData:noteData
                                                              forCollection:collectionName
                                                                    andNote:noteName];
                               }
                               //if there is no data there is nothing to write so continue
                               if (didWrite)
                               {
                                   [self getRemainingNoteImagesAtIndex:index
                                                             fromArray:allNotes
                                                         forCollection:collectionName
                                                            chainNotes:chain];
                               }
                           }];
    }
    else
    {
        if (chain)
        {
            [self getRemainingNoteAtIndex:0
                                fromArray:allNotes
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
    self.hasCachedVersion[collectionName] = @YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTION_DOWNLOADED_EVENT
                                                        object:self];
    [NetworkActivityHelper removeActivityInProgress];
    
}

- (NSData *) getNoteForTheCollection: (NSString *) collectionName
                                   WithName: (NSString *) noteName
{
    //it is always assumed that the this method is called after a get collection which caches everything
    //so if we get a cache hit we trust that its most uptodate
    NSData * noteData = [self getFromDiskNote:noteName fromCollection:collectionName];
    if (!noteData)
    {
        NSLog(@"Could not get Retreive note data from cache, refresh the cache by getting the collection again");
        return nil;
    }
    else
    {
        return noteData;
    }
}

- (NSData *) getImage: (NSString *) imgName
              ForNote: (NSString *) noteName
        andCollection: (NSString *) collectionName;
{
    NSData * imgData = [self getFromDiskNoteImageForNote:noteName andCollection: collectionName];
    if (!imgData)
    {
        
        NSLog(@"Could not get Retreive note data from cache, refresh the cache by getting the collection again");
        return nil;
    }
    else
    {
        return imgData;
    }
}

#pragma mark - Disk Cache helpers

-(NSArray *) getAllCollectionsFromDisk
{
    NSString * path = [FileSystemHelper getPathForAllCollections];
    NSError * err;
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&err];
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
    
    NSLog(@"BulletinBoard : %@ read from disk", collectionName);
    
    return [data dataUsingEncoding:NSUTF8StringEncoding];
}

-(void) createCollectionToDisk:(NSString *) collectionName
{
    NSString * path = [[FileSystemHelper getPathForCollectionWithName:collectionName] stringByDeletingLastPathComponent];
    [FileSystemHelper createMissingDirectoryForPath:path];
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
        
        NSString *newFilePath = [newDirectoryPath stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];
        
        NSString *oldFilePath = [oldDirectoryPath stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];
        
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
- (BOOL) saveToDiskCollectionData:(NSData *) data
                     ForCollection:(NSString *) collectionName
{
    
    NSString * path = [FileSystemHelper getPathForCollectionWithName: collectionName];
    [FileSystemHelper createMissingDirectoryForPath:path];
    NSError * err;
    BOOL didWrite = [data writeToFile:path options:NSDataWritingAtomic error:&err];
    if(!didWrite)
    {
        NSLog(@"Failed to write the file to %@", path);
    }
    return didWrite;
}

-(BOOL) saveToDiskNoteData:(NSData *) data
             forCollection:(NSString *) collectionName
                   andNote: (NSString *)noteName
{
    NSString * path = [FileSystemHelper getPathForNoteWithName:noteName
                                          inCollectionWithName:collectionName];
    [FileSystemHelper createMissingDirectoryForPath:path];
    NSError * err;
    BOOL didWrite = [data writeToFile:path options:NSDataWritingAtomic error:&err];
    if(!didWrite)
    {
        NSLog(@"Failed to write the file to %@", path);
    }
    return didWrite;
}

-(BOOL) saveToDiskNoteImageData:(NSData *) data
                  forCollection:(NSString *) collectionName
                        andNote:(NSString *) noteName
{
    NSString * path = [FileSystemHelper getPathForNoteImageforNoteName:noteName
                                                       inBulletinBoard:collectionName];
    [FileSystemHelper createMissingDirectoryForPath:path];
    
    NSError * err;
    BOOL didWrite = [data writeToFile:path options:NSDataWritingAtomic error:&err];
    if(!didWrite)
    {
        NSLog(@"Failed to write the file to %@", path);
    }
    return didWrite;
}

-(BOOL) removeFromDiskNote: (NSString *) noteName
            fromCollection: (NSString *) collectionName;
{
    BOOL result = [FileSystemHelper removeNote:noteName fromCollection:collectionName];
    return result;
}

-(BOOL) removeFromDiskCollection:(NSString *) collectionName
{
    BOOL result = [FileSystemHelper removeCollection:collectionName];
    return result;
}

-(NSData *) getFromDiskNote: (NSString *) noteName fromCollection:(NSString *) collectionName
{
    
    NSString * path = [FileSystemHelper getPathForNoteWithName:noteName inCollectionWithName:collectionName];
    NSError * err;
    NSString *data = [NSString stringWithContentsOfFile:path  encoding:NSUTF8StringEncoding error:&err];
    if (!data){
        NSLog(@"Failed to read note %@", err);
        NSLog(@"%@", path);
        return nil;
    }
    
    NSLog(@"Note: %@ read from disk", noteName);
    
    return [data dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSData *) getFromDiskNoteImageForNote:(NSString *) noteName
                          andCollection: (NSString *) collectionName
{
    
    NSString * path = [FileSystemHelper getPathForNoteImageforNoteName:noteName
                                                       inBulletinBoard:collectionName];
    
    NSData * data = [NSData dataWithContentsOfFile:path];
    if (!data){
        return nil;
    }
    
    NSLog(@"Note img: %@ read from disk", noteName);
    
    return data;
}

#pragma mark - Cached Object methods

-(void) refreshCacheForKey:(NSString *)collectionName
{
    self.hasCachedVersion[collectionName] = @NO;
    [self getCollection:collectionName];
}



@end
