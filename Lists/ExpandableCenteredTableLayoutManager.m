//
//  ExpandableCenteredTableViewLayoutManager.m
//  Lists
//
//  Created by Ali Fathalian on 5/12/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ExpandableCenteredTableLayoutManager.h"

@interface ExpandableCenteredTableLayoutManager()

@property id<ListDataSourceIndexer> indexer;

@end
@implementation ExpandableCenteredTableLayoutManager

-(id) initWithDivider:(CGFloat)dividerSpace
       andItemIndexer:(id<ListDataSourceIndexer>) indexer
{
    self = [super initWithDivider:dividerSpace];
    if (self)
    {
        self.indexer = indexer;
    }
    return self;
}


- (CGRect) frameForRowforIndex:(int) index
          inSuperView:(UIView *) superView
{
    
    int numberOfSubITemsAbove = [self.indexer numberOfSubItemsAfterIndex:index];
    int numberOfItemsAbove = [self.indexer numberOfItemsBeforeIndex:index];
    CGFloat startY = numberOfItemsAbove * (self.rowHeight + self.rowDivider) +
                     numberOfSubITemsAbove * self.subItemHeight +
                     self.verticalOffsetFromTop;
    CGPoint origin = CGPointMake(superView.bounds.size.width/2 - self.rowWidth/2, startY);
    return CGRectMake(origin.x, origin.y, self.rowWidth, self.rowHeight);
}

-(int) binarySearchForIntersectingRectWithFrame:(CGRect) frame
                                         InView:(UIView *) superView
{
    int numberOfIndexes = [self.indexer numberOfIndexes];
    int begin = 0;
    int end = numberOfIndexes - 1;
    while (begin <= end)
    {
        int mid = (begin + end) /2;
        CGRect midRect = [self frameForRowforIndex:mid inSuperView:superView];
        if (CGRectIntersectsRect(frame, midRect))
        {
            return mid;
        }
        else if (midRect.origin.y < frame.origin.y)
        {
            begin = mid +1;
        }
        else
        {
            end = mid - 1;
        }
    }
    
    NSLog(@"lowestAndHighestIndex-Non of the subViews intersect with the frame");
    @throw NSInternalInconsistencyException;
}

-(NSArray *) lowestAndHighestIndexForFrame:(CGRect)frame
                               inSuperView:(UIView *) superView
{
    //a binary search to find one rectangle that intersects with the frame
    int mid = [self binarySearchForIntersectingRectWithFrame:frame
                                                      InView:superView];
    //Now that we have found a rect that intersects go up until you find the
    //lowest index
    //moving index is the first index that falls out of the bounds
    int numberOfIndexes = [self.indexer numberOfIndexes];
    int movingIndex = mid-1;
    
    if (movingIndex >= 0)
    {
        CGRect movingRect = [self frameForRowforIndex:movingIndex
                                          inSuperView:superView];
        while(CGRectIntersectsRect(frame, movingRect) && movingIndex >= 0)
        {
            movingIndex--;
            movingRect = [self frameForRowforIndex:movingIndex
                                       inSuperView:superView];
        }
    }
    
    int lowestIndex = movingIndex + 1;
    NSNumber * lowestIndexNumber = [NSNumber numberWithInt:lowestIndex];
    
    //now find the highest index
    movingIndex = mid + 1;
    
    if (movingIndex < numberOfIndexes)
    {
        CGRect movingRect = [self frameForRowforIndex:movingIndex
                                          inSuperView:superView];
        while(CGRectIntersectsRect(frame, movingRect) && movingIndex < numberOfIndexes)
        {
            movingIndex++;
            movingRect = [self frameForRowforIndex:movingIndex
                                       inSuperView:superView];
        }
    }
    
    //bump the highest index to have one reserver not showing so that delete animations
    //will be smooth
    int highestIndex = movingIndex + 1;
    NSNumber * highestIndexNumber = [NSNumber numberWithInt:highestIndex];
    
    //NSLog(@"Lowest Index %@, Highest Index %@", lowestIndexNumber, highestIndexNumber);
    return @[lowestIndexNumber, highestIndexNumber];
}

@end
