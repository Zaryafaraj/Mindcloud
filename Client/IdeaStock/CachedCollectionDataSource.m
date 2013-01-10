//
//  CachedCollectionDataModel.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/8/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CachedCollectionDataSource.h"
#import "FileSystemHelper.h"

//TODO make sure you create queue and then action in progress for each thing
@implementation CachedCollectionDataSource

- (void) addNote: (NSString *)noteName 
     withContent: (NSData *) note 
    ToCollection: (NSString *) collectionName
{
    
}

-(void) addImageNote: (NSString *) noteName
     withNoteContent: (NSData *) note 
            andImage: (NSData *) img 
   withImageFileName: (NSString *)imgName
     toCollection: (NSString *) collectionName;
{
    
}

-(void) updateCollectionWithName: (NSString *) collectionName
               andContent: (NSData *) content
{
    
}


-(void) updateNote: (NSString *) noteName 
       withContent: (NSData *) conetent
   inCollection:(NSString *) collectionName
{
    
}

- (void) removeNote: (NSString *) noteName
  FromCollection: (NSString *) collectionName
{
    
}


- (NSData *) getCollection: (NSString *) collectionName
{
    //Try to get the collection from disk
    
}

- (NSData *) getNoteForTheCollection: (NSString *) collectionName
                                   WithName: (NSString *) noteName
{
    return nil;
}

- (NSData *) getImage: (NSString *) imgName
              ForNote: (NSString *)noteID 
            andCollection: (NSString *) bulletinBoardName
{
    return nil;
}

-(NSData *) getCollectionFromDisk: (NSString *) collectionName{
    
    NSString * path = [FileSystemHelper getPathForCollectionWithName: collectionName];
    NSError * err;
    NSString *data = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    if (!data){
        NSLog(@"Failed to read file from disk: %@", err);
        return nil;
    }
    
    NSLog(@"BulletinBoard : %@ read successful", collectionName);
    
    return [data dataUsingEncoding:NSUTF8StringEncoding];
    
}

-(NSData *) getNoteDataForNote: (NSString *) noteName inCollection:(NSString *) collectionName{
    
    
    NSString * path = [FileSystemHelper getPathForNoteWithName:noteName inCollectionWithName:collectionName];
    NSError * err;
    NSString *data = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    if (!data){
        NSLog(@"Failed to read  note file from disk: %@", err);
        return nil;
    }
    
    NSLog(@"Note: %@ read Successful", noteName);
    
    return [data dataUsingEncoding:NSUTF8StringEncoding];
}
@end
