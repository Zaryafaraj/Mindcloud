//
//  UserStatus.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/29/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "UserStatus.h"
#import "EventTypes.h"

@implementation UserStatus

+(UserStatus *) userStatus
{
    static UserStatus * currentStatus = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentStatus = [[UserStatus alloc] init];
    });
    return currentStatus;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        self.isUserOnline = YES;
        self.hasUserBeenNotifiedOfBeingOffline = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userIsOffline:)
                                                     name:USER_OFFLINE
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userIsOnline:)
                                                     name:USER_ONLINE
                                                   object:nil];
    }
    return self;
}


- (void) userIsOffline:(NSNotification *) notification
{
    self.isUserOnline = NO;
    self.hasUserBeenNotifiedOfBeingOffline = NO;
}

- (void) userIsOnline:(NSNotification *) notification
{
    self.isUserOnline = NO;
    self.hasUserBeenNotifiedOfBeingOffline = NO;
}
@end
