//
//  NoteAnimator.m
//  Mindcloud
//
//  Created by Ali Fathalian on 9/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "NoteAnimator.h"

@implementation NoteAnimator

#define SCALE_SIZE 1.1
#define HIGHLIGHT_DURATION 0.2
#define HIGHLIGHT_SHADOW_ADDITON_X 3
#define HIGHLIGHT_SHADOW_ADDITON_Y 3
#define HIGHLIGHT_ADDITONAL_RADIUS 3

+(void) animateNoteHighlighted:(NoteView *) note
              withDeleteButton:(UIButton *) deleteButton
{
    
    [self scaleNote:note];
    deleteButton.hidden = NO;
    deleteButton.transform = CGAffineTransformIdentity;
    deleteButton.transform = CGAffineTransformScale(deleteButton.transform, 0.1, 0.1);
    [UIView animateWithDuration:0.6
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         deleteButton.transform = CGAffineTransformScale(deleteButton.transform,
                                                                         10 * note.scaleOffset,
                                                                         10 * note.scaleOffset);
                     }completion:^(BOOL completed){}];
}

+(void) animateNoteSelectedInStack:(NoteView *) note
{
    [self scaleNote:note];
}

+(void) animateNoteDeselectedInStack:(NoteView *) note
{
    [self unscaleNote:note];
}

+(void) scaleNote:(UIView *) note
{
    
    CALayer * layer = note.layer;
    layer.transform = CATransform3DIdentity;
    CABasicAnimation * selectAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D toTransform = CATransform3DMakeScale(SCALE_SIZE, SCALE_SIZE, SCALE_SIZE);
    toTransform.m34 = - 1./500;
    
    
    selectAnimation.fromValue = [NSValue valueWithCATransform3D:layer.transform];
    selectAnimation.toValue = [NSValue valueWithCATransform3D:toTransform];
    
    layer.transform = toTransform;
    selectAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    selectAnimation.duration = HIGHLIGHT_DURATION;
    [layer addAnimation:selectAnimation forKey:@"scaleAnimation"];
    
    CABasicAnimation * shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
    CGSize toValue = CGSizeMake(layer.shadowOffset.width,
                                layer.shadowOffset.height + HIGHLIGHT_SHADOW_ADDITON_Y);
    
    shadowAnimation.fromValue = [NSValue valueWithCGSize:layer.shadowOffset];
    shadowAnimation.toValue = [NSValue valueWithCGSize:toValue];
    
    layer.shadowOffset = toValue;
    shadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    shadowAnimation.duration = HIGHLIGHT_DURATION;
    [layer addAnimation:shadowAnimation forKey:@"shadowOffset"];
    
    CABasicAnimation * shadowRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    shadowRadiusAnimation.fromValue = [NSNumber numberWithFloat:layer.shadowRadius];
    shadowRadiusAnimation.toValue = [NSNumber numberWithFloat:layer.shadowRadius + HIGHLIGHT_ADDITONAL_RADIUS];
    
    layer.shadowRadius = layer.shadowRadius + HIGHLIGHT_ADDITONAL_RADIUS;
    shadowRadiusAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    shadowRadiusAnimation.duration = HIGHLIGHT_DURATION;
    [layer addAnimation:shadowRadiusAnimation forKey:@"shadowRadius"];
}

+(void) animateNoteUnhighlighted:(NoteView *) note
                withDeleteButton:(UIButton *) deleteButton
{
    
    
    [self unscaleNote:note];
    [UIView animateWithDuration:0.6
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         deleteButton.transform = CGAffineTransformScale(deleteButton.transform, 0.001 * 1/note.scaleOffset, 0.001 * 1/note.scaleOffset);
                     }completion:^(BOOL completed){
                         deleteButton.hidden = YES;
                     }];
}

+(void) unscaleNote:(UIView *) note
{
    CALayer * layer = note.layer;
    CABasicAnimation * selectAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D toTransform = CATransform3DIdentity;
    
    selectAnimation.fromValue = [NSValue valueWithCATransform3D:layer.transform];
    selectAnimation.toValue = [NSValue valueWithCATransform3D:toTransform];
    
    layer.transform = toTransform;
    
    selectAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    selectAnimation.duration = HIGHLIGHT_DURATION;
    [layer addAnimation:selectAnimation forKey:@"scaleAnimation"];
    
    CABasicAnimation * shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
    CGSize toValue = CGSizeMake(layer.shadowOffset.width,
                                layer.shadowOffset.height - HIGHLIGHT_SHADOW_ADDITON_Y);
    
    shadowAnimation.fromValue = [NSValue valueWithCGSize:layer.shadowOffset];
    shadowAnimation.toValue = [NSValue valueWithCGSize:toValue];
    
    layer.shadowOffset = toValue;
    shadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    shadowAnimation.duration = HIGHLIGHT_DURATION;
    [layer addAnimation:shadowAnimation forKey:@"shadowOffset"];
    
    CABasicAnimation * shadowRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    shadowRadiusAnimation.fromValue = [NSNumber numberWithFloat:layer.shadowRadius];
    shadowRadiusAnimation.toValue = [NSNumber numberWithFloat:layer.shadowRadius - HIGHLIGHT_ADDITONAL_RADIUS];
    
    layer.shadowRadius = layer.shadowRadius - HIGHLIGHT_ADDITONAL_RADIUS;
    shadowRadiusAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    shadowRadiusAnimation.duration = HIGHLIGHT_DURATION;
    [layer addAnimation:shadowRadiusAnimation forKey:@"shadowRadius"];
}
@end
