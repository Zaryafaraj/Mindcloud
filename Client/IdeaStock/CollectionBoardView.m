//
//  CollectionBoardView.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/15/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionBoardView.h"
#import "PaintLayerView.h"
#import "ThemeFactory.h"
#import "CollectionBoardState.h"

@interface CollectionBoardView()


@property (nonatomic, strong) NSMutableArray * viewGrid;

/* all the drawings who have been touched */
@property (nonatomic, strong) NSMutableDictionary * allDrawings;

@property (nonatomic, strong) NSMutableSet * touchedViews;

@property (nonatomic, strong) NSMutableSet * viewsWithoutTouchEnded;

//To make sure that we communicate views that a vlaid undo happened on them
//and became empty as opposed to views that a undo for an artifact happend to them. This is an NSSet keyed on NSNumber which is the index of the view
@property (nonatomic, strong) NSMutableSet * validUndoViews;

@property NSInteger orderIndex;

@property (nonatomic, strong) NSMutableSet * overlappingViewsFromLastTouch;

//used to determine double tap when gesture recognizers are disabled
@property (nonatomic) CGPoint lastTouchBeganLocation;
@property (nonatomic, strong) PaintLayerView * lastTouchBeganView;

@property (nonatomic) BOOL hasUnsavedClear;

@property (nonatomic) NSTimeInterval lastTouchTime;

@property (nonatomic, strong) CollectionBoardState * stateBeforeClear;

@property (nonatomic, assign) BOOL lastActionWasClear;

/*! keys are orderIndex, valued on NSSet of PaintLayerViews */
@property (nonatomic, strong) NSMutableDictionary * redoableViews;

@property (nonatomic, assign) BOOL hasRedos;

@end

@implementation CollectionBoardView

#define DEFAULT_BRUSH_WIDTH 3.0f

@synthesize eraseModeEnabled = _eraseModeEnabled;

-(void) setEraseModeEnabled:(BOOL)eraseModeEnabled
{
    _eraseModeEnabled = eraseModeEnabled;
    for (PaintLayerView * view in self.viewGrid)
    {
        view.eraseModeEnabled = eraseModeEnabled;
    }
}

-(void) setCurrentWidth:(CGFloat)currentWidth
{
    _currentWidth = currentWidth;
    for(PaintLayerView * view in self.viewGrid)
    {
        view.lineWidth = currentWidth;
    }
}

@synthesize currentColor = _currentColor;
-(UIColor *) currentColor
{
    return _currentColor;
}
-(void) setCurrentColor:(UIColor *)currentColor
{
    _currentColor = currentColor;
    for(PaintLayerView * view in self.viewGrid)
    {
        view.lineColor = currentColor;
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
    self.allDrawings = [NSMutableDictionary dictionary];
    self.touchedViews = [NSMutableSet set];
    //haven't started drawing anything
    self.orderIndex = -1;
    self.multipleTouchEnabled = YES;
    self.viewsWithoutTouchEnded = [NSMutableSet set];
    self.overlappingViewsFromLastTouch = [NSMutableSet set];
    self.validUndoViews = [NSMutableSet set];
    self.hasUnsavedClear = NO;
    self.redoableViews = [NSMutableDictionary dictionary];
    self.hasRedos = NO;
}


//have done performance tests and reached 100. Do not change
#define GRID_CELL_SIZE 400
#define VIEW_WIDTH 2000
#define VIEW_HEIGHT 2000

-(void) configurePaintLayer
{
    
    _currentColor = [[ThemeFactory currentTheme] defaultColorForDrawing];
    _currentWidth = DEFAULT_BRUSH_WIDTH;
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
//            paintLayer.layer.borderWidth = 2.0;
//            paintLayer.layer.borderColor = [UIColor blackColor].CGColor;
            paintLayer.multipleTouchEnabled = YES;
            paintLayer.clipsToBounds = NO;
            paintLayer.lineWidth = self.currentWidth;
            paintLayer.lineColor = self.currentColor;
            paintLayer.colIndex = col;
            paintLayer.rowIndex = row;
            paintLayer.backgroundColor = [UIColor clearColor];
            paintLayer.userInteractionEnabled = NO;
            [self addSubview:paintLayer];
            [self.viewGrid addObject:paintLayer];
            int gridIndex = [self.viewGrid count] - 1;
            paintLayer.gridIndex = gridIndex;
        }
    }
}

