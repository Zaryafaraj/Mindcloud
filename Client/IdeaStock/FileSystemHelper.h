//
//  FileSystemHelper.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/7/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileSystemHelper : NSObject

+ (NSString *) getPathForBulletinBoardWithName:(NSString *) bulletinBoardName;

+ (NSString *) getPathForNoteWithName: (NSString *) noteName inBulletinBoardWithName: (NSString *) bulletinBoardName;        

+ (void) createMissingDirectoryForPath: (NSString *) path;

+(NSString *) getPathForImageWithName: (NSString *) imgName
                          forNoteName: (NSString *) noteName
                      inBulletinBoard: (NSString *) bulletinBoardName;

+(BOOL) doesFileExist: (NSString *) path;

@end
