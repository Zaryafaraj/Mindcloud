//
//  AuthenticationAction.h
//  IdeaStock
//
//  Created by Ali Fathalian on 9/22/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface AuthenticationAction : MindcloudBaseAction

typedef void (^authentication_callback)(NSDictionary * authenticationParams);

-(id) initWithUserId: (NSString *) userID andCallback: (authentication_callback) callback;
-(void) execute;

@end
