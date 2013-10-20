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

@property (nonatomic, strong) NSMutableArray * allDrawings;

@property NSInteger orderIndex;

@end

@implementation CollectionBoardView


@synthesize eraseModeEnabled = _eraseModeEnabled;

-(void) setEraseModeEnabled:(BOOL)eraseModeEnabled
{
    _eraseModeEnabled = eraseModeEnabled;
    for (PaintLayerView * view in self.viewGrid)
    {
        view.eraseModeEnabled = eraseModeEnabled;
    }
}
-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self configurePaintLayer];
        [self configureInternals];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self configurePaintLayer];
        [self configureInternals];
    }
    return self;
}

-(void) configureInternals
{
    self.allDrawings = [NSMutableArray array];
    //haven't started drawing anything
    self.orderIndex = -1;
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
            paintLayer.layer.borderWidth = 1.0;
            paintLayer.layer.borderColor = [UIColor blackColor].CGColor;
            paintLayer.clipsToBounds = NO;
            paintLayer.colIndex = col;
            paintLayer.rowIndex = row;
            paintLayer.backgroundColor = [UIColor clearColor];
            paintLayer.userInteractionEnabled = NO;
            [self addSubview:paintLayer];
            [self.viewGrid addObject:paintLayer];
        }
    }
    self.userInteractionEnabled = NO;
}

-(void) undo
{
    if (self.orderIndex >= 0 &&
        self.orderIndex < self.allDrawings.count)
    {
        NSSet * touchedViewsInLastOrder = self.allDrawings[self.orderIndex];
        for (PaintLayerView * view in touchedViewsInLastOrder)
        {
            [view undoIndex:self.orderIndex];
        }
    
        [self.allDrawings removeLastObject];
        self.orderIndex--;
    }
}

-(void) enableDebugMode
{
   for (UIView * gridView in self.viewGrid)
   {
       gridView.layer.borderWidth = 1.0;
       gridView.layer.borderColor = [UIColor blackColor].CGColor;
       gridView.backgroundColor = [UIColor greenColor];
   }
}

-(void) addTouchedItem:(PaintLayerView *) view
{
    if (self.orderIndex + 1> self.allDrawings.count)
    {
        NSMutableSet * touchedViews = [NSMutableSet set];
        [self.allDrawings addObject:touchedViews];
    }
    
    NSMutableSet * touchedViewsInOrder = self.allDrawings[self.orderIndex];
    [touchedViewsInOrder addObject:view];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (touches.count > 1) return;
    
    self.orderIndex++;
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    PaintLayerView * touchedLayer = [self getGridCellForTouchLocation:location];
    [self addTouchedItem:touchedLayer];
    [touchedLayer parentTouchBegan:touch withEvent:event andOrderIndex:self.orderIndex];
}

-(void) touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    PaintLayerView * currentTouchedLayer = [self getGridCellForTouchLocation:touchLocation];
    
    CGPoint currentInSelf = [touch locationInView:self];
    CGPoint currentInChild = [currentTouchedLayer convertPoint:currentInSelf fromView:self];
   
    [currentTouchedLayer parentTouchExitedTheView:touch
                                 withCurrentPoint:currentInChild
                                    andOrderIndex:self.orderIndex];
}
-(void) touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    
    if (touches.count > 1) return;
    
    UITouch * touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    CGPoint prevLocation = [touch previousLocationInView:self];
    PaintLayerView * currentTouchedLayer = [self getGridCellForTouchLocation:touchLocation];
    PaintLayerView * prevTouchedLayer = [self getGridCellForTouchLocation:prevLocation];
    
    [prevTouchedLayer parentTouchMoved:touch withEvent:event andOrderIndex:self.orderIndex];
    
    [self addTouchedItem:currentTouchedLayer];
    
    if (prevTouchedLayer == currentTouchedLayer)
    {
        [prevTouchedLayer parentTouchMoved:touch withEvent:event andOrderIndex:self.orderIndex];
    }
    else
    {
        
        CGPoint currentInSelf = [touch locationInView:self];
        CGPoint currentInChild = [prevTouchedLayer convertPoint:currentInSelf fromView:self];
        
        [self addTouchedItem:prevTouchedLayer];
        
        [prevTouchedLayer parentTouchExitedTheView:touch withCurrentPoint:currentInChild andOrderIndex:self.orderIndex];
        
        
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
                                     andPreviousPoint2:prevPoint2InCurrent andOrderIndex:self.orderIndex];
        
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



-(void) showPaintLayer
{
    self.userInteractionEnabled = YES;
    for (UIView * view in self.viewGrid)
    {
        view.userInteractionEnabled = YES;
    }
}

-(void) hidePaintLayer
{
    self.userInteractionEnabled = NO;
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
