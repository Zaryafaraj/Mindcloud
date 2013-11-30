//
//  UserStatus.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/29/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserStatus : NSObject

+(UserStatus *) userStatus;

@property (nonatomic) BOOL isUserOnline;
@property (nonatomic) BOOL hasUserBeenNotifiedOfBeingOffline;

@end
