//
//  MergeResult.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/16/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MergeResult.h"

@implementation MergeResult

-(id) initWithNotifications:(NotificationContainer *) notifications
           andFinalManifest:(id<CollectionManifestProtocol>) finalManifest
          andCollectionName:(NSString *) collectionName
{
    self = [super init];
    self.notifications = notifications;
    self.finalManifest = finalManifest;
    self.collectionName = collectionName;
    return self;
}

@end
