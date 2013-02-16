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

-(id) initWithClientManifest:(id <CollectionManifestProtocol>) clientManifest
           andServerManifest:(id <CollectionManifestProtocol>) serverManifest
           andActionRecorder:(CollectionRecorder *) recorder;

-(id<CollectionManifestProtocol>) mergeManifests;

-(NotificationContainer *) getNotifications;

@end
