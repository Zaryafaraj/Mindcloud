//
//  CollectionViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 4/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "PaintLayerView.h"
#import <QuartzCore/QuartzCore.h>
#import "DrawingTraceContainer.h"


static const CGFloat kPointMinDistance = 3;

static const CGFloat kPointMinDistanceSquared = kPointMinDistance * kPointMinDistance;

@interface PaintLayerView () 

@property UIColor * lastLineColor;
@property (atomic, strong) DrawingTraceContainer * container;

@end

@implementation PaintLayerView

@synthesize lineColor;
@synthesize lineWidth;
@synthesize empty = _empty;
@synthesize eraseModeEnabled = _eraseModeEnabled;


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self initInternals];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initInternals];
    }
    
    return self;
}

-(void) initInternals
{
    self.container = [[DrawingTraceContainer alloc] init];
    self.empty = YES;
    path = CGPathCreateMutable();
}

#pragma mark Private Helper function

CGPoint midPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}


-(void) parentTouchBegan:(UITouch *) touch
               withEvent:(UIEvent *) event
           andOrderIndex:(NSInteger) index
{
    self.previousPoint1 = [touch locationInView:self];
    self.previousPoint2 = [touch locationInView:self];
    self.currentPoint = [touch locationInView:self];
    
    [self appendNewPath:NO withIndex:index];
    self.isTrackingTouch = YES;
    //self.backgroundColor = [UIColor yellowColor];
}

-(void) parentTouchExitedTheView:(UITouch *) touch
                withCurrentPoint:(CGPoint) currentPoint
                   andOrderIndex:(NSInteger) index
{
    if (!self.isTrackingTouch)
    {
        return;
    }
    self.previousPoint2 = self.previousPoint1;
    self.previousPoint1 = [touch previousLocationInView:self];
    self.currentPoint = currentPoint;
    
    [self appendNewPath:YES withIndex:index];
    self.isTrackingTouch = NO;
    //self.backgroundColor = [UIColor greenColor];
}

-(void) parentTouchEnteredTheView:(UITouch *) touch
               withPreviousPoint1: (CGPoint) prevPoint1
                andPreviousPoint2:(CGPoint) previPoint2
                    andOrderIndex:(NSInteger) index
{
    self.currentPoint = [touch locationInView:self];
    self.previousPoint1 = prevPoint1;
    self.previousPoint2 = previPoint2;
    [self appendNewPath:NO withIndex:index];
    self.isTrackingTouch = YES;
    //self.backgroundColor = [UIColor orangeColor];
}

-(void) parentTouchMoved:(UITouch *) touch
                 withEvent:(UIEvent *) event
           andOrderIndex:(NSInteger) index;
{
    //this touch has erroronusly been detected as a moved but its a begin
    if (!self.isTrackingTouch)
    {
        NSLog(@"touch moved without touch began");
    }
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
    
    [self appendNewPath:NO withIndex:index];
    //self.backgroundColor = [UIColor redColor];
}

-(void) appendNewPath:(BOOL) isEndingPath withIndex:(NSInteger) index
{
    //if there is no path to show create a mutable one
    if (path == nil)
    {
        path = CGPathCreateMutable();
    }
    
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
        
        DrawingTraceType drawingType = self.eraseModeEnabled ? DrawingTraceTypeErase : DrawingTraceTypePaint;
        UIColor * color = self.eraseModeEnabled ? [UIColor clearColor] : self.lineColor;
        UIBezierPath * bezierPath = [UIBezierPath bezierPathWithCGPath:path];
        DrawingTrace * trace = [[DrawingTrace alloc] initWithPath:bezierPath
                                                         andColor: color
                                                     andLineWidth:self.lineWidth
                                                          andType:drawingType];
        [self.container addDrawingTrace:trace forOrderIndex:index];
        CGPathRelease(path);
        path = nil;
    }
    

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
   
    NSArray * allTraces = [self.container getAllTracers];
    for (DrawingTrace * trace in allTraces)
    {
        CGContextSetLineCap(context, kCGLineCapRound);
        
        CGContextAddPath(context, trace.path.CGPath);
        if (trace.drawingType == DrawingTraceTypeErase)
        {
//            CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetLineWidth(context,  trace.lineWidth * 5);
            CGContextSetLineCap(context, kCGLineCapSquare);
        }
        else
        {
            CGContextSetBlendMode(context, kCGBlendModeNormal);
            CGContextSetStrokeColorWithColor(context, trace.color.CGColor);
            CGContextSetLineWidth(context, trace.lineWidth);
            CGContextSetLineJoin(context, kCGLineJoinMiter);
        }
        CGContextStrokePath(context);
    }
    if (path != nil)
    {
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinMiter);
       // CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextAddPath(context, path);
        if (self.eraseModeEnabled)
        {
            CGContextSetBlendMode(context, kCGBlendModeClear);
//            CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
            CGContextSetLineWidth(context, self.lineWidth * 5);
            CGContextSetLineCap(context, kCGLineCapSquare);
        }
        else
        {
            CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
            CGContextSetBlendMode(context, kCGBlendModeNormal);
            CGContextSetLineWidth(context, self.lineWidth);
        }
        
        CGContextStrokePath(context);
    }
    
    
    UIGraphicsEndImageContext();
}

-(void) clearContent
{
    self.empty = YES;
    self.isTrackingTouch = NO;
    CGPathRelease(path);
    path = CGPathCreateMutable();
    [self.container clearAllTraces];
    [self setNeedsDisplay];
}

-(void) cleanupContentBeingDrawn
{
    CGPathRelease(path);
    path = nil;
    self.isTrackingTouch = NO;
    [self setNeedsDisplay];
}

-(void) undoIndex:(NSInteger)index
{
    [self.container removeDrawingTracesAtOrderIndex:index];
    [self setNeedsDisplay];
}

-(void)dealloc {
	CGPathRelease(path);
}

-(NSData *) serializeLayer
{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}


-(void) addContentOfSerializedContainerAsBase:(NSData *) baseContainerData
{
    @try {
        DrawingTraceContainer *  baseContainer = [NSKeyedUnarchiver unarchiveObjectWithData:baseContainerData];
        [self.container applyBaseContainer:baseContainer];
        [self setNeedsDisplay];
    }
    @catch (NSException *exception) {
        NSLog(@"Failed to unarchive");
        return;
    }
}

-(void) addContentOfSerializedContainerAsAdded:(NSData *) addedContainer
{
    
}

-(NSDictionary *) getNewDrawings
{
    return [self.container getNewTraces];
}

-(NSDictionary *) getAllDrawings
{
    return [self.container getAllTracesDictionary];
}

-(void) resetNewTracesHeadToNow
{
    [self.container rebaseTraces];
}

-(NSString *) description
{
    NSString * parentDescription = [super description];
    return [NSString stringWithFormat:@"row: %d ; col: %d ; %@", self.rowIndex, self.colIndex, parentDescription];
}
@end

