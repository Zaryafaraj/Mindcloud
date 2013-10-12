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
#import "UIImage+ImageEffects.h"

@implementation MultimediaHelper
#define THUMBNAIL_WIDTH 250
#define THUMBNAIL_HEIGHT 250
#define IMG_COMPRESSION_QUALITY 0.7
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
    imagePicker.allowsEditing = NO;
    return imagePicker;
}

+(UIImagePickerController *) getLibraryController
{
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
    imagePicker.allowsEditing = NO;
    return imagePicker;
}

+ (UIImage *) blurRect:(CGRect) rect
                inView:(UIView *) view
{
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, view.window.screen.scale);
    
    // There he is! The new API method
    [view drawViewHierarchyInRect:view.frame afterScreenUpdates:NO];
    
    // Get the snapshot
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Now apply the blur effect using Apple's UIImageEffect category
    UIImage *blurredSnapshotImage = [snapshotImage applyLightEffect];
    
    // Or apply any other effects available in "UIImage+ImageEffects.h"
    // UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
    // UIImage *blurredSnapshotImage = [snapshotImage applyExtraLightEffect];
    
    // Be nice and clean your mess up
    UIGraphicsEndImageContext();
    
    return blurredSnapshotImage;
}

+ (NSData *) captureScreenshotOfView:(UIView *)view
{
    CGFloat sizeX = MIN(view.bounds.size.width, view.bounds.size.height);
    CGFloat sizeY = sizeX;
    CGSize imageSize = CGSizeMake(sizeX, sizeY);
    CGRect drawRect = CGRectMake(0, 0, sizeX, sizeY);
    //app works only on ios version 4 and up which is the earliest ios on ipad so this
    //should not be a problem
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    
    [view drawViewHierarchyInRect:drawRect afterScreenUpdates:NO];
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    for (UIView * subView in view.subviews)
//    {
//        if (![subView isKindOfClass:[UIToolbar class]])
//            [subView.layer renderInContext:context];
//    }
    
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
