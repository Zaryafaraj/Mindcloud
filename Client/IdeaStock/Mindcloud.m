//
//  Mindcloud.m
//  IdeaStock
//
//  Created by Ali Fathalian on 9/22/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "Mindcloud.h"
#import "AuthenticationAction.h"

@interface Mindcloud()

//This needs to be weak since we want the delegate to get deallocated whenver
//it wants
//TODO maybe this is not the best way to do this. Maybe this is bad design
@property (weak, nonatomic) id<AuthorizationDelegate> authenticationDelegate;

@end

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
     withDelegate:(id<AuthorizationDelegate>)delegate
{
    //set the delegate
    self.authenticationDelegate = delegate;
    //prepare the action
    MindcloudBaseAction * action = [[AuthenticationAction alloc] initWithUserId:userId
                                                                    andCallback:^(NSDictionary * results)
                                {
                                    NSString * accountStatus = results[ACCOUNT_STATUS_KEY];
                                    if ([accountStatus isEqualToString:UNAUTHORIZED_STATUS])
                                    {
                                        NSString * urlStr = results[AUTH_URL];
                                        urlStr = [urlStr stringByAppendingFormat:@"&oauth_callback=%@",MINDCLOUD_CALLBACK];
                                        [self.authenticationDelegate didFinishAuthorizing:userId andNeedsAuthenting:YES withURL:urlStr];
                                        //add a call back URL to switch back to app
                                        
                                    }
                                    else
                                    {
                                        NSLog(@"Account Already Auhtorized and ready to use");
                                        //no authentication step remains
                                        [delegate didFinishAuthorizing:userId andNeedsAuthenting:NO
                                                               withURL:nil];
                                        
                                    }
                                }];
                                    
    [action executeGET];
}

-(void) authorizationDone:(NSString *) userId
{
    MindcloudBaseAction * action = [[AuthenticationAction alloc] initWithUserId:userId
                                                                    andCallback:^(NSDictionary * results)
                                    {
                                        //if someone has registered to recieve notification
                                        //call them
                                        if (self.authenticationDelegate)
                                        {
                                        //we are done, no more steps needed
                                        [self.authenticationDelegate didFinishAuthorizing:userId andNeedsAuthenting:NO withURL:nil];
                                        }
                                        NSLog(@"Account Authorized and Saved in Mindcloud");
                                    }];
    
    [action executePOST];

}

-(void) getAllCollectionsFor:(NSString *)userId
                   WithCallback:(get_collections_callback)callback
{
    
    MindcloudBaseAction * action = [[AccountsAction alloc] initWithUserID:userId
                                                              andCallback:callback];
    [action executeGET];
}
@end
