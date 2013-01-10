//
//  CollectionAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/9/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface CollectionAction : MindcloudBaseAction

typedef void (^get_collection_callback)(NSData * collectionData);

@property (nonatomic, strong) get_collection_callback getCallback;

-(id) initWithUserId:(NSString *) userId
       andCollection:(NSString *) collectionName;

@end
