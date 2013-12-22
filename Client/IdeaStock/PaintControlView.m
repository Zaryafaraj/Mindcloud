//
//  PaintControlView.m
//  Mindcloud
//
//  Created by Ali Fathalian on 12/18/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "PaintControlView.h"
#import "ThemeFactory.h"

@interface PaintControlView()

@property (nonatomic) CGPoint lastTranslation;

@property (nonatomic, strong) UIImageView * imgView;

@end

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
        self.layer.shadowOffset = CGSizeMake(0,1);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 1;
        self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        [self addGestureRecognizer:tgr];
        self.backgroundColor = [[ThemeFactory currentTheme] colorForPaintControl];
        //self.translatesAutoresizingMaskIntoConstraints = NO;
        UIImage * img = [[ThemeFactory currentTheme] imageForPaintControl];
        UIImageView * imgView = [[UIImageView alloc] initWithImage:img];
        self.imgView = imgView;
        imgView.tintColor = [[ThemeFactory currentTheme] tintColorForInactivePaintControl];
        [self addSubview:imgView];
        
        imgView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary * views = NSDictionaryOfVariableBindings(imgView);
        
        NSDictionary * metrics = @{@"imgWidth" : [NSNumber numberWithInt:frame.size.width * 0.45],
                                   @"imgHeight" : [NSNumber numberWithInt:frame.size.height * 0.45]};
        
        NSLayoutConstraint * centerX = [NSLayoutConstraint constraintWithItem:imgView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1
                                                                   constant:0];
        
        NSLayoutConstraint * centerY = [NSLayoutConstraint constraintWithItem:imgView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1
                                                                   constant:0];
        NSString * imgConstraintH = @"H:[imgView(==imgWidth)]";
        NSString * imgConstraintV = @"V:[imgView(==imgHeight)]";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:imgConstraintH
                                                                    options:0
                                                                    metrics:metrics
                                                                      views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:imgConstraintV
                                                                    options:0
                                                                    metrics:metrics
                                                                      views:views]];
        [self addConstraints:@[centerX, centerY]];
//        UIView *bgView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
//        bgView.backgroundColor = [UIColor clearColor];
//        bgView.layer.borderColor = [UIColor whiteColor].CGColor;
//        bgView.layer.borderWidth = 3;
//        bgView.layer.cornerRadius = 25;
        // Initialization code
    }
    return self;
}

-(void) setEraseMode:(BOOL)eraseMode
{
    if (eraseMode)
    {
        self.imgView.image = [[ThemeFactory currentTheme] imageForPaintControlEraser];
    }
    else
    {
        
        self.imgView.image = [[ThemeFactory currentTheme] imageForPaintControl];
    }
}
-(void) setTintColor:(UIColor *)tintColor
{
    self.imgView.tintColor = tintColor;
}
-(void) controlTapped: (UITapGestureRecognizer *) sender
{
    id<PaintControlViewDelegate> temp = self.delegate;
    if (temp)
    {
        [temp controlSelected];
    }
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
        
        if(sender.state == UIGestureRecognizerStateChanged)
        {
            self.lastTranslation = translation;
            id<PaintControlViewDelegate> temp = self.delegate;
            if (temp)
            {
                [temp controlDragged];
            }
        }
    }
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [sender velocityInView:sender.view.superview];
        [self adjustViewToBeInBounds:sender.view
                        withVelocity:velocity];
        
        id<PaintControlViewDelegate> temp = self.delegate;
        if (temp)
        {
            CGVector direction = CGVectorMake(self.lastTranslation.x/80, self.lastTranslation.y/80);
            [temp controlReleasedWithVelocity:velocity withPushDirection:direction];
        }
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

-(BOOL) adjustViewToBeInBounds:(UIView *) view
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
    return shouldAdjust;
}


-(void) adjustToClosestEdge
{
    BOOL didAdjust = [self adjustViewToBeInBounds:self
                                     withVelocity:CGPointMake(0, 0)];
    
    if (!didAdjust)
    {
        
        CGFloat newX;
        CGFloat newY;
        
        CGFloat distanceToRight = abs(self.superview.bounds.size.width -EDGE_OFFSET_SIDE - self.center.x);
        CGFloat distanceToLeft = abs(self.center.x + EDGE_OFFSET_SIDE);
        CGFloat distanceToTop = abs(self.center.y + EDGE_OFFSET_TOP + self.topOffset);
        CGFloat distanceToBottom = abs(self.superview.bounds.size.height - self.center.y - EDGE_OFFSET_BOTTOM);
        
        BOOL shouldSnapToSides = YES;
        if (MIN(distanceToTop, distanceToBottom) < MIN(distanceToRight, distanceToLeft))
        {
            shouldSnapToSides = NO;
        }
        if (distanceToRight <= distanceToLeft)
        {
            newX = self.superview.bounds.origin.x + self.superview.bounds.size.width - EDGE_OFFSET_SIDE - self.bounds.size.width/2;
        }
        else
        {
            newX = self.superview.bounds.origin.x + EDGE_OFFSET_SIDE + self.bounds.size.width/2;
        }
        
        if (distanceToBottom <= distanceToTop)
        {
            newY = self.superview.bounds.origin.y + self.superview.bounds.size.height - EDGE_OFFSET_BOTTOM - self.bounds.size.height/2;
        }
        else
        {
            newY = self.superview.bounds.origin.y + EDGE_OFFSET_TOP + self.topOffset + self.bounds.size.height/2;
        }
        
        CGPoint newCenter;
        
        if (shouldSnapToSides)
        {
            newCenter = CGPointMake(newX, self.center.y);
        }
        else
        {
            newCenter = CGPointMake(self.center.x, newY);
        }
        
        
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.5
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.center = newCenter;
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
