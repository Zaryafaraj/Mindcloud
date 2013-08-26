//
//  MindcloudGordonAuthentication.h
//  Mindcloud
//
//  Created by Ali Fathalian on 8/25/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthorizationDelegate.h"
#import "MindcloudAuthenticationGordonDelegate.h"

@interface MindcloudAuthenticationGordon : NSObject <AuthorizationDelegate>

-(id) initWithUserId:(NSString *) userId
         andDelegate:(id<MindcloudAuthenticationGordonDelegate> ) del;

-(void) authorizeUser:(NSString *) userId;

-(NSString *) authenticationURL;
@end
