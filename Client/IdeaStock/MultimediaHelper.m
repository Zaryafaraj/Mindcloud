//
//  MultimediaHelper.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/20/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MultimediaHelper.h"
#import <MobileCoreServices/UTCoreTypes.h>

@implementation MultimediaHelper

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
@end
