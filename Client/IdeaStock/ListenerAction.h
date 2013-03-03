//
//  ListenerAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 3/2/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface ListenerAction : MindcloudBaseAction
typedef void (^listener_returned_callback)(NSDictionary * results);
typedef void (^stopped_listenning_callback)(void);

@property (nonatomic, strong) listener_returned_callback postCallback;
@property (nonatomic, strong) stopped_listenning_callback deleteCallback;

-(id) initWithUserId:(NSString *) userId
   andCollectionName:(NSString *) collectionName
    andSharingSecret:(NSString *) sharingSecret
  andSharingSpaceURL:(NSString *) url;

@end
