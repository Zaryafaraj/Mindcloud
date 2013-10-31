//
//  BrushSelectionView.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "BrushSelectionView.h"
#import "ThemeFactory.h"

@interface BrushSelectionView()

@property UIBezierPath * samplePath;

@end

@implementation BrushSelectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.samplePath = [self createSamplePath];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.samplePath = [self createSamplePath];
        self.backgroundColor = [[ThemeFactory currentTheme] collectionBackgroundColor];
    }
    return self;
}

-(void) setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

@synthesize lineColor = _lineColor;
-(void) setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    [self setNeedsDisplay];
}

-(UIColor *) lineColor
{
    if (!_lineColor)
    {
        _lineColor = [UIColor whiteColor];
    }
    return _lineColor;
}

//offset from the left and right side of the view where the curve begins
#define X_OFFSET 10
#define Y_OFFSET 3

-(UIBezierPath *) createSamplePath
{
    
    CGFloat xSpaceAvailable = self.bounds.size.width - 2 * X_OFFSET;
    CGFloat ySpaceAvailable = self.bounds.size.height - 2 * Y_OFFSET;
    //we need four points for three quad bezier curves
    CGFloat spaceBetweenEndpoints = xSpaceAvailable / 3;
    CGFloat middleY = ySpaceAvailable / 2;
    
    CGPoint start = CGPointMake(X_OFFSET, middleY);
    CGPoint mid1 = CGPointMake(start.x + spaceBetweenEndpoints, middleY);
    CGPoint mid2= CGPointMake(mid1.x + spaceBetweenEndpoints, middleY);
    CGPoint end = CGPointMake(mid2.x + spaceBetweenEndpoints, middleY);
    
    CGPoint controlPoint1 = CGPointMake(start.x + spaceBetweenEndpoints/2,
                                        Y_OFFSET);
    CGPoint controlPoint2 = CGPointMake(mid1.x + spaceBetweenEndpoints/2,
                                        self.bounds.size.height - Y_OFFSET);
    CGPoint controlPoint3 = CGPointMake(mid2.x + spaceBetweenEndpoints/2,
                                           Y_OFFSET);
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:start];
    [path addQuadCurveToPoint:mid1 controlPoint:controlPoint1];
    [path moveToPoint:mid1];
    [path addQuadCurveToPoint:mid2 controlPoint:controlPoint2];
    [path moveToPoint:mid2];
    [path addQuadCurveToPoint:end controlPoint:controlPoint3];
    path.lineWidth = self.lineWidth;
    return path;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    self.samplePath.lineWidth = self.lineWidth;
    [self.lineColor setStroke];
    [self.samplePath strokeWithBlendMode:kCGBlendModeNormal alpha:1];
}


@end