-(void) setBounds:(CGRect)bounds
{
    //For some reason a method called applyISEngineLayoutValues from UIView Geomatry calls this with a value of 3k. I don't have time right now
    //to investigate why that happens so I am disabling setBounds for no
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

-(void) redo
{
    if (self.hasRedos && self.orderIndex >= -1)
    {
        NSNumber * indexObj = [NSNumber numberWithInteger:(self.orderIndex+1)];
        NSMutableSet * lastViews = self.redoableViews[indexObj];
        if (lastViews)
        {
            
            self.orderIndex++;
            for(PaintLayerView * view in lastViews)
            {
                
                [self.touchedViews addObject:view];
                NSNumber * viewIndex = [NSNumber numberWithInt: view.gridIndex];
                [self.validUndoViews removeObject:viewIndex];
                [view redoIndex:self.orderIndex];
            }
            
            [self.redoableViews removeObjectForKey:indexObj];
            self.allDrawings[indexObj] = lastViews;
            
            id<CollectionBoardDelegate> temp = self.delegate;
            if (temp)
            {
                [temp didFinishDrawingOnScreen];
            }
        }
    }
}

-(NSInteger) undo:(BOOL) isUnwantedArtifact
{
    if (self.lastActionWasClear)
    {
        [self restoreBoardFromState:self.stateBeforeClear];
        self.stateBeforeClear = nil;
        self.lastActionWasClear = NO;
        for(PaintLayerView * view in self.viewGrid)
        {
            [view undoClearContent];
        }
        return self.orderIndex;
    }
    
    if (self.orderIndex < 0 ||
        self.orderIndex > self.allDrawings.count)
    {
        self.orderIndex = self.allDrawings.count - 1;
    }
    if (self.orderIndex >= 0 &
        self.orderIndex < self.allDrawings.count)
    {
        NSNumber * orderIndxObj = [NSNumber numberWithInteger:self.orderIndex];
        NSSet * touchedViewsInLastOrder = self.allDrawings[orderIndxObj];
        BOOL didChangeDrawings = NO;
        NSMutableSet * redoableViews = [NSMutableSet set];
        
        for (PaintLayerView * view in touchedViewsInLastOrder)
        {
            [view undoIndex:self.orderIndex];
            if (!isUnwantedArtifact)
            {
                [self.touchedViews addObject:view];
                didChangeDrawings = YES;
                NSNumber * indexObj = [NSNumber numberWithInt: view.gridIndex];
                [self.validUndoViews addObject:indexObj];
                self.hasRedos = YES;
                [redoableViews addObject:view];
            }
        }
        
        if (!isUnwantedArtifact && self.hasRedos)
        {
            NSNumber * indexObj = [NSNumber numberWithInt:self.orderIndex];
            self.redoableViews[indexObj] = redoableViews;
        }
    
        [self.allDrawings removeObjectForKey:orderIndxObj];
        NSInteger undidOrder = self.orderIndex;
        self.orderIndex--;
//        NSLog(@"1-Decreasing order index %d", self.orderIndex);
        if (didChangeDrawings)
        {
            id<CollectionBoardDelegate> temp = self.delegate;
            if (temp)
            {
                [temp didFinishDrawingOnScreen];
            }
            return undidOrder;
        }
        else
        {
            return -1;
        }
    }
    else
    {
        return -1;
    }
}

-(void) redoItemsAtOrderIndex:(NSArray *) orderIndexes
{
    
}

-(void) undoItemsAtOrderIndex:(NSArray *) orderIndexes
{
    BOOL didChangeDrawings = NO;
    for(NSString * numStr in orderIndexes)
    {
       
        NSInteger  numInt = [numStr integerValue];
        NSNumber * num = [NSNumber numberWithInteger:numInt];
        if (self.orderIndex >= 0 &&
            self.orderIndex < self.allDrawings.count)
        {
            NSSet * touchedViewsInLastOrder = self.allDrawings[num];
            for (PaintLayerView * view in touchedViewsInLastOrder)
            {
                [view undoIndex:num.integerValue];
                [self.touchedViews addObject:view];
                didChangeDrawings = YES;
                NSNumber * indexObj = [NSNumber numberWithInt: view.gridIndex];
                [self.validUndoViews addObject:indexObj];
            }
            
            if (self.orderIndex == numInt)
            {
                self.orderIndex--;
//                NSLog(@"2-Decreasing order index %d", self.orderIndex);
            }
        
            [self.allDrawings removeObjectForKey:num];
        }
    }
    
    if (didChangeDrawings)
    {
        id<CollectionBoardDelegate> temp = self.delegate;
        if (temp)
        {
            [temp didFinishDrawingOnScreen];
        }
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
    if (view == nil) return;
    NSNumber * orderIndexObj = [NSNumber numberWithInteger:self.orderIndex];
    if (!self.allDrawings[orderIndexObj])
    {
        NSMutableSet * touchedViews = [NSMutableSet set];
        self.allDrawings[orderIndexObj] = touchedViews;
    }
    
    NSMutableSet * touchedViewsInOrder = self.allDrawings[orderIndexObj];
    [touchedViewsInOrder addObject:view];
    [self.touchedViews addObject:view];
}

-(void) touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    
    //we only handle single touch gestures. the other gestures
    //will be handled by the respective views
    id<CollectionBoardDelegate> temp = self.delegate;
    if (temp)
    {
        BOOL didCauseCancelation = [temp screenTapped];
        if (didCauseCancelation)
        {
            return;
        }
    }
    if (event.allTouches.count > 1)
    {
        return;
    }
    
    if (!self.drawingEnabled) return;
    
    UITouch * touch = [touches anyObject];
    
    if (temp)
    {
        [temp willBeginDrawingOnScreen];
    }
    
    if (touches.count > 1) return;
    
    
    self.orderIndex++;
//    NSLog(@"3-Increasing order %d", self.orderIndex);
    
    CGPoint location = [touch locationInView:self];
    PaintLayerView * touchedLayer = [self getGridCellForTouchLocation:location];
    [self addTouchedItem:touchedLayer];
    [touchedLayer parentTouchBegan:touch withEvent:event andOrderIndex:self.orderIndex];
    //touchedLayer.backgroundColor = [UIColor whiteColor];
    [self fillOverlappingViewsForTouchLocation:location
                                      forTouch:touch
                                      andEvent:event
                                 andOrderIndex:self.orderIndex];
    if (touchedLayer != nil)
    {
        [self.viewsWithoutTouchEnded addObject:touchedLayer];
        
        self.lastTouchBeganLocation = location;
        self.lastTouchBeganView = touchedLayer;
    }
}

-(void) touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    
//    NSLog(@"Ended");
    UITouch * touch = [touches anyObject];
    if (event.allTouches.count > 1)
    {
        return;
    }
//    if (touch.tapCount == 2)
//    {
//        return;
//    }
    
    if (!self.drawingEnabled) return;
    
    CGPoint touchLocation = [touch locationInView:self];
    PaintLayerView * currentTouchedLayer = [self getGridCellForTouchLocation:touchLocation];
    
    CGPoint currentInSelf = [touch locationInView:self];
    CGPoint currentInChild = [currentTouchedLayer convertPoint:currentInSelf fromView:self];
   
    [currentTouchedLayer parentTouchExitedTheView:touch
                                 withCurrentPoint:currentInChild
                                    andOrderIndex:self.orderIndex];
    //currentTouchedLayer.backgroundColor = [UIColor darkGrayColor];
    NSSet * overLapping = [self getOverlappingViewsForPoint:touchLocation];
    for(PaintLayerView * view in overLapping)
    {
        CGPoint currentInOverlapping = [view convertPoint:currentInSelf fromView:self];
        if (view.isTrackingTouch)
        {
            [view parentTouchExitedTheView:touch
                          withCurrentPoint:currentInOverlapping
                             andOrderIndex:self.orderIndex];
        }
        //view.backgroundColor = [UIColor greenColor];
        [self.viewsWithoutTouchEnded removeObject:view];
//        view.backgroundColor = [UIColor yellowColor];
    }
    
    id<CollectionBoardDelegate> temp = self.delegate;
    if (temp)
    {
        [temp didFinishDrawingOnScreen];
    }
    if (currentTouchedLayer == nil)
    {
        return;
    }
    
    [self.viewsWithoutTouchEnded removeObject:currentTouchedLayer];
    
    //reset redoable objects
    if (self.hasRedos)
    {
        self.hasRedos = NO;
        [self.redoableViews removeAllObjects];
    }
}

