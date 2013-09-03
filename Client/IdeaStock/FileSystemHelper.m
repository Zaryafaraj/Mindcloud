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
#define COLLECTION_FILENAME @"collection.xml"
#define SUB_COLLECTION_FILENAME @"note.xml"
#define SUB_COLLECTION_IMG_FILENAME @"img.jpg"
#define CATEGORIES_FILENAME @"categories.xml"
#define THUMBNAIL_FILENAME @"thumbnail.jpg"

+(NSString *) getPathForAllCollections
{
    NSString * path = [NSHomeDirectory() stringByAppendingString:@"/Documents/Cache/"];
    [self createMissingDirectoryForPath:path];
    return path;
}

+(NSString *) getPathForCategories
{
    NSString * path = [NSHomeDirectory() stringByAppendingString:@"/Documents/Cache/"];
    path = [path stringByAppendingString:CATEGORIES_FILENAME];
    [self createMissingDirectoryForPath:path];
    return path;
}
+ (NSString *) getPathForCollectionWithName:(NSString *) collectionName{
    
    NSString * pathExtension = [[collectionName stringByAppendingString:@"/"]
                                stringByAppendingString:COLLECTION_FILENAME];
    
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
                       stringByAppendingString:THUMBNAIL_FILENAME];
    return path;
}
+ (NSString *) getPathForAssociatedItemWithName: (NSString *) subCollectionName
                 inCollectionWithName: (NSString *) collectionName{
    
    NSString * collectionPath = [collectionName stringByAppendingString:@"/"];
    NSString * noteExtension = [[[collectionPath stringByAppendingString:subCollectionName]
                                 stringByAppendingString:@"/"]
                                stringByAppendingString:SUB_COLLECTION_FILENAME];
    
    NSString * path = [[NSHomeDirectory() stringByAppendingString: @"/Documents/Cache/"]
                       stringByAppendingString:noteExtension];
    [self createMissingDirectoryForPath:path];
    return path;
}

+ (void) createMissingDirectoryForPath: (NSString *) path{
    
    NSString *lastComponent = [path lastPathComponent];
    BOOL isFile = NO;
    if ([lastComponent isEqualToString:COLLECTION_FILENAME] ||
        [lastComponent isEqualToString:SUB_COLLECTION_FILENAME] ||
        [lastComponent isEqualToString:CATEGORIES_FILENAME]){
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

+ (NSString *) getPathForAssociatedItemImageforAssociatedItemName: (NSString *) subCollectionName
                              inCollection: (NSString *) collectionName;
{
    NSString * imgPath = [FileSystemHelper getPathForAssociatedItemWithName:subCollectionName
                                             inCollectionWithName:collectionName];
    imgPath = [imgPath stringByDeletingLastPathComponent];
    [self createMissingDirectoryForPath:imgPath];
    imgPath = [imgPath stringByAppendingFormat:@"/%@",SUB_COLLECTION_IMG_FILENAME];
    
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

+ (BOOL) removeAssociation:(NSString *) subCollectionName
     fromCollection:(NSString *) collectionName
{
    NSString * notePath = [FileSystemHelper getPathForAssociatedItemWithName:subCollectionName
                                              inCollectionWithName:collectionName];
    NSError * err;
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:notePath error:&err];
    if (!result)
    {
        NSLog(@"Failed to remove note %@ from collection %@ from filesystem",subCollectionName, collectionName);
    }
    return result;
    
}

+(BOOL) doesFileExist:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

@end
