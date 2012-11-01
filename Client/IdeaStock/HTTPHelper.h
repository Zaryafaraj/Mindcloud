//
//  HTTPHelper.h
//  Mindcloud
//
//  Created by Ali Fathalian on 10/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPHelper : NSObject

+(NSMutableURLRequest *) addPostFile: (NSData *) data
                            withName: (NSString *) fileName
                           andParams:(NSDictionary *) params
                                  to: (NSMutableURLRequest *) request;

+(NSMutableURLRequest *) addPutParams:(NSDictionary *)params
                                   to:(NSMutableURLRequest *)request;
@end
