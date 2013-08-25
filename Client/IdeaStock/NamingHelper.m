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

/*
 Perform some simple error checking on a collection name
 Return the suggested name
 */
+(NSString *) validateCollectionName: (NSString *) nameCandidate
                       amongAllNames:(NSSet *) allNames
{
    int counter = 1;
    NSString * finalName = nameCandidate;
    while ([allNames containsObject:finalName])
    {
        finalName = [NSString stringWithFormat:@"%@%d",nameCandidate,counter];
        counter++;
    }
    
    //so that no one can hack folder hierarchy
    finalName = [finalName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    //protect escape characters
    finalName = [finalName stringByReplacingOccurrencesOfString:@"\\" withString:@"_"];
    finalName = [finalName stringByReplacingOccurrencesOfString:@"~" withString:@"_"];
    NSString * withoutSpaces = [finalName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (withoutSpaces.length == 0)
    {
        finalName = [finalName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    }
    
    return finalName;
}
@end
