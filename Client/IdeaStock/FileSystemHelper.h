//
//  FileSystemHelper.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/7/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileSystemHelper : NSObject

+ (NSString *) getPathForAllCollections;

+ (NSString *) getPathForCategories;

+ (NSString *) getPathForCollectionWithName:(NSString *) collectionName;

+ (NSString *) getPathForSubCollectionWithName: (NSString *) subCollectionName inCollectionWithName: (NSString *) collectionName;

+ (NSString *) getPathForThumbnailForCollectionWithName:(NSString *) collectionName;

+ (void) createMissingDirectoryForPath: (NSString *) path;

+ (NSString *) getPathForSubCollectionImageforSubCollectionName: (NSString *) subCollectionName
                              inCollection: (NSString *) collectionName;

+ (BOOL) doesFileExist: (NSString *) path;

+ (BOOL) removeCollection:(NSString *) collectionName;

+ (BOOL) removeSubCollection:(NSString *) subCollectionName
     fromCollection:(NSString *) collectionName;

@end
