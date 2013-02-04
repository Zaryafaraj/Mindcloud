//
//  NamingHelper.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/3/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "NamingHelper.h"

@implementation NamingHelper

+(NSString *) getBestNameFor:(NSString *)nameCandidate
               amongAllNAmes:(NSArray *)allNames
{
    int count = 1;
    NSSet * existingNames = [NSSet setWithArray:allNames];
    NSString * resultCandidate = nameCandidate;
    while ([existingNames containsObject:resultCandidate])
    {
        resultCandidate = [NSString stringWithFormat:@"%@%d", nameCandidate, count];
        count++;
    }
    return resultCandidate;
}
@end
