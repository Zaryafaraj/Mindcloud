//
//  IntroScreenViewController.h
//  Mindcloud
//
//  Created by Ali Fathalian on 12/6/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IntroScreenDelegate <NSObject>

-(void) signInPressed;
-(void) introScreenFinished:(BOOL) skipped;

@end

@interface IntroScreenViewController : UIViewController <UIScrollViewDelegate>

@property id<IntroScreenDelegate> delegate;

@end