-(void) cleanupUnwantedArtifacts
{
    if (self.viewsWithoutTouchEnded.count > 0)
    {
        
        BOOL didCleanSomething = NO;
        for (PaintLayerView * layer in self.viewsWithoutTouchEnded)
        {
            didCleanSomething |= [layer cleanupContentBeingDrawn];
        }
        
        if (didCleanSomething)
        {
            self.orderIndex--;
//            NSLog(@"4-decreasing order %d", self.orderIndex);
        }
    }
    for (PaintLayerView * layer in self.overlappingViewsFromLastTouch)
    {
        // [layer cleanupContentBeingDrawn];
        //layer.backgroundColor = [UIColor yellowColor];
    }
    [self.overlappingViewsFromLastTouch removeAllObjects];
    
}

-(void) touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    
    if (event.allTouches.count > 1)
    {
        return;
    }
    if (!self.drawingEnabled) return;
    
    if (touches.count > 1) return;
    
    UITouch * touch = [touches anyObject];
    
    CGPoint touchLocation = [touch locationInView:self];
    CGPoint prevLocation = [touch previousLocationInView:self];
    PaintLayerView * currentTouchedLayer = [self getGridCellForTouchLocation:touchLocation];
    
    PaintLayerView * prevTouchedLayer = [self getGridCellForTouchLocation:prevLocation];
    
    
    
    [prevTouchedLayer parentTouchMoved:touch withEvent:event andOrderIndex:self.orderIndex];
    
    //prevTouchedLayer.backgroundColor = [UIColor blueColor];
    [self addTouchedItem:currentTouchedLayer];
    
    //sometimes if we are moving around the border and the width of the line
    //is big enough we might enter another view without actually touching that
    //view. Using this array we can track those incidents and draw incomplete
    //paths
    
    if (prevTouchedLayer == currentTouchedLayer)
    {
        [prevTouchedLayer parentTouchMoved:touch withEvent:event andOrderIndex:self.orderIndex];
//        prevTouchedLayer.backgroundColor = [UIColor purpleColor];
        
    }
    else
    {
        
        CGPoint currentInSelf = [touch locationInView:self];
        CGPoint currentInChild = [prevTouchedLayer convertPoint:currentInSelf fromView:self];
        
        if (prevTouchedLayer == nil) return;
        
        [self addTouchedItem:prevTouchedLayer];
        
        [prevTouchedLayer parentTouchExitedTheView:touch withCurrentPoint:currentInChild andOrderIndex:self.orderIndex];
        [self.viewsWithoutTouchEnded removeObject:prevTouchedLayer];
        CGPoint prevPoint1 = prevTouchedLayer.previousPoint1;
        CGPoint prevPoint2 = prevTouchedLayer.previousPoint2;
        CGPoint prevPoint1InSelf = [self convertPoint:prevPoint1
                                             fromView:prevTouchedLayer];
        CGPoint prevPoint2InSelf = [self convertPoint:prevPoint2
                                             fromView:prevTouchedLayer];
        //if the start is in one view grid and the end is in another grid the touch sensors have missed
        // at least a grid between. find those grids and ask them to draw a straight line
        if (![self areViewsAdjacentInGridForView:prevTouchedLayer andView:currentTouchedLayer])
        {
            NSArray * middleViews = [self getCandidateMiddleViewsForStartingPoint:prevLocation
                                                                      andEndPoint:touchLocation];
//            currentTouchedLayer.backgroundColor = [UIColor greenColor];
//            prevTouchedLayer.backgroundColor = [UIColor purpleColor];
            for(PaintLayerView * view in middleViews)
            {
                if (view == currentTouchedLayer) continue;
                
                CGPoint prevPoint1InMiddle = [view convertPoint:prevPoint1InSelf
                                                               fromView:self];
        
                CGPoint prevPoint2InMiddle = [view convertPoint:prevPoint2InSelf fromView:self];
                
                CGPoint currentInMiddle = [view convertPoint:currentInSelf fromView:self];
//                view.backgroundColor = [UIColor blueColor];
                [view parentTouchEnteredTheView:touch
                             withPreviousPoint1:prevPoint1InMiddle
                              andPreviousPoint2:prevPoint2InMiddle
                                  andOrderIndex:self.orderIndex];
                [view parentTouchExitedTheView:touch
                              withCurrentPoint:currentInMiddle
                                 andOrderIndex:self.orderIndex];
                [self addTouchedItem:view];
            }
        }
        
        CGPoint prevPoint1InCurrent = [currentTouchedLayer convertPoint:prevPoint1InSelf
                                                               fromView:self];
        
        CGPoint prevPoint2InCurrent = [currentTouchedLayer convertPoint:prevPoint2InSelf fromView:self];
        [currentTouchedLayer parentTouchEnteredTheView:touch withPreviousPoint1:prevPoint1InCurrent
                                     andPreviousPoint2:prevPoint2InCurrent andOrderIndex:self.orderIndex];
        
        //currentTouchedLayer.backgroundColor = [UIColor whiteColor];
    }
    
    [self fillOverlappingViewsForTouchLocation:prevLocation
                                      forTouch:touch
                                      andEvent:event
                                 andOrderIndex:self.orderIndex];
    [self fillOverlappingViewsForTouchLocation:touchLocation
                                      forTouch:touch
                                      andEvent:event
                                 andOrderIndex:self.orderIndex];
}


