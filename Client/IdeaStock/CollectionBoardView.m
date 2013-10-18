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

@synthesize eraseModeEnabled = _eraseModeEnabled;

-(BOOL) eraseModeEnabled
{
    return _eraseModeEnabled;
}
-(void) setEraseModeEnabled:(BOOL)eraseModeEnabled
{
    _eraseModeEnabled = eraseModeEnabled;
    for (PaintLayerView * view in self.viewGrid)
    {
        view.eraseModeEnabled = eraseModeEnabled;
    }
}
#define GRID_CELL_SIZE 400
#define VIEW_WIDTH 4000
#define VIEW_HEIGHT 4000
-(void) configurePaintLayer
{
    self.viewGrid = [NSMutableArray array];
    int columCellCount = VIEW_WIDTH / GRID_CELL_SIZE;
    int rowCellCount = VIEW_HEIGHT / GRID_CELL_SIZE;
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
       gridView.layer.borderWidth = 1.3;
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
    
    int columnCellCount =  VIEW_WIDTH / GRID_CELL_SIZE;
    int index = (row * columnCellCount) + col;
    if (index >= [self.viewGrid count])
    {
        NSLog(@"OH OH %@", NSStringFromCGRect(self.bounds));
    }
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

-(void) reload
{
    for (UIView * view in self.viewGrid)
    {
        [self addSubview:view];
        view.hidden = NO;
    }
}

-(void) unload
{
    for (UIView * view in self.viewGrid)
    {
        view.hidden = YES;
        [view removeFromSuperview];
    }
}


-(void) clearPaintedItems
{
    for (PaintLayerView * view in self.viewGrid)
    {
        [view clearContent];
    }
}
@end
