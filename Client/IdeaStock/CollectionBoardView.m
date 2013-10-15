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

@property (nonatomic, strong) PaintLayerView * paintLayer;

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
    CGRect paintFrame = CGRectMake(0,
                                   0,
                                   self.bounds.size.width,
                                   self.bounds.size.height);
    PaintLayerView * paintLayer = [[PaintLayerView alloc] initWithFrame:paintFrame];
    paintLayer.backgroundColor = [UIColor greenColor];
    self.paintLayer = paintLayer;
    self.paintLayer.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary * viewsDictionary = NSDictionaryOfVariableBindings(self, paintLayer);
    [self addSubview:paintLayer];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[paintLayer]|" options:0 metrics: 0 views:viewsDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[paintLayer]|" options:0 metrics: 0 views:viewsDictionary]];
    self.paintLayer.hidden = YES;
}

-(void) showPaintLayer
{
    self.paintLayer.hidden = NO;
}

-(void) hidePaintLayer
{
    self.paintLayer.hidden = YES;
}

@end
