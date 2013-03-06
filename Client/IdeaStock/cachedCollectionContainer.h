//
//  cachedCollectionContainer.h
//  Mindcloud
//
//  Created by Ali Fathalian on 3/5/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol cachedCollectionContainer <NSObject>

- (NSData *) getCollectionFromCache: (NSString *) collectionName;

@end
