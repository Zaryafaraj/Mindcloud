//
//  FileSystemHelper.m
//  IdeaStock
//
//  Created by Ali Fathalian on 4/7/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "FileSystemHelper.h"

@implementation FileSystemHelper

//files are saved in lowercase
#define BULLETINBOARD_XOOML_FILE_NAME @"collection.xml"
#define NOTE_XOOML_FILE_NAME @"note.xml"
#define NOTE_IMG_FILE_NAME @"img.jpg"
#define CATEGORIES_FILE_NAME @"categories.xml"
#define THUMBNAIL_FILE_NAME @"thumbnail.jpg"

+(NSString *) getPathForAllCollections
{
    NSString * path = [NSHomeDirectory() stringByAppendingString:@"/Documents/Cache/"];
    [self createMissingDirectoryForPath:path];
    return path;
}

+(NSString *) getPathForCategories
{
    NSString * path = [NSHomeDirectory() stringByAppendingString:@"/Documents/Cache/"];
    path = [path stringByAppendingString:CATEGORIES_FILE_NAME];
    [self createMissingDirectoryForPath:path];
    return path;
}
+ (NSString *) getPathForCollectionWithName:(NSString *) collectionName{
    
    NSString * pathExtension = [[collectionName stringByAppendingString:@"/"]
                                stringByAppendingString:BULLETINBOARD_XOOML_FILE_NAME];
    
    NSString *path = [[NSHomeDirectory() stringByAppendingString:@"/Documents/Cache/"]
                      stringByAppendingString:pathExtension];
    [self createMissingDirectoryForPath:path];
    return path;
}

+ (NSString *) getPathForThumbnailForCollectionWithName:(NSString *) collectionName
{
    NSString * pathExtension = [collectionName stringByAppendingString:@"/"];
    NSString * path = [[[NSHomeDirectory() stringByAppendingString:@"/Documents/Cache/"]
                       stringByAppendingString:pathExtension]
                       stringByAppendingString:THUMBNAIL_FILE_NAME];
    return path;
}
+ (NSString *) getPathForNoteWithName: (NSString *) noteName
                 inCollectionWithName: (NSString *) collectionName{
    
    NSString * bulletinBoardPath = [collectionName stringByAppendingString:@"/"];
    NSString * noteExtension = [[[bulletinBoardPath stringByAppendingString:noteName]
                                 stringByAppendingString:@"/"]
                                stringByAppendingString:NOTE_XOOML_FILE_NAME];
    
    NSString * path = [[NSHomeDirectory() stringByAppendingString: @"/Documents/Cache/"]
                       stringByAppendingString:noteExtension];
    [self createMissingDirectoryForPath:path];
    return path;
}

+ (void) createMissingDirectoryForPath: (NSString *) path{
    
    NSString *lastComponent = [path lastPathComponent];
    BOOL isFile = NO;
    if ([lastComponent isEqualToString:BULLETINBOARD_XOOML_FILE_NAME] ||
        [lastComponent isEqualToString:NOTE_XOOML_FILE_NAME] ||
        [lastComponent isEqualToString:CATEGORIES_FILE_NAME]){
        isFile = true;;
    }
    
    NSString * directory = path;
    
    if (isFile){
        directory = [path stringByDeletingLastPathComponent];
    }

    NSString * directoryName = [directory lastPathComponent];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * err;
    //check to see if directory exists
    NSString * root = [directory stringByDeletingLastPathComponent];
    NSArray * rootDirectories = [fileManager contentsOfDirectoryAtPath:root  error:&err];
    BOOL shouldCreateDirectory = YES;
    if (rootDirectories){
        for (NSString * dir in rootDirectories){
            if ([dir isEqualToString:directoryName] || [dir isEqualToString:directoryName]){
                
                shouldCreateDirectory =NO;
                break;
            }
        }
    }
    if (shouldCreateDirectory){
        
        BOOL didCreate = [fileManager createDirectoryAtPath:directory
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error: &err];
        if(!didCreate){
            NSLog(@"Failed To create Direcjtory: %@",err);
        }
    }
}

+ (NSString *) getPathForNoteImageforNoteName: (NSString *) noteName
                              inBulletinBoard: (NSString *) bulletinBoardName;
{
    NSString * imgPath = [FileSystemHelper getPathForNoteWithName:noteName
                                             inCollectionWithName:bulletinBoardName];
    imgPath = [imgPath stringByDeletingLastPathComponent];
    [self createMissingDirectoryForPath:imgPath];
    imgPath = [imgPath stringByAppendingFormat:@"/%@",NOTE_IMG_FILE_NAME];
    
    return imgPath;
}



+(BOOL) removeCollection:(NSString *) collectionName
{
    NSString * collectionPath = [FileSystemHelper getPathForCollectionWithName:collectionName];
    NSError * err;
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:collectionPath error:&err];
    if (!result)
    {
        NSLog(@"Failed to remove collection %@ from filesystem", collectionName);
    }
    return result;
}

+ (BOOL) removeNote:(NSString *) noteName
     fromCollection:(NSString *) collectionName
{
    NSString * notePath = [FileSystemHelper getPathForNoteWithName:noteName
                                              inCollectionWithName:collectionName];
    NSError * err;
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:notePath error:&err];
    if (!result)
    {
        NSLog(@"Failed to remove note %@ from collection %@ from filesystem",noteName, collectionName);
    }
    return result;
    
}

+(BOOL) doesFileExist:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

@end
