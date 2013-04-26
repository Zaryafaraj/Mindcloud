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
#import "ListRow.h"

@implementation ListTableSlideAnimationManager

-(void) slideMainScreenRow:(UIView *) row
                   toFrame:(CGRect) frame
{
    [UIView animateWithDuration:0.25 animations:^{
        row.frame = frame;
    }];
}


-(void) animateAdditionForRow:(UIView<ListRow> *) row
                      toFrame:(CGRect) frame
                  inSuperView:(UIView *) superView
        withCompletionHandler:(row_modification_callback) callback
{
    [row removeFromSuperview];
    row.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    [superView addSubview:row];
    
    CALayer * layer = row.layer;
    
    layer.anchorPoint = CGPointMake(0.5, 0);
    layer.transform = CATransform3DIdentity;
    layer.transform = CATransform3DTranslate(layer.transform, 0, -frame.size.height/2, 0);

    CABasicAnimation * rotateAnime = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D transform = CATransform3DRotate(layer.transform, - 1 * M_PI_2, 1, 0, 0);
    transform.m34 = -1./500;
    CATransform3D transform2 = CATransform3DRotate(layer.transform, + 0.40 * M_PI_2, 1, 0, 0);
    transform2.m34 = -1./500;
    //transform = CATransform3DTranslate(transform, 0, 0, 200);
    rotateAnime.fromValue = [NSValue valueWithCATransform3D:transform];
    rotateAnime.toValue = [NSValue valueWithCATransform3D:layer.transform];
    rotateAnime.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    rotateAnime.duration = 0.7;
    
   [layer addAnimation:rotateAnime forKey:@"rotation"];
    
    CABasicAnimation * opacityAnime = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnime.fromValue = [NSNumber numberWithFloat:0.3];
    opacityAnime.toValue = [NSNumber numberWithFloat:1];
    opacityAnime.duration = 0.4;
    
    [layer addAnimation:opacityAnime forKey:@"opacity"];
    
    CALayer *foregroundLayer = row.foregroundView.layer;
    CABasicAnimation * shadowAnime = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
    CGSize initShadowOffset = CGSizeMake(foregroundLayer.shadowOffset.width ,
                                         foregroundLayer.shadowOffset.height + 20);
    shadowAnime.fromValue = [NSValue valueWithCGSize:initShadowOffset];
    shadowAnime.toValue = [NSValue valueWithCGSize:foregroundLayer.shadowOffset];
    shadowAnime.duration = rotateAnime.duration;
    
    [foregroundLayer addAnimation:shadowAnime forKey:@"shadowOffset"];
    
    CABasicAnimation * shadowAnime2 = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    shadowAnime2.fromValue = [NSNumber numberWithFloat:9];
    shadowAnime2.toValue = [NSNumber numberWithFloat:foregroundLayer.shadowRadius];
    shadowAnime2.duration = shadowAnime.duration;
    
    [foregroundLayer addAnimation:shadowAnime2 forKey:@"shadowRadius"];
    
    CABasicAnimation * shadowAnime3 = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    shadowAnime3.fromValue = [NSNumber numberWithFloat:0.4];
    shadowAnime3.toValue = [NSNumber numberWithFloat:foregroundLayer.shadowOpacity];
    shadowAnime3.duration =  0.8 * shadowAnime.duration;
    
    [foregroundLayer addAnimation:shadowAnime3 forKey:@"shadowOpacity"];
    
}

-(void) animateRemovalForRow:(UIView<ListRow> *) row
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