-(int) getGridIndexForTouchLocation:(CGPoint) touchLocation
{
    int column = touchLocation.x / GRID_CELL_SIZE;
    int row = touchLocation.y / GRID_CELL_SIZE;
    int index = [self arrayIndexForColumn:column andRow:row];
    return index;
}

-(PaintLayerView *) getGridCellForTouchLocation:(CGPoint) touchLocation
{
    int index = [self getGridIndexForTouchLocation:touchLocation];
    if (index < 0 || index > self.viewGrid.count - 1) return nil;
    PaintLayerView * layer = self.viewGrid[index];
    return layer;
}

-(BOOL) areViewsAdjacentInGridForView:(PaintLayerView *) prevView andView:(PaintLayerView * ) currView
{
    
    //There are six adjacent cells to each cell in the grid
    //
    //            -----------------------------------------------------------
    //            |  X - COL_SIZE -1   |  X - COL_SIZE  |  X - COL_SIZE + 1  |
    //            -----------------------------------------------------------
    //            |        X - 1       |        X       |        X + 1       |
    //            -----------------------------------------------------------
    //            |  X + COL_SIZE -1   |  X + COL_SIZE  |  X + COL_SIZE + 1  |
    //            -----------------------------------------------------------
    
    if (prevView.rowIndex == currView.rowIndex)
    {
        if (prevView.colIndex == currView.colIndex ||
            prevView.colIndex + 1 == currView.colIndex ||
            prevView.colIndex - 1 == currView.colIndex)
        {
            return true;
        }
    }
    if (prevView.colIndex == currView.colIndex)
    {
        if (prevView.rowIndex == currView.rowIndex ||
            prevView.rowIndex + 1 == currView.rowIndex ||
            prevView.rowIndex - 1 == currView.rowIndex)
        {
            return true;
        }
    }
    
//Although the for diameter adjacent views are theoratically
//adjacent because geometrically speaking those two views are
//attached only by a single point, then statistically it is
//impossible for a line to enter them from that point. What usually happens is that
//the line will go to another view and then come back to them
//    if (prevView.colIndex + 1 == currView.colIndex)
//    {
//        prevView.backgroundColor = [UIColor redColor];
//        if (prevView.rowIndex + 1 == currView.rowIndex ||
//            prevView.rowIndex - 1 == currView.rowIndex)
//        {
//            prevView.backgroundColor = [UIColor brownColor];
//            return true;
//        }
//    }
//    if (prevView.colIndex - 1 == currView.colIndex)
//    {
//        prevView.backgroundColor = [UIColor yellowColor];
//        if (prevView.rowIndex + 1 == currView.rowIndex ||
//            prevView.rowIndex - 1 == currView.rowIndex)
//        {
//            return true;
//        }
//    }
    
    return false;
}

