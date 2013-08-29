//
//  MergeResult.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/16/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationContainer.h"
#import "XoomlProtocol.h"

@interface MergeResult : NSObject
@property (nonatomic, strong) NotificationContainer * notifications;
@property (nonatomic, strong) id<XoomlProtocol> finalManifest;
@property (nonatomic, strong) NSString * collectionName;

-(id) initWithNotifications:(NotificationContainer *) notifications
           andFinalManifest:(id<XoomlProtocol>) finalManifest
          andCollectionName:(NSString *) collectionName;
@end
