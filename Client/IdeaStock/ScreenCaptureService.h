//
//  ScreenCaptureService.h
//  Mindcloud
//
//  Created by Ali Fathalian on 10/11/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, ViewForScreenShotType) {
    ViewForScreenShotCollectionView
};

typedef void (^thumbnail_saved_callback)(NSData * thumbnailData, NSString * collectionName, ViewForScreenShotType viewType);

@interface ScreenCaptureService : NSObject

+(id) getInstance;

-(void) submitCaptureThumbnailRequestForCollection:(NSString *) collectionName
                                       withTopView:(UIView *) viewToCapture
                                       andViewType: (ViewForScreenShotType) viewType
                                       andCallback: (thumbnail_saved_callback) callback;

@end
