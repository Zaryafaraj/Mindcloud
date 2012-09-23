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

-(void) authorize: (NSString *) userId
{
    MindcloudBaseAction * action = [[AuthenticationAction alloc] initWithUserId:userId
                                                                    andCallback:^(NSDictionary * results)
                                    {
                                        NSString * accountStatus = [results objectForKey:ACCOUNT_STATUS_KEY];
                                        if ([accountStatus isEqualToString:UNAUTHORIZED_STATUS])
                                        {
                                            
                                        }
                                        else
                                        {
                                            NSLog(@"Account Auhtorized and ready to use");
                                        }
                                    }];
                                    
    [action execute];
}
@end
