//
//  XoomlAttributeHelper.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/29/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "XoomlAttributeHelper.h"

@implementation XoomlAttributeHelper

+ (NSString *) generateUUID{
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}

//Date as XooML uses : 3/28/2012 12:43 PM
+(NSString *) generateCurrentTimeForXooml{
    NSDate * now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"EN"]];
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm a"];
    return [dateFormatter stringFromDate:now];
}

@end
