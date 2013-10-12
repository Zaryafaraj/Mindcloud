//
//  ScreenCaptureService.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/11/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "ScreenCaptureService.h"
#import "MultimediaHelper.h"

@implementation ScreenCaptureService

dispatch_queue_t thumbnailQueue;

+(id) getInstance
{
    
    static ScreenCaptureService * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ScreenCaptureService alloc] init];
    });
    
    return instance;
}

-(dispatch_queue_t) getThumbnailQueue
{
    if (!thumbnailQueue)
    {
        thumbnailQueue = dispatch_queue_create("collection_thumbnail_queue", NULL);
    }
    return thumbnailQueue;
}

-(void) submitCaptureThumbnailRequestForCollection:(NSString *) collectionName
                                       withTopView:(UIView *) viewToCapture
                                       andViewType: (ViewForScreenShotType) viewType
                                       andCallback: (thumbnail_saved_callback) callback
{
    
    dispatch_queue_t queue = [self getThumbnailQueue];
    dispatch_async(queue, ^{
        
        NSData * thumbnailData = [MultimediaHelper captureScreenshotOfView:viewToCapture];
        
        dispatch_async(dispatch_get_main_queue(),^{
            if (callback != nil)
            {
                callback(thumbnailData, collectionName, viewType);
            }
        });
    });
}
@end
