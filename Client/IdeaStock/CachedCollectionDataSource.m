//
//  CachedCollectionDataModel.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/8/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CachedCollectionDataSource.h"
#import "FileSystemHelper.h"
#import "Mindcloud.h"
#import "UserPropertiesHelper.h"
#import "EventTypes.h"

//TODO make sure you create queue and then action in progress for each thing
@implementation CachedCollectionDataSource

#pragma mark - Addition/Update

- (void) addNote: (NSString *)noteName
     withContent: (NSData *) note 
    ToCollection: (NSString *) collectionName
{
    
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
                        
                        NSLog(@"Updated Note %@ for Collection %@", noteName, collectionName);
    }];
}

-(void) addImageNote: (NSString *) noteName
     withNoteContent: (NSData *) note 
            andImage: (NSData *) img 
   withImageFileName: (NSString *)imgName
     toCollection: (NSString *) collectionName;
{
    [self saveToDiskNoteData:note
               forCollection:collectionName
                     andNote:noteName];
    
    [self saveToDiskNoteImageData:img
                    forCollection:collectionName
                          andNote:noteName];
    
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userID = [UserPropertiesHelper userID];
    [mindcloud updateNoteAndNoteImageForUser:userID forCollection:collectionName andNote:noteName withNoteData:note andImageData:img withCallback:^(void) {
                    NSLog(@"Updated Note img %@ for Collection %@", noteName, collectionName);
    }];
}

-(void) updateCollectionWithName: (NSString *) collectionName
               andContent: (NSData *) content
{
    [self saveToDiskCollectionData:content
                     ForCollection:collectionName];
    
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userID = [UserPropertiesHelper userID];
    [mindcloud updateCollectionManifestForUser:userID forCollection:collectionName withData:content withCallback:^(void){
        NSLog(@"Update Manifest for collection %@", collectionName);
    }];
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
    [self removeFromDiskNote:noteName fromCollection:collectionName];
    
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userID = [UserPropertiesHelper userID];
    
    [mindcloud deleteNoteForUser:userID forCollection:collectionName andNote:noteName withCallback:^(void){
        NSLog(@"Delete Note failed for note %@ and collection %@", noteName, collectionName);
    }];
}

#pragma mark retreival
- (NSData *) getCollection: (NSString *) collectionName
{
    NSData * cachedData = [self getCollectionFromDisk:collectionName];
    //whatever is cached we try to retreive the collection again
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userID = [UserPropertiesHelper userID];
    [mindcloud getCollectionManifestForUser:userID
                              forCollection:collectionName
                               withCallback:^(NSData * collectionData){
                                   if (collectionData)
                                   {
                                       
                                        BOOL didWrite = [self saveToDiskCollectionData:collectionData
                                                                       ForCollection:collectionName];
                                        //get the rest of the notes
                                        if (didWrite)
                                        {
                                        [self getAllNotes:collectionName];
                                        }
                                    }
                               }];
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
           [self downloadComplete];
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
                               
                               BOOL didWrite = [self saveToDiskNoteImageData:noteData
                                                          forCollection:collectionName
                                                                andNote:noteName];
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
            [self downloadComplete];
        }
    }
    
}

-(void) downloadComplete
{
    NSLog(@"Download Completed");
    //tell the notification center that download has been completed
    [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTION_DOWNLOADED_EVENT
                                                        object:self];
    
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

- (BOOL) saveToDiskCollectionData:(NSData *) data
                     ForCollection:(NSString *) collectionName
{
    
    NSString * path = [FileSystemHelper getPathForCollectionWithName: collectionName];
    [FileSystemHelper createMissingDirectoryForPath:path];
    BOOL didWrite = [data writeToFile:path atomically:NO];
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
    
    BOOL didWrite = [data writeToFile:path atomically:NO];
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
    
    BOOL didWrite = [data writeToFile:path atomically:NO];
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
    NSString *data = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    if (!data){
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

@end
