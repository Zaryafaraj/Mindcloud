//
//  MindcloudAuthenticator.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/29/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MindcloudAuthenticationGordonDelegate.h"

@protocol MindlcoudAuthenticatorDelegate <NSObject>

-(void) userFinishedAuthenticating:(BOOL) success;

@end

@interface MindcloudAuthenticator : NSObject <MindcloudAuthenticationGordonDelegate>

@property (nonatomic, weak) id<MindlcoudAuthenticatorDelegate> delegate;

- (void) authorizeUser;
- (void) authenticateUser;

@end
