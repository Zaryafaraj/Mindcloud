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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
