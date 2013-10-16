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

@property (nonatomic, strong) NSMutableArray * viewGrid;

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

#define GRID_CELL_SIZE 400
-(void) configurePaintLayer
{
    int cellsInRow = self.bounds.size.width / 400;
    int cellsInColumn = self.bounds.size.height / 400;
    for (int i = 0 ; i < cellsInColumn; i++)
    {
        for (int j = 0 ; j < cellsInRow ; j++)
        {
            CGRect gridFrame = CGRectMake(j * GRID_CELL_SIZE,
                                          i * GRID_CELL_SIZE,
                                          GRID_CELL_SIZE,
                                          GRID_CELL_SIZE);
            
            PaintLayerView * paintLayer = [[PaintLayerView alloc] initWithFrame:gridFrame];
            paintLayer.layer.borderWidth = 1;
            paintLayer.layer.borderColor = [UIColor blackColor].CGColor;
            paintLayer.rowIndex = j;
            paintLayer.colIndex = i;
            paintLayer.backgroundColor = [UIColor greenColor];
            [self addSubview:paintLayer];
            [self.viewGrid addObject:paintLayer];
            paintLayer.userInteractionEnabled = YES;
        }
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    event.
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
-(void) showPaintLayer
{
    for (UIView * view in self.viewGrid)
    {
        view.userInteractionEnabled = YES;
    }
}

-(void) hidePaintLayer
{
    for (UIView * view in self.viewGrid)
    {
        view.userInteractionEnabled = NO;
    }
}

@end
