//
//  XoomlCategoryParser.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/8/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryModelProtocol.h"

@interface XoomlCategoryParser : NSObject

+(NSData *) serializeToXooml:(id<CategoryModelProtocol>) model;
/**
 A dictionary keyed on the name of the category and valued on an NSArray containing
 All collections that belong to that category
 */
+(NSDictionary *) deserializeXooml: (NSData *) xooml;

@end
