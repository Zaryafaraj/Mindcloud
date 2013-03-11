//
//  CachedObject.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/19/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CachedObject <NSObject>

-(void) refreshCacheForKey:(NSString *)key;

-(BOOL) isKeyCached:(NSString *) key;

@end