/*! If the starting point and endpoint are not from adjust cells in the grid
    There must be some middle views between them. There are variety of straight lines that
    can go from startingPoint to endPoint. 
    This method returns and NSArray of all those candidate views that the straight line could fall inside of
 */
-(NSArray *) getCandidateMiddleViewsForStartingPoint:(CGPoint) startingPoint
                                         andEndPoint:(CGPoint) endPoint
{
    int startIndex = [self getGridIndexForTouchLocation:startingPoint];
    
    int colSize = VIEW_WIDTH / GRID_CELL_SIZE;
    NSMutableArray * result = [NSMutableArray array];
    //we are not catching everything just the minimum number of candidates to make the line look smooth
    if (endPoint.x > startingPoint.x)
    {
        int immediateRight = startIndex + 1;
        
        if (immediateRight >= 0 && immediateRight < self.viewGrid.count)
        {
            [result addObject:self.viewGrid[immediateRight]];
        }
        if (endPoint.y < startingPoint.y)
        {
            int rightAndAbove = startIndex - colSize + 1;
            
            if (rightAndAbove >=0 && rightAndAbove < self.viewGrid.count)
            {
                [result addObject:self.viewGrid[rightAndAbove]];
            }
        }
        else if (endPoint.y > startingPoint.y)
        {
            int rightAndBelow = startIndex + colSize + 1;
            if (rightAndBelow >=0 && rightAndBelow < self.viewGrid.count)
            {
                [result addObject:self.viewGrid[rightAndBelow]];
            }
        }
    }
    
    //we don't add anything in case they are equals
    else if (endPoint.x < startingPoint.x)
    {
        int immediateLeft = startIndex - 1;
        if (immediateLeft >= 0 && immediateLeft < self.viewGrid.count)
        {
            [result addObject:self.viewGrid[immediateLeft]];
        }
        if (endPoint.y < startingPoint.y)
        {
            int leftAndAbove = startIndex - colSize - 1;
            if (leftAndAbove >=0 && leftAndAbove < self.viewGrid.count)
            {
                [result addObject:self.viewGrid[leftAndAbove]];
            }
        }
        else if (endPoint.y > startingPoint.y)
        {
            int leftAndBelow = startIndex + colSize - 1;
            if (leftAndBelow >=0 && leftAndBelow < self.viewGrid.count)
            {
                [result addObject:self.viewGrid[leftAndBelow]];
            }
        }
    }
    
    //above and below
    if (endPoint.y < startingPoint.y)
    {
        int immediateAbove = startIndex - colSize;
        if (immediateAbove >=0 && immediateAbove < self.viewGrid.count)
        {
            [result addObject:self.viewGrid[immediateAbove]];
        }
    }
    else if (endPoint.y > startingPoint.y)
    {
        int immediateBelow = startIndex + colSize;
        if (immediateBelow >=0 && immediateBelow < self.viewGrid.count)
        {
            [result addObject:self.viewGrid[immediateBelow]];
        }
    }
    
    return result;
}

