//
//  MultimediaHelper.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/20/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultimediaHelper : NSObject

+(UIImagePickerController *) getCameraController;

+(NSData *) captureScreenshotOfView:(UIView *)view;

@end