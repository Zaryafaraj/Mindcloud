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
    self.viewGrid = [NSMutableArray array];
    int columCellCount = self.bounds.size.width / GRID_CELL_SIZE;
    int rowCellCount = self.bounds.size.height / GRID_CELL_SIZE;
    for (int  row = 0 ; row < rowCellCount; row++)
    {
        for (int col = 0 ; col < columCellCount ; col++)
        {
            CGRect gridFrame = CGRectMake(col * GRID_CELL_SIZE,
                                          row * GRID_CELL_SIZE,
                                          GRID_CELL_SIZE,
                                          GRID_CELL_SIZE);
            
            PaintLayerView * paintLayer = [[PaintLayerView alloc] initWithFrame:gridFrame];
            paintLayer.clipsToBounds = NO;
            paintLayer.colIndex = col;
            paintLayer.rowIndex = row;
            paintLayer.backgroundColor = [UIColor clearColor];
            [self addSubview:paintLayer];
            [self.viewGrid addObject:paintLayer];
            paintLayer.userInteractionEnabled = NO;
        }
    }
}

-(void) enableDebugMode
{
   for (UIView * gridView in self.viewGrid)
   {
       gridView.layer.borderWidth = 0.3;
       gridView.layer.borderColor = [UIColor blackColor].CGColor;
       gridView.backgroundColor = [UIColor greenColor];
   }
}
-(void) touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    CGPoint prevLocation = [touch previousLocationInView:self];
    PaintLayerView * currentTouchedLayer = [self getGridCellForTouchLocation:touchLocation];
    PaintLayerView * prevTouchedLayer = [self getGridCellForTouchLocation:prevLocation];
    
    [prevTouchedLayer parentTouchMoved:touch withEvent:event];
    if (prevTouchedLayer == currentTouchedLayer)
    {
        [prevTouchedLayer parentTouchMoved:touch withEvent:event];
    }
    else
    {
        
        CGPoint currentInSelf = [touch locationInView:self];
        CGPoint currentInChild = [prevTouchedLayer convertPoint:currentInSelf fromView:self];
        [prevTouchedLayer parentTouchExitedTheView:touch withCurrentPoint:currentInChild];
        
        
        CGPoint prevPoint1 = prevTouchedLayer.previousPoint1;
        CGPoint prevPoint2 = prevTouchedLayer.previousPoint2;
        CGPoint prevPoint1InSelf = [self convertPoint:prevPoint1
                                             fromView:prevTouchedLayer];
        CGPoint prevPoint2InSelf = [self convertPoint:prevPoint2
                                             fromView:prevTouchedLayer];
        
        CGPoint prevPoint1InCurrent = [currentTouchedLayer convertPoint:prevPoint1InSelf
                                                               fromView:self];
        
        CGPoint prevPoint2InCurrent = [currentTouchedLayer convertPoint:prevPoint2InSelf
                                                               fromView:self];
        [currentTouchedLayer parentTouchEnteredTheView:touch withPreviousPoint1:prevPoint1InCurrent
                                     andPreviousPoint2:prevPoint2InCurrent];
        
    }
    
}

-(PaintLayerView *) getGridCellForTouchLocation:(CGPoint) touchLocation
{
    int column = touchLocation.x / GRID_CELL_SIZE;
    int row = touchLocation.y / GRID_CELL_SIZE;
    int index = [self arrayIndexForColumn:column andRow:row];
    PaintLayerView * layer = self.viewGrid[index];
    return layer;
}
-(int) arrayIndexForColumn:(int) col
                     andRow:(int) row
{
    
    int columnCellCount = self.bounds.size.width / GRID_CELL_SIZE;
    int index = (row * columnCellCount) + col;
    return index;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    PaintLayerView * layer = [self getGridCellForTouchLocation:location];
    [layer parentTouchBegan:touch withEvent:event];
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
