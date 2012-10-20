//
//  Mindcloud.m
//  IdeaStock
//
//  Created by Ali Fathalian on 9/22/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "Mindcloud.h"
#import "AuthenticationAction.h"

@implementation Mindcloud

static Mindcloud * instance;

+ (Mindcloud *) getMindCloud
{
    if (!instance)
    {
        instance = [[Mindcloud alloc] init];
    }
    return instance;
}

#define ACCOUNT_STATUS_KEY @"account_status"
#define UNAUTHORIZED_STATUS @"unauthorized"
#define AUTHORIZED_STATUS @"authorized"
#define AUTH_URL @"url"
#define MINDCLOUD_CALLBACK @"mindcloud://done"

/**
 Send an authorize request to mindcloud server. If unauthorized get redirected to the dropbox sign in page 
 and then switch back to the app. 
 If authorized do nothing.
 */

-(void) authorize: (NSString *) userId
{
    MindcloudBaseAction * action = [[AuthenticationAction alloc] initWithUserId:userId
                                                                    andCallback:^(NSDictionary * results)
                                {
                                    NSString * accountStatus = [results objectForKey:ACCOUNT_STATUS_KEY];
                                    if ([accountStatus isEqualToString:UNAUTHORIZED_STATUS])
                                    {
                                        NSString * urlStr = [results objectForKey:AUTH_URL];
                                        urlStr = [urlStr stringByAppendingFormat:@"&oauth_callback=%@",MINDCLOUD_CALLBACK];
                                        //add a call back URL to switch back to app
                                        
                                        //open safari with the link to dropbox signin page
                                        //The call back after user signs in is in the appDelegate.m class
                                        NSURL * url = [NSURL URLWithString:urlStr];
                                        [[UIApplication sharedApplication] openURL:url];
                                    }
                                    else
                                    {
                                        NSLog(@"Account Already Auhtorized and ready to use");
                                    }
                                }];
                                    
    [action executeGET];
}

-(void) authorizationDone:(NSString *) userId
{
    MindcloudBaseAction * action = [[AuthenticationAction alloc] initWithUserId:userId
                                                                    andCallback:^(NSDictionary * results)
                                    {
                                        NSLog(@"Account Authorized and Saved in Mindcloud");
                                    }];
    
    [action executePOST];

}

-(void) getAllBulletinBoardsFor:(NSString *)userId
                   WithCallback:(get_collections_callback)callback
{
    
    MindcloudBaseAction * action = [[AccountsAction alloc] initWithUserID:userId
                                                              andCallback:callback];
    [action executeGET];
}
@end
