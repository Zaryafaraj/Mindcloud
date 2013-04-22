//
//  AnimationHelper.m
//  Lists
//
//  Created by Ali Fathalian on 4/9/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ListTableSlideAnimationManager.h"
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CAAnimation.h>

@implementation ListTableSlideAnimationManager

-(void) slideMainScreenRow:(UIView *) row
                   toFrame:(CGRect) frame
{
    [UIView animateWithDuration:0.25 animations:^{
        row.frame = frame;
    }];
}


-(void) animateAdditionForRow:(UIView *) row
                      toFrame:(CGRect) frame
                  inSuperView:(UIView *) superView
        withCompletionHandler:(row_modification_callback) callback
{
    [superView addSubview:row];
    row.frame = CGRectMake(0, frame.origin.y, frame.size.width, frame.size.height);
    
    CALayer * layer = row.layer;
    
    layer.anchorPoint = CGPointMake(0, 0);
    
    CABasicAnimation * translationAnime = [CABasicAnimation animationWithKeyPath:@"position"];
    translationAnime.fromValue = [NSValue valueWithCGPoint:CGPointMake(0, frame.origin.y)];
    translationAnime.toValue = [NSValue valueWithCGPoint:CGPointMake(frame.origin.x, frame.origin.y)];
    translationAnime.duration = 0.3;
    
    CABasicAnimation * alphaAnime = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnime.fromValue = [NSNumber numberWithFloat:0];
    alphaAnime.toValue = [NSNumber numberWithFloat:1];
    alphaAnime.duration = 0.3;
    
    [layer addAnimation:translationAnime forKey:@"translation"];
    [layer addAnimation:alphaAnime forKey:@"opacity"];
    row.frame = frame;
    //    [CATransaction setAnimationDuration:5];
    //    layer.position= CGPointMake(frame.origin.x, frame.origin.y);
    //    layer.opacity = 1;
    //    row.frame = frame;
}

-(void) animateRemovalForRow:(UIView *) row
                 inSuperView:(UIView *) superView
       withCompletionHandler:(row_modification_callback) callback
{
    [UIView animateWithDuration:0.25 animations:^{
        row.alpha = 0;
    }completion:^(BOOL finished){
        if (finished)
        {
            callback();
        }
    }];
}
@end
