//
//  UserPropertiesHelper.m
//  IdeaStock
//
//  Created by Ali Fathalian on 9/22/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "UserPropertiesHelper.h"
#import "FileSystemHelper.h"
#import "StringUtils.h"

@implementation UserPropertiesHelper

static NSString * user_id;

#define PROPERTIES_LIST_PATH @"user.plist"
#define USER_ID_KEY @"userID"

+(NSString *) getUserPropertiesListPath
{
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES)[0];
    NSString * plistPath = [rootPath stringByAppendingPathComponent:PROPERTIES_LIST_PATH];
    return plistPath;
    
}
+(NSString *) userID{
    
    //if userID has been cached befoer then just return it
    if (user_id) return user_id;
    
    NSString * propertiesListPath = [self getUserPropertiesListPath];
    NSDictionary * userInfo;
    if ([FileSystemHelper doesFileExist:propertiesListPath])
    {
        //first lunch of the app
        userInfo = [NSDictionary dictionaryWithContentsOfFile: propertiesListPath];
        user_id = userInfo[USER_ID_KEY];
        return user_id;
    }
    else
    {
        user_id = [StringUtils generateUUID];
        NSDictionary * userInfo = @{USER_ID_KEY: user_id};
        BOOL didWrite = [userInfo writeToFile:propertiesListPath atomically:YES];
        if(didWrite) NSLog(@"Wrote the plist");
        return user_id;
    }
}

@end