-(void) fillOverlappingViewsForTouchLocation:(CGPoint) location
                                    forTouch:(UITouch *) touch
                                    andEvent:(UIEvent *) event
                               andOrderIndex:(NSInteger) orderIndex
{
    
    NSSet * candidates = [self getOverlappingViewsForPoint:location];
    
    //first make sure that views that overlapped before and are now not overlapping
    //are exited correctly
    [self.overlappingViewsFromLastTouch minusSet:candidates];
    
    for (PaintLayerView * view in self.overlappingViewsFromLastTouch)
    {
        
        CGPoint currentInChild = [view convertPoint:location fromView:self];
        if (view.isTrackingTouch)
        {
           [view parentTouchExitedTheView:touch
                         withCurrentPoint:currentInChild
                            andOrderIndex:self.orderIndex];
            //[self.viewsWithoutTouchEnded removeObject:view];
            //view.backgroundColor = [UIColor greenColor];
        }
    }
    
    for(PaintLayerView * view in candidates)
    {
        [self addTouchedItem:view];
        if (view.isTrackingTouch)
        {
            [view parentTouchMoved:touch
                         withEvent:event
                     andOrderIndex:orderIndex];
            //view.backgroundColor = [UIColor blackColor];
            [self.overlappingViewsFromLastTouch addObject:view];
            [self.viewsWithoutTouchEnded addObject:view];
            //view.backgroundColor = [UIColor greenColor];
            
        }
        else
        {
            
            PaintLayerView * prevTouchedLayer = [self getGridCellForTouchLocation:location];
            CGPoint prevPoint1 = prevTouchedLayer.previousPoint1;
            CGPoint prevPoint2 = prevTouchedLayer.previousPoint2;
            CGPoint prevPoint1InSelf = [self convertPoint:prevPoint1
                                                 fromView:prevTouchedLayer];
            CGPoint prevPoint2InSelf = [self convertPoint:prevPoint2
                                                 fromView:prevTouchedLayer];
            CGPoint prevPoint1InCurrent = [view convertPoint:prevPoint1InSelf
                                                                   fromView:self];
            
            CGPoint prevPoint2InCurrent = [view convertPoint:prevPoint2InSelf fromView:self];
            [view parentTouchEnteredTheView:touch
                         withPreviousPoint1:prevPoint1InCurrent
                          andPreviousPoint2:prevPoint2InCurrent
                              andOrderIndex:orderIndex];
            //view.backgroundColor = [UIColor blueColor];
            [self.viewsWithoutTouchEnded addObject:view];
            [self.overlappingViewsFromLastTouch addObject:view];
        }
    }
    
}

