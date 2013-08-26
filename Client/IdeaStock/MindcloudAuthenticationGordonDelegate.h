//
//  MindcloudAuthenticationGordonDelegate.h
//  Mindcloud
//
//  Created by Ali Fathalian on 8/25/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MindcloudAuthenticationGordonDelegate <NSObject>

-(void) userIsAuthenticatedAndAuthorized:(NSString *) userID;

@end
