//
//  ManifestMerger.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionManifestProtocol.h"
#import "CollectionRecorder.h"
#import "NotificationContainer.h"
@interface ManifestMerger : NSObject

-(id) initWithClientManifest:(id <XoomlProtocol>) clientManifest
           andServerManifest:(id <XoomlProtocol>) serverManifest
           andActionRecorder:(CollectionRecorder *) recorder;

-(id<XoomlProtocol>) mergeManifests;

-(NotificationContainer *) getNotifications;

@end
