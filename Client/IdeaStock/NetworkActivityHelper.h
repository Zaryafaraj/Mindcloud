//
//  NetworkActivityHelper.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/21/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkActivityHelper : NSObject
+(void) addActivityInProgress;
+(void) removeActivityInProgress;
@end
