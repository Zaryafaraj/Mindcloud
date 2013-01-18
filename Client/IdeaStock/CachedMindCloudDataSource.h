//
//  CachedCollectionDataModel.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/8/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionDataSource.h"

@interface CachedMindCloudDataSource : NSObject<MindcloudDataSource>

//always use this factory method to instantiate class
+(id) getInstance: (NSString *) collectionName;

@end
