//
//  FileSystemHelper.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/7/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileSystemHelper : NSObject

+ (NSString *) getPathForCollectionWithName:(NSString *) collectionName;

+ (NSString *) getPathForNoteWithName: (NSString *) noteName inCollectionWithName: (NSString *) bulletinBoardName;        

+ (void) createMissingDirectoryForPath: (NSString *) path;

+ (NSString *) getPathForNoteImageforNoteName: (NSString *) noteName
                              inBulletinBoard: (NSString *) bulletinBoardName;

+ (BOOL) doesFileExist: (NSString *) path;

+ (BOOL) removeCollection:(NSString *) collectionName;

+ (BOOL) removeNote:(NSString *) noteName
     fromCollection:(NSString *) collectionName;

@end
