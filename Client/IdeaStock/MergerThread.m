//
//  MergerThread.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/16/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MergerThread.h"
#import "ManifestMerger.h"
#import "EventTypes.h"
#import "MergeResult.h"

@implementation MergerThread

dispatch_queue_t queue;

//singleTone
+(id) getInstance
{
    
    static MergerThread * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MergerThread alloc] init];
    });
    
    return instance;
}

-(dispatch_queue_t) getDispatchQueue
{
    if (!queue)
    {
        queue = dispatch_queue_create("manifest_merger", NULL);
    }
    return queue;
}

-(void) submitClientManifest:(id<XoomlProtocol>) clientManifest
           andServerManifest:(id<XoomlProtocol>) serverManifest
           andActionRecorder:(CollectionRecorder *) recorder
           ForCollectionName:(NSString *)collectionName
{
    if (recorder == nil) recorder = [[CollectionRecorder alloc] init];
    NSLog(@"MergerThread - Merge Request Submitted");
    dispatch_queue_t queue = [self getDispatchQueue];
    dispatch_async(queue, ^{
        ManifestMerger * merger = [[ManifestMerger alloc] initWithClientManifest:clientManifest andServerManifest:serverManifest andActionRecorder:recorder];
        id<XoomlProtocol> result = merger.mergeManifests;
        NotificationContainer * notifications = merger.getNotifications;
        MergeResult * mergeResult = [[MergeResult alloc] initWithNotifications:notifications
                                                              andFinalManifest:result
                                                             andCollectionName:collectionName];
        //now merge with the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary * userInfo = @{@"result" : mergeResult};
            [[NSNotificationCenter defaultCenter] postNotificationName:FRAGMENT_MERGE_FINISHED_EVENT
                                                                object:self
                                                              userInfo:userInfo];
        });
    });
}

@end
