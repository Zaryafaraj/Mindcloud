//
//  MindcloudAuthenticator.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/29/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudAuthenticator.h"
#import "MindcloudAuthenticationGordon.h"
#import "UserPropertiesHelper.h"

@interface MindcloudAuthenticator()

@property(nonatomic, strong) MindcloudAuthenticationGordon * gordon;

@end

@implementation MindcloudAuthenticator

-(id) init
{
    self = [super init];
    NSString * userID = [UserPropertiesHelper userID];
    self.gordon = [[MindcloudAuthenticationGordon alloc] initWithUserId:userID
                                                            andDelegate:self];
    return self;
}

- (void) authorizeUser
{
    NSString * userID = [UserPropertiesHelper userID];
    [self.gordon authorizeUser:userID];
}

- (void) authenticateUser
{
    //open safari with the link to dropbox signin page
    //The call back after user signs in is in the appDelegate.m class
    if ([self.gordon authenticationURL])
    {
        NSURL * url = [NSURL URLWithString:[self.gordon authenticationURL]];
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        //we are in trouble
        //kill the app ?
        NSLog(@"Authentication params not set");
    }
}

- (void) userIsAuthenticatedAndAuthorized:(NSString *) userID
{
    if (self.delegate)
    {
        [self.delegate userFinishedAuthenticating:YES];
    }
}

@end
