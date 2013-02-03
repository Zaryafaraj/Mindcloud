//
//  MultimediaHelper.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/20/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MultimediaHelper.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>

@implementation MultimediaHelper
#define THUMBNAIL_WIDTH 250
#define THUMBNAIL_HEIGHT 250
#define IMG_COMPRESSION_QUALITY 1
+(UIImagePickerController *) getCameraController
{
    
    //check to see if camera is available
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        return nil;
    }
    
    NSArray * mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    if (![mediaTypes containsObject:(NSString *) kUTTypeImage]) return nil;
    
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
    imagePicker.allowsEditing = YES;
    return imagePicker;
}

+ (NSData *) captureScreenshotOfView:(UIView *)view
{
    CGFloat sizeX = MAX(view.bounds.size.width, view.bounds.size.height);
    CGFloat sizeY = MIN(view.bounds.size.width, view.bounds.size.height);
    CGSize imageSize = CGSizeMake(sizeX, sizeY);
    //app works only on ios version 4 and up which is the earliest ios on ipad so this
    //should not be a problem
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIView * subView in view.subviews)
    {
        if (![subView isKindOfClass:[UIToolbar class]])
            [subView.layer renderInContext:context];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * imgData = UIImageJPEGRepresentation(image, IMG_COMPRESSION_QUALITY);
    return imgData;
}

+(NSData *) getThumbnailDataforUIImage:(UIImage *) image
{
    NSData * imgData = UIImageJPEGRepresentation(image, IMG_COMPRESSION_QUALITY);
    return imgData;
}
@end
