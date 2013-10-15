//
//  CollectionBoardView.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/15/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionBoardView.h"
#import "PaintLayerView.h"

@interface CollectionBoardView()

@property (nonatomic, strong) UIView * paintLayer;

@end
@implementation CollectionBoardView

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self configurePaintLayer];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self configurePaintLayer];
    }
    return self;
}

-(void) configurePaintLayer
{
    NSLog(@"I WAS HERE");
    CGRect paintFrame = CGRectMake(0,
                                   0,
                                   self.bounds.size.width,
                                   self.bounds.size.height);
    UIView * paintLayer = [[UIView alloc] initWithFrame:paintFrame];
    paintLayer.backgroundColor = [UIColor greenColor];
    self.paintLayer = paintLayer;
    self.paintLayer.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary * viewsDictionary = NSDictionaryOfVariableBindings(self, paintLayer);
    [self addSubview:paintLayer];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[paintLayer]|" options:0 metrics: 0 views:viewsDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[paintLayer]|" options:0 metrics: 0 views:viewsDictionary]];
}

-(void) showPaintLayer
{
    self.paintLayer.hidden = YES;
}

-(void) hidePaintLayer
{
    self.paintLayer.hidden = NO;
}

@end
