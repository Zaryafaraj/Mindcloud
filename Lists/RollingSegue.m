//
//  RollDownSegue.m
//  Lists
//
//  Created by Ali Fathalian on 4/28/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "RollingSegue.h"
#import "CollectionScreenListTableViewController.h"
#import "MultimediaHelper.h"
#import <QuartzCore/QuartzCore.h>

@interface RollingSegue()
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) CALayer * topLayer;
@property (nonatomic, retain) CALayer * bottomLayer;
@end
@implementation RollingSegue

-(void) perform
{
    
    [[self sourceViewController] presentModalViewController:[self destinationViewController] animated:YES];
    //animations are disabled for now
//    self.window = [[[UIApplication sharedApplication] delegate] window];
//    UIViewController * dest = self.destinationViewController;
//    UIViewController * src = self.sourceViewController;
//    [src.view removeFromSuperview];
//    CALayer * topLayer = [CALayer layer];
//    topLayer.anchorPoint = CGPointMake(0.5, 0.5);
//    topLayer.frame = src.view.layer.frame;
//    topLayer.shadowOffset = CGSizeMake(5.0, 5.0);
//    topLayer.contents = (id) [MultimediaHelper clipImageFromLayer:src.view.layer
//                                                             size:topLayer.frame.size
//                                                          offsetX:0.0f];
//    
//    CALayer * bottomLayer = [CALayer layer];
//    bottomLayer.anchorPoint = CGPointMake(0.5, 0.5);
//    bottomLayer.frame = CGRectMake(topLayer.frame.origin.x,
//                                   topLayer.frame.origin.y + topLayer.frame.size.height,
//                                   topLayer.frame.size.width,
//                                   topLayer.frame.size.height);
//    bottomLayer.contents = (__bridge id)([UIImage imageNamed:@"woodenBG.jpg"].CGImage);
//    bottomLayer.shadowOffset = CGSizeMake(0.5, 0.5);
//    
//    self.topLayer = topLayer;
//    self.bottomLayer = bottomLayer;
//    [self.window.layer addSublayer:topLayer];
//    [self.window.layer addSublayer:bottomLayer];
//    
//    CABasicAnimation * topAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
//    CATransform3D topFromTransform = topLayer.transform;
//    //CATransform3DRotate(topLayer.transform, 0, 1, 0,0);
//    topFromTransform.m34 = - 1./400;
//    CATransform3D topToTransform = CATransform3DTranslate(topLayer.transform, 0, -topLayer.frame.size.height, 0);
//    //CATransform3DRotate(topLayer.transform, 0, 1, 0,0);
//    //topToTransform =CATransform3DTranslate(topToTransform, 0, 0, topLayer.frame.size.height);
//    topToTransform.m34 = - 1./400;
//    topAnimation.fromValue = [NSValue valueWithCATransform3D:topFromTransform];
//    topAnimation.toValue = [NSValue valueWithCATransform3D:topToTransform];
//    topAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    topAnimation.duration = 1.0;
//    topAnimation.delegate = self;
//    [topLayer addAnimation:topAnimation forKey:@"SegueAnimation"];
//    
//    CABasicAnimation * bottomAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
//    CATransform3D bottomFromTransform = bottomLayer.transform;
//    //CATransform3DRotate(bottomLayer.transform, 0 , 1, 0,0);
//    bottomFromTransform.m34 = - 1./400;
//    CATransform3D bottomToTransform = CATransform3DTranslate(bottomLayer.transform, 0, -bottomLayer.frame.size.height, 0);
//    //CATransform3DRotate(bottomLayer.transform,  0, 1, 0,0);
//    bottomToTransform.m34 = - 1./400;
//    bottomAnimation.fromValue = [NSValue valueWithCATransform3D:bottomFromTransform];
//    bottomAnimation.toValue = [NSValue valueWithCATransform3D:bottomToTransform];
//    bottomAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    bottomAnimation.duration = topAnimation.duration;
//    
//    [bottomLayer addAnimation:bottomAnimation forKey:@"SegueAnimation"];
}

-(void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
//    [self.topLayer removeFromSuperlayer];
//    [self.bottomLayer removeFromSuperlayer];
//    [self.window setRootViewController:self.destinationViewController];
}
@end
