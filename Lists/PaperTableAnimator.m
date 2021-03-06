//
//  AnimationHelper.m
//  Lists
//
//  Created by Ali Fathalian on 4/9/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "PaperTableAnimator.h"
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CAAnimation.h>
#import "ThemeFactory.h"

@interface additionAnimationDelegate : NSObject

-(void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
@property (strong, nonatomic) row_modification_callback callback;
@end

@implementation additionAnimationDelegate

-(void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.callback != nil)
    {
        self.callback();
    }
}
@end

@interface removalAnimationDelegate : NSObject

-(void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
@property (strong, nonatomic) row_modification_callback callback;

@end

@implementation removalAnimationDelegate

-(void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.callback != nil)
    {
        self.callback();
    }
}

@end

@implementation PaperTableAnimator

-(void) slideMainScreenRow:(UIView *) row
                   toFrame:(CGRect) frame
                      fast:(BOOL)fast
{
    float duration = fast ? 0.2 : 0.7;
    [UIView animateWithDuration:duration animations:^{
        row.frame = frame;
    }];
}

-(void) slideContextualMenu:(UIView *) contextualMenu
                    toFrame:(CGRect) frame
                       fast:(BOOL) fast
{
    float duration = fast ? 0.2 : 0.7;
    [UIView animateWithDuration:duration animations:^{
        contextualMenu.frame = frame;
    }];
}


-(void) animateAdditionForRow:(UIView<ListRowProtocol> *) row
                      toFrame:(CGRect) frame
                  inSuperView:(UIView *) superView
        withCompletionHandler:(row_modification_callback) callback
{
    additionAnimationDelegate * delegate = [[additionAnimationDelegate alloc] init];
    delegate.callback = callback;
    
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
    rotateAnime.delegate = delegate;
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
    //callback();
    
}

-(void) animateAdditionForContextualMenu:(UIView *) menu
                             inSuperView:(UIView *) superView
{
    
    menu.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{menu.alpha = 1;}];
//    CALayer * layer = menu.layer;
//    layer.transform = CATransform3DIdentity;
//    
//    CABasicAnimation * bounceAnime = [CABasicAnimation animationWithKeyPath:@"transform"];
//    CATransform3D fromValue = CATransform3DScale(layer.transform, 0.5, 0.5, 0.5);
//    CATransform3D toValue = CATransform3DScale(layer.transform, 1.2, 1.2, 1.2);
//    bounceAnime.fromValue = [NSValue valueWithCATransform3D:fromValue];
//    bounceAnime.toValue = [NSValue valueWithCATransform3D:toValue];
//    bounceAnime.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//    bounceAnime.duration = 0.3;
//    [layer addAnimation:bounceAnime forKey:@"rotation1"];
//    
//    CFTimeInterval now = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
//    CABasicAnimation * bounceAnime2 = [CABasicAnimation animationWithKeyPath:@"transform"];
//    CATransform3D fromValue2 = toValue;
//    CATransform3D toValue2 = layer.transform;
//    bounceAnime2.fromValue = [NSValue valueWithCATransform3D:fromValue2];
//    bounceAnime2.toValue = [NSValue valueWithCATransform3D:toValue2];
//    bounceAnime2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//    bounceAnime2.duration = 0.15;
//    bounceAnime.beginTime = now + bounceAnime.duration;
//    [layer addAnimation:bounceAnime forKey:@"rotation1"];
}

-(void) animateRemovalForRow:(UIView<ListRowProtocol> *) row
                 inSuperView:(UIView *) superView
       withCompletionHandler:(row_modification_callback) callback
{
    
    removalAnimationDelegate * delegate = [[removalAnimationDelegate alloc] init];
    delegate.callback = callback;
    
    CALayer * layer = row.layer;
    layer.anchorPoint = CGPointMake(0.5, 0.5);
    layer.transform = CATransform3DIdentity;
    layer.opacity = 0;
    
    CGFloat xTranslation = -(row.frame.origin.x + row.frame.size.width);
    CABasicAnimation * rotateTranslateAnime = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D toTransform = CATransform3DRotate(layer.transform, - M_PI_4, 0, 1, 1);
    toTransform = CATransform3DTranslate(toTransform, xTranslation, -300, 0);
    toTransform.m34 = - 1./500;
    rotateTranslateAnime.fromValue = [NSValue valueWithCATransform3D:layer.transform];
    rotateTranslateAnime.toValue = [NSValue valueWithCATransform3D:toTransform];
    rotateTranslateAnime.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    rotateTranslateAnime.duration = 1.0;
    rotateTranslateAnime.delegate = delegate;
    [layer addAnimation:rotateTranslateAnime forKey:@"rotateTranslate"];
    
    CABasicAnimation * opacityAnime = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnime.fromValue = [NSNumber numberWithFloat:1];
    opacityAnime.toValue = [NSNumber numberWithFloat:0.5];
    opacityAnime.duration = rotateTranslateAnime.duration;
    
    [layer addAnimation:opacityAnime forKey:@"opacity"];

//    [UIView animateWithDuration:0.25 animations:^{
//        row.alpha = 0;
//    }completion:^(BOOL finished){
//        if (finished)
//        {
//            callback();
//        }
//    }];
}

-(void) animateRemovalForContextualMenu:(UIView *) menu
                            inSuperView:(UIView *) superView
                  withCompletionHandler:(row_modification_callback) callback
{
    [UIView animateWithDuration:1.0 animations:^{
        menu.alpha = 0;
    }completion:^(BOOL completed){
        callback();
    }];
}
-(void) hideNavigationBar:(UINavigationBar *) navBar
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        navBar.alpha = 0;
    }completion:^(BOOL Completed){
        
    }];
}

-(void) showNavigationBar:(UINavigationBar *) navBar
{
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
        navBar.alpha = [[ThemeFactory currentTheme] alphaForMainScreenNavigationBar];
    }completion:^(BOOL Completed){
        
    }];
}


-(void) animateSetToDone:(UIView<ListRowProtocol> *)row
{
    UIColor * doneColor = [[ThemeFactory currentTheme] colorForTaskStateDone];
    [UIView animateWithDuration: 0.2 animations:^{
        row.backgroundColor = doneColor;
    }];
//    CALayer * layer = row.layer;
//    
//    CABasicAnimation * changeColorAnime = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
//    changeColorAnime.fromValue = layer.backgroundColor;
    
}

-(void) animateSetToUndone:(UIView<ListRowProtocol> *) row
{
    UIColor * doneColor = [[ThemeFactory currentTheme] colorForTaskStateUndone];
    [UIView animateWithDuration: 0.2 animations:^{
        row.backgroundColor = doneColor;
    }];
}

-(void) animateSetToStar:(UIView<ListRowProtocol> *) row
{
    UIColor * starColor = [[ThemeFactory currentTheme] colorForTaskStateStarred];
    [UIView animateWithDuration: 0.2 animations:^{
        row.backgroundColor = starColor;
    }];
}

-(void) animateSetTimer:(UIView<ListRowProtocol> *) row
{
    UIColor * timedColor = [[ThemeFactory currentTheme] colorForTaskStateTimed];
    [UIView animateWithDuration: 0.2 animations:^{
        row.backgroundColor = timedColor;
    }];
}

-(void) animateExpandRow:(UIView<ListRowProtocol> *) row
{
    
}

@end
