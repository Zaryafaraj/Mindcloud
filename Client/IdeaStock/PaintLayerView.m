//
//  CollectionViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 4/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "PaintLayerView.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_COLOR [UIColor whiteColor]
#define DEFAULT_WIDTH 5.0f

static const CGFloat kPointMinDistance = 5;

static const CGFloat kPointMinDistanceSquared = kPointMinDistance * kPointMinDistance;

@interface PaintLayerView () 

#pragma mark Private Helper function

CGPoint midPoint(CGPoint p1, CGPoint p2);
@property UIColor * lastLineColor;
@property CGMutablePathRef erasePath;
@property NSMutableArray * paths;

@end

@implementation PaintLayerView

@synthesize lineColor;
@synthesize lineWidth;
@synthesize empty = _empty;
@synthesize eraseModeEnabled = _eraseModeEnabled;

-(BOOL)eraseModeEnabled
{
    return _eraseModeEnabled;
    
}

-(void) setEraseModeEnabled:(BOOL)eraseModeEnabled
{
    _eraseModeEnabled = eraseModeEnabled;
    if (_eraseModeEnabled)
    {
//        CGPathRelease(path);
//        path = CGPathCreateMutable();
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.lineWidth = DEFAULT_WIDTH;
        self.lineColor = DEFAULT_COLOR;
        self.empty = YES;
		path = CGPathCreateMutable();
        self.erasePath = CGPathCreateMutable();
        self.paths = [NSMutableArray array];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.lineWidth = DEFAULT_WIDTH;
        self.lineColor = DEFAULT_COLOR;
        self.empty = YES;
		path = CGPathCreateMutable();
        self.erasePath = CGPathCreateMutable();
        self.paths = [NSMutableArray array];
    }
    
    return self;
}


#pragma mark Private Helper function

CGPoint midPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}


-(void) parentTouchBegan:(UITouch *) touch
               withEvent:(UIEvent *) event
{
    self.previousPoint1 = [touch locationInView:self];
    self.previousPoint2 = [touch locationInView:self];
    self.currentPoint = [touch locationInView:self];
    
    [self appendNewPath:NO];
}

-(void) parentTouchExitedTheView:(UITouch *) touch withCurrentPoint:(CGPoint) currentPoint
{
    self.previousPoint2 = self.previousPoint1;
    self.previousPoint1 = [touch previousLocationInView:self];
    self.currentPoint = currentPoint;
    
    [self appendNewPath:YES];
    
}

-(void) parentTouchEnteredTheView:(UITouch *) touch
               withPreviousPoint1: (CGPoint) prevPoint1
                andPreviousPoint2:(CGPoint) previPoint2
{
    self.currentPoint = [touch locationInView:self];
    self.previousPoint1 = prevPoint1;
    self.previousPoint2 = previPoint2;
    [self appendNewPath:NO];
}

-(void) parentTouchMoved:(UITouch *) touch
                 withEvent:(UIEvent *) event;
{
	CGPoint point = [touch locationInView:self];
	
	/* check if the point is farther than min dist from previous */
    CGFloat dx = point.x - self.currentPoint.x;
    CGFloat dy = point.y - self.currentPoint.y;
	
    if ((dx * dx + dy * dy) < kPointMinDistanceSquared) {
        return;
    }
    
    self.previousPoint2 = self.previousPoint1;
    self.previousPoint1 = [touch previousLocationInView:self];
    self.currentPoint = [touch locationInView:self];
    
    [self appendNewPath:NO];
}

-(void) appendNewPath:(BOOL) isEndingPath
{
    CGPoint mid1 = midPoint(self.previousPoint1, self.previousPoint2);
    CGPoint mid2 = midPoint(self.currentPoint, self.previousPoint1);
    
    if (isEndingPath)
    {
        mid2 = self.currentPoint;
    }
    
	CGMutablePathRef subpath = CGPathCreateMutable();
    CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(subpath, NULL, self.previousPoint1.x, self.previousPoint1.y, mid2.x, mid2.y);
    CGRect bounds = CGPathGetBoundingBox(subpath);
    CGPathAddPath(path, NULL, subpath);
   	CGPathRelease(subpath);
	
    if (isEndingPath)
    {
        
        [self.paths addObject:CFBridgingRelease(CGPathCreateCopy(path))];
        CGPathRelease(path);
        path = CGPathCreateMutable();
    }
//    if (self.eraseModeEnabled)
//    {
//        CGPathAddPath(self.erasePath, NULL, subpath);
//    }
//    else
//        if (isEndingPath)
//        {
//        }
   // }

    CGRect drawBox = bounds;
    drawBox.origin.x -= self.lineWidth * 2.0;
    drawBox.origin.y -= self.lineWidth * 2.0;
    drawBox.size.width += self.lineWidth * 4.0;
    drawBox.size.height += self.lineWidth * 4.0;
    
    [self setNeedsDisplayInRect:drawBox];
}


- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
   
    for (id pathRef in self.paths)
    {
        CGPathRef pastDrawPath = (__bridge CGPathRef) pathRef;
       	CGContextAddPath(context, pastDrawPath);
    }
    
	CGContextAddPath(context, path);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    
    CGContextStrokePath(context);
    
    UIGraphicsEndImageContext();
}

-(void) clearContent
{
    self.empty = YES;
    CGPathRelease(path);
    path = CGPathCreateMutable();
    [self.paths removeAllObjects];
    [self setNeedsDisplay];
}

-(void)dealloc {
	CGPathRelease(path);
}

@end

