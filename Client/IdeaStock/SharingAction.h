//
//  SharingAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/23/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MindcloudBaseAction.h"

@interface SharingAction : MindcloudBaseAction

typedef void (^share_collection_callback)(NSString * sharingSecret);
typedef void (^unshare_collection_callback)(void);
typedef void (^get_sharing_info_callback)(NSDictionary * sharingInfo);

@property (nonatomic, strong) share_collection_callback postCallback;
@property (nonatomic, strong) unshare_collection_callback deleteCallback;
@property (nonatomic, strong) get_sharing_info_callback getCallback;

-(id) initWithUserId:(NSString *) userId
   andCollectionName:(NSString *) collectionName;

@end
