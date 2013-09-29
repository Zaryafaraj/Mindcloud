//
//  NoteAnimator.m
//  Mindcloud
//
//  Created by Ali Fathalian on 9/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "NoteAnimator.h"

@implementation NoteAnimator

+(void) animateNoteHighlighted:(NoteView *) note
{
    CALayer * layer = note.layer;
    layer.transform = CATransform3DIdentity;
    CABasicAnimation * selectAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D toTransform = CATransform3DMakeScale(1.1, 1.1, 1.1);
    toTransform.m34 = - 1./500;
    
    
    selectAnimation.fromValue = [NSValue valueWithCATransform3D:layer.transform];
    selectAnimation.toValue = [NSValue valueWithCATransform3D:toTransform];
    
    layer.transform = toTransform;
    selectAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    selectAnimation.duration = 0.2;
    [layer addAnimation:selectAnimation forKey:@"scaleAnimation"];
    
}

+(void) animateNoteUnhighlighted:(NoteView *) note
{
    
    CALayer * layer = note.layer;
    CABasicAnimation * selectAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D toTransform = CATransform3DIdentity;
    
    selectAnimation.fromValue = [NSValue valueWithCATransform3D:layer.transform];
    selectAnimation.toValue = [NSValue valueWithCATransform3D:toTransform];
    
    layer.transform = toTransform;
    
    selectAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    selectAnimation.duration = 0.2;
    [layer addAnimation:selectAnimation forKey:@"scaleAnimation"];
}

@end
