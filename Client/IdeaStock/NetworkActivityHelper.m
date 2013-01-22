//
//  NetworkActivityHelper.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/21/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "NetworkActivityHelper.h"

@implementation NetworkActivityHelper
static int counter;
+(void) addActivityInProgress
{
    if (counter == 0)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    counter++;
}

+(void) removeActivityInProgress
{
    
    counter--;
    if (counter <= 0)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}
@end
