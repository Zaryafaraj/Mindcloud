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
#define NOTE_IMG_FILE_NAME @"note.jpg"

+ (NSString *) getPathForCollectionWithName:(NSString *) collectionName{
    
    NSString * pathExtension = [[collectionName stringByAppendingString:@"/"]
                                stringByAppendingString:BULLETINBOARD_XOOML_FILE_NAME];
    
    pathExtension = [pathExtension lowercaseString];
    NSString *path = [[NSHomeDirectory() stringByAppendingString:@"/Documents/"]
                      stringByAppendingString:pathExtension];
    return path;
}

+ (NSString *) getPathForNoteWithName: (NSString *) noteName
                 inCollectionWithName: (NSString *) collectionName{
    
    NSString * bulletinBoardPath = [collectionName stringByAppendingString:@"/"];
    NSString * noteExtension = [[[bulletinBoardPath stringByAppendingString:noteName]
                                 stringByAppendingString:@"/"]
                                stringByAppendingString:NOTE_XOOML_FILE_NAME];
    
    noteExtension = [noteExtension lowercaseString];
    NSString * path = [[NSHomeDirectory() stringByAppendingString: @"/Documents/"]
                       stringByAppendingString:noteExtension];
    return path;
}

+ (void) createMissingDirectoryForPath: (NSString *) path{
    
    NSString *lastComponent = [path lastPathComponent];
    BOOL isFile = NO;
    if ([lastComponent isEqualToString:BULLETINBOARD_XOOML_FILE_NAME] ||
        [lastComponent isEqualToString:NOTE_XOOML_FILE_NAME]){
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
            if ([dir isEqualToString:directoryName] || [dir isEqualToString:[directoryName lowercaseString]]){
                
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
    imgPath = [imgPath stringByAppendingFormat:@"/%@",NOTE_IMG_FILE_NAME];
    
    return imgPath;
}

+(BOOL) doesFileExist:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

@end
