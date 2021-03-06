//
//  CachedCollectionDataModel.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/8/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MindcloudDataSource.h"
#import "CachedObject.h"
#import "CollectionSharingAdapterDelegate.h"
#import "SharingAwareObject.h"
#import "CachedCollectionContainer.h"
#import "AuthorizationDelegate.h"

@interface CachedMindCloudDataSource : NSObject<MindcloudDataSource,
CachedObject,
SharingAwareObject,
CollectionSharingAdapterDelegate,
cachedCollectionContainer>

//always use this factory method to instantiate class
+(id) getInstance: (NSString *) collectionName;

@end
