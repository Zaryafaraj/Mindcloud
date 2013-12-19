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
        UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(controlTapped:)];
        [self addGestureRecognizer:tgr];
//        UIView *bgView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
//        bgView.backgroundColor = [UIColor clearColor];
//        bgView.layer.borderColor = [UIColor whiteColor].CGColor;
//        bgView.layer.borderWidth = 3;
//        bgView.layer.cornerRadius = 25;
        // Initialization code
    }
    return self;
}

-(void) controlTapped: (UITapGestureRecognizer *) sender
{
}

#define EDGE_OFFSET_TOP 10
#define EDGE_OFFSET_SIDE 5
#define EDGE_OFFSET_BOTTOM 5

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

-(void) adjustViewToBeInBoundsForRotation
{
    CGFloat distanceFromBottom = self.superview.bounds.size.height - self.center.y;
    CGFloat distanceFromRight = self.superview.bounds.size.width - self.center.x;
    CGFloat scalingFactorRight = distanceFromRight / self.superview.frame.size.width;
    CGFloat scalingFactorBottom = distanceFromBottom / self.superview.frame.size.height;
    
    CGFloat newDistanceFromRight = self.superview.frame.size.height * scalingFactorRight;
    CGFloat newDistanceFromBottom = self.superview.frame.size.width * scalingFactorBottom;
    CGFloat newX = self.superview.bounds.size.height - newDistanceFromRight;
    CGFloat newY = self.superview.bounds.size.width - newDistanceFromBottom;
    if (newY - self.bounds.size.width/2< self.superview.bounds.origin.x + self.topOffset)
    {
        newY = self.superview.bounds.origin.x + self.topOffset + self.frame.size.width/2 + EDGE_OFFSET_TOP;
    }
    if (newY + self.bounds.size.height/2> self.superview.bounds.size.width)
    {
        newY = self.superview.bounds.size.width - self.bounds.size.width/2 - EDGE_OFFSET_BOTTOM;
    }
    
    if (newX - self.bounds.size.width/2 < 0)
    {
        newX = self.bounds.size.width/2 + EDGE_OFFSET_SIDE;
    }
    
    if (newX + self.bounds.size.width/2 > self.superview.bounds.size.height)
    {
        newX = self.superview.bounds.size.height - self.bounds.size.width/2 - EDGE_OFFSET_SIDE;
    }
    
    self.center = CGPointMake(newX, newY);
}

-(void) adjustViewToBeInBounds:(UIView *) view
                  withVelocity:(CGPoint) velocity
{
    
    CGPoint newCenter = view.center;
    CGFloat velocityAxis;
    BOOL shouldAdjust = NO;
    
    if (newCenter.y - (self.frame.size.height/2) < self.topOffset)
    {
        newCenter = CGPointMake(newCenter.x, self.topOffset + self.frame.size.height/2 + EDGE_OFFSET_TOP);
        velocityAxis = velocity.y;
        shouldAdjust = YES;
    }
    if (newCenter.x - (self.frame.size.width/2) < 0)
    {
        newCenter = CGPointMake(self.frame.size.width/2 + EDGE_OFFSET_SIDE, newCenter.y);
        velocityAxis = velocity.x;
        shouldAdjust = YES;
    }
    if (newCenter.y + (self.frame.size.height)/2 > self.superview.frame.size.height)
    {
        newCenter = CGPointMake(newCenter.x, self.superview.frame.size.height - self.frame.size.height/2 - EDGE_OFFSET_BOTTOM);
        velocityAxis = velocity.y;
        shouldAdjust = YES;
    }
    if (newCenter.x + (self.frame.size.width)/2 > self.superview.frame.size.width)
    {
        newCenter = CGPointMake(self.superview.frame.size.width - self.frame.size.width/2 - EDGE_OFFSET_SIDE, newCenter.y);
        velocityAxis = velocity.x;
        shouldAdjust = YES;
    }
    
    if (shouldAdjust)
    {
        velocityAxis = MIN(velocityAxis/2, 50);
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.5
              initialSpringVelocity:velocityAxis
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
