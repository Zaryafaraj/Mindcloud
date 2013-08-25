//
//  NamingHelper.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/3/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NamingHelper : NSObject

+(NSString *) getBestNameFor:(NSString *) nameCandidate
               amongAllNAmes:(NSArray *) allName;

+(NSString *) validateCollectionName: (NSString *) nameCandidate
                       amongAllNames:(NSSet *) allNames;
@end
