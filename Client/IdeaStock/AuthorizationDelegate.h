//
//  AuthorizationDelegate.h
//  IdeaStock
//
//  Created by Ali Fathalian on 10/20/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AuthorizationDelegate <NSObject>

-(void) didFinishAuthorizing: (NSString *)userID
andNeedsAuthenting:(BOOL) needAuthenticating
                     withURL: (NSString *) url;

-(void) authorizationFailed;

@end