-(NSSet *) getOverlappingViewsForPoint:(CGPoint) location
{
    NSMutableSet * candidates = [NSMutableSet set];
    CGFloat halfLineWidth = self.currentWidth / 2;
    //get the end of the point after adding width
    NSValue * above = [NSValue valueWithCGPoint:CGPointMake(location.x, location.y - halfLineWidth)];
    NSValue * below = [NSValue valueWithCGPoint:CGPointMake(location.x, location.y + halfLineWidth)];
    NSValue * left = [NSValue valueWithCGPoint: CGPointMake(location.x - halfLineWidth, location.y)];
    NSValue * right = [NSValue valueWithCGPoint:CGPointMake(location.x + halfLineWidth, location.y)];
    NSValue * aboveLeft = [NSValue valueWithCGPoint:CGPointMake(location.x - halfLineWidth, location.y - halfLineWidth)];
    NSValue * aboveRight = [NSValue valueWithCGPoint:CGPointMake(location.x + halfLineWidth, location.y - halfLineWidth)];
    NSValue * belowLeft = [NSValue valueWithCGPoint:CGPointMake(location.x - halfLineWidth, location.y + halfLineWidth)];
    NSValue * belowRight = [NSValue valueWithCGPoint:CGPointMake(location.x + halfLineWidth, location.y + halfLineWidth)];
    NSArray * suspects = @[above,
                           below,
                           left,
                           right,
                           aboveLeft,
                           aboveRight,
                           belowLeft,
                           belowRight];
    for (NSValue * value in suspects)
    {
        CGPoint loc = value.CGPointValue;
        PaintLayerView * view = [self getGridCellForTouchLocation:loc];
        if (view)
        {
            [candidates addObject:view];
        }
    }
    return candidates;
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
    self.drawingEnabled = YES;
    for (UIView * view in self.viewGrid)
    {
        view.userInteractionEnabled = YES;
    }
}

-(void) hidePaintLayer
{
    self.drawingEnabled = NO;
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
    self.stateBeforeClear = [self captureCurrentBoardState];
    self.lastActionWasClear = YES;
    
    for (PaintLayerView * view in self.viewGrid)
    {
        [view clearContent];
        [self.touchedViews addObject:view];
        NSNumber * index = [NSNumber numberWithInt:view.gridIndex];
        [self.validUndoViews addObject:index];
    }
    [self.viewsWithoutTouchEnded removeAllObjects];
    id<CollectionBoardDelegate> temp = self.delegate;
    if (temp)
    {
        [temp didFinishDrawingOnScreen];
    }
    self.hasUnsavedClear = YES;
    [self.allDrawings removeAllObjects];
    [self.touchedViews removeAllObjects];
    [self.viewsWithoutTouchEnded removeAllObjects];
    [self.validUndoViews removeAllObjects];
    [self.overlappingViewsFromLastTouch removeAllObjects];
    self.orderIndex = -1;
    
    //reset redoable objects
    if (self.hasRedos)
    {
        self.hasRedos = NO;
        [self.redoableViews removeAllObjects];
    }
}

-(CollectionBoardState *) captureCurrentBoardState
{
    CollectionBoardState * state = [[CollectionBoardState alloc] init];
    state.touchedViews = [self.touchedViews mutableCopy];
    state.validUndoView = [self.validUndoViews mutableCopy];
    state.allDrawings = [self.allDrawings mutableCopy];
    state.overlappingViewsFromLastTouch = [self.overlappingViewsFromLastTouch mutableCopy];
    state.orderIndex = self.orderIndex;
    return state;
}

