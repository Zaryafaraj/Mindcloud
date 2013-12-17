//
//  TutorialPaintView.m
//  Mindcloud
//
//  Created by Ali Fathalian on 12/12/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "TutorialPaintView.h"


@interface TutorialPaintView()

@property (nonatomic, strong) DrawingTraceContainer * container;

@property (nonatomic, strong) NSMutableArray * allTraces;

@end

@implementation TutorialPaintView


-(id) initWithContainer:(DrawingTraceContainer *) container
{
    self = [super init];
    if (self)
    {
        self.container = container;
    }
    return self;
}

-(void) startDrawing
{
    self.allTraces = [self.container getAllTracers].mutableCopy;
    DrawingTrace * firstTrace = self.allTraces[0];
    [self animateTrace:firstTrace];
}

-(void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.allTraces removeObjectAtIndex:0];
    if (self.allTraces.count == 0 )
    {
        id<TutorialPaintViewDelegate> tempDel = self.delegate;
        if (self.delegate)
        {
            [tempDel animationsFinished];
        }
        return;
    }
    if ( self.allTraces.count == self.stopPoint)
    {
        id<TutorialPaintViewDelegate> tempDel = self.delegate;
        if (self.delegate)
        {
            [tempDel animationsStoppedAtIndex:self.allTraces.count];
        }
        return;
    }
    DrawingTrace * trace = self.allTraces[0];
    [self animateTrace:trace];
}

-(void) animateTrace:(DrawingTrace *) trace
{
    CAShapeLayer * bezier = [[CAShapeLayer alloc] init];
    bezier.path = trace.path.CGPath;
    bezier.strokeColor = trace.color.CGColor;
    bezier.fillColor = [UIColor clearColor].CGColor;
    bezier.lineWidth = trace.lineWidth;
    bezier.lineCap = kCALineCapRound;
    bezier.strokeStart = 0;
    bezier.strokeEnd = 1.0;
    [self.layer addSublayer:bezier];
    
    CABasicAnimation *animateStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokeEnd.delegate = self;
    animateStrokeEnd.duration  = 0.3;
    animateStrokeEnd.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animateStrokeEnd.fromValue = [NSNumber numberWithFloat:0.0f];
    animateStrokeEnd.toValue   = [NSNumber numberWithFloat:1.0f];
    [bezier addAnimation:animateStrokeEnd forKey:@"strokeEndAnimation"];
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
