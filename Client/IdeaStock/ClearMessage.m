//
//  ClearMessage.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "ClearMessage.h"

@implementation ClearMessage

-(NSString *) messageString
{
    NSString * msg =  @"{'action':'clear'}";
    return msg;
}
@end
