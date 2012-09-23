//
//  AuthenticationAction.h
//  IdeaStock
//
//  Created by Ali Fathalian on 9/22/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface AuthenticationAction : MindcloudBaseAction

-(id) initWithUserId: (NSString *) userID;
-(void) execute;
@end