-(void) restoreBoardFromState:(CollectionBoardState *) state
{
    self.touchedViews = state.touchedViews;
    self.validUndoViews = state.validUndoView;
    self.allDrawings = state.allDrawings;
    self.overlappingViewsFromLastTouch = state.overlappingViewsFromLastTouch;
    self.orderIndex = state.orderIndex;
}

-(void) resetTouchRecorder
{
    [self.touchedViews removeAllObjects];
    [self.validUndoViews removeAllObjects];
    self.hasUnsavedClear = NO;
}

-(ScreenDrawing *) getNewScreenDrawingsWithRebasing:(BOOL) shouldRebase
{
    //now figure out what is the diff between the last time and now
    NSMutableDictionary * layerDiffs = [NSMutableDictionary dictionary];
    for(PaintLayerView * layer in self.touchedViews)
    {
        NSDictionary * newDrawings = [layer getNewDrawings];
        NSNumber * gridNumber = [NSNumber numberWithInt:layer.gridIndex];
        layerDiffs[gridNumber] = newDrawings;
        if (shouldRebase)
        {
            [layer resetNewTracesHeadToNow];
        }
    }
    
    ScreenDrawing * answer =  [[ScreenDrawing alloc] initWithGridDictionary:layerDiffs
                                                            andUndidIndexes:[self.validUndoViews copy]];
    if (self.hasUnsavedClear)
    {
        answer.hasClear = YES;
    }
    return answer;
}

-(ScreenDrawing *) getAllScreenDrawings
{
    NSMutableDictionary * layerDrawings = [NSMutableDictionary dictionary];
    for (PaintLayerView * layer in self.viewGrid)
    {
        NSDictionary * allDrawings = [layer getAllDrawings];
        NSNumber * gridNumber = [NSNumber numberWithInt:layer.gridIndex];
        layerDrawings[gridNumber] = allDrawings;
    }
    
    ScreenDrawing * answer = [[ScreenDrawing alloc] initWithGridDictionary:layerDrawings andUndidIndexes:[self.validUndoViews copy]];
    return answer;
}

-(void) setAllDrawingContentTo:(ScreenDrawing *) allDrawings
{
    int maxOrderIndex = self.orderIndex;
    for (int i = 0 ; i < self.viewGrid.count; i++)
    {
        NSDictionary * drawings = [allDrawings getDrawingsForGridIndex:i];
        if (drawings)
        {
            PaintLayerView * layer = self.viewGrid[i];
            [layer setAllDrawingsTo:drawings];
            int lastOrderIndex = [layer getMaxOrderIndex];
            if (lastOrderIndex > maxOrderIndex)
            {
                maxOrderIndex = lastOrderIndex;
            }
        }
    }
    
    if (self.orderIndex != maxOrderIndex)
    {
        self.orderIndex = maxOrderIndex++;
    }
    
}

-(void) applyDiffDrawingContentFrom:(ScreenDrawing *) diffDrawings
{
    NSArray * avaiableIndices = [diffDrawings getAvailableGridIndices];
    
    int maxOrderIndex = self.orderIndex;
    for (NSNumber * index in avaiableIndices)
    {
        int i = index.intValue;
        if (self.viewGrid[i])
        {
            PaintLayerView * layer = self.viewGrid[i];
            NSDictionary * drawings = [diffDrawings getDrawingsForGridIndex:i];
            for(NSNumber * orderIndex in drawings.allKeys)
            {
                if (!self.allDrawings[orderIndex])
                {
                    self.allDrawings[orderIndex] = [NSMutableSet set];
                }
                NSMutableSet * drawingsInOrder = self.allDrawings[orderIndex];
                [drawingsInOrder addObject:layer];
            }
            [layer applyDiffDrawingContentFrom:drawings];
            int lastOrderIndex = [layer getMaxOrderIndex];
            if (lastOrderIndex > maxOrderIndex)
            {
                maxOrderIndex = lastOrderIndex;
            }
        }
    }
    
    if (self.orderIndex != maxOrderIndex)
    {
        self.orderIndex = maxOrderIndex++;
    }
    
    
    
}

-(void) debug_captureBezier
{
    PaintLayerView * layer = self.viewGrid[0];
    [layer debug_writeBezierPathToFile];
}
@end
