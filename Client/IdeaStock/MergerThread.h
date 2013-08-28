//
//  MergerThread.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/16/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionManifestProtocol.h"
#import "CollectionRecorder.h"

@interface MergerThread : NSObject

+(id) getInstance;

-(void) submitClientManifest:(id<XoomlProtocol>) clientManifest
           andServerManifest:(id<XoomlProtocol>) serverManifest
andActionRecorder:(CollectionRecorder *) recorder
           ForCollectionName:(NSString *) collectionName;
@end
