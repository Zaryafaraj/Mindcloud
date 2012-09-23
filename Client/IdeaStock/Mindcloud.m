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

-(void) authorize: (NSString *) userId
{
    MindcloudBaseAction * action = [[AuthenticationAction alloc] initWithUserId:userId];
    [action execute];
}
@end
