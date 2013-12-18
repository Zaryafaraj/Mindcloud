//
//  PaintControlView.m
//  Mindcloud
//
//  Created by Ali Fathalian on 12/18/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "PaintControlView.h"

@implementation PaintControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = frame.size.width / 2;
        UIPanGestureRecognizer * gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(controlPanned:)];
        [self addGestureRecognizer:gr];
//        UIView *bgView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
//        bgView.backgroundColor = [UIColor clearColor];
//        bgView.layer.borderColor = [UIColor whiteColor].CGColor;
//        bgView.layer.borderWidth = 3;
//        bgView.layer.cornerRadius = 25;
        // Initialization code
    }
    return self;
}

-(void) controlPanned: (UIPanGestureRecognizer *) sender{
    if( sender.state == UIGestureRecognizerStateChanged ||
       sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint translation = [sender translationInView:self.superview];
        UIView * pannedView = [sender view];
        CGPoint newCenter = CGPointMake(pannedView.center.x + translation.x,
                                        pannedView.center.y + translation.y);
        pannedView.center = newCenter;
        [sender setTranslation:CGPointZero inView:self.superview];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [sender velocityInView:sender.view.superview];
        [self adjustViewToBeInBounds:sender.view
                        withVelocity:velocity];
    }
}

-(void) adjustViewToBeInBounds:(UIView *) view
                  withVelocity:(CGPoint) velocity
{
    
    CGPoint newCenter = view.center;
    CGFloat velocityAxis;
    BOOL shouldAdjust = NO;
    
    if (newCenter.y - (self.frame.size.height/2) < self.topOffset)
    {
        newCenter = CGPointMake(newCenter.x, self.topOffset + self.frame.size.height/2);
        velocityAxis = velocity.y;
        shouldAdjust = YES;
    }
    if (newCenter.x - (self.frame.size.width/2) < 0)
    {
        newCenter = CGPointMake(self.frame.size.width/2, newCenter.y);
        velocityAxis = velocity.x;
        shouldAdjust = YES;
    }
    if (newCenter.y + (self.frame.size.height)/2 > self.superview.frame.size.height)
    {
        newCenter = CGPointMake(newCenter.x, self.superview.frame.size.height - self.frame.size.height/2);
        velocityAxis = velocity.y;
        shouldAdjust = YES;
    }
    if (newCenter.x + (self.frame.size.width)/2 > self.superview.frame.size.width)
    {
        newCenter = CGPointMake(self.superview.frame.size.width - self.frame.size.width/2, newCenter.y);
        velocityAxis = velocity.x;
        shouldAdjust = YES;
    }
    
    if (shouldAdjust)
    {
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.5
              initialSpringVelocity:velocityAxis/2
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             view.center = newCenter;
                         }completion:^(BOOL completed){}];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
