//
//  SubscriptionAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/24/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface SubscriptionAction : MindcloudBaseAction

typedef void (^subscribe_to_collection_callback)(NSString * collectionName);

@property (nonatomic, strong) subscribe_to_collection_callback postCallback;

-(id) initWithUserId:(NSString *) userId
    andSharingSecret:(NSString *) sharingSecret;

@end
