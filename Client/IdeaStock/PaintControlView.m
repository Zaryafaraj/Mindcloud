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
