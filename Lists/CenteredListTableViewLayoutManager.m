//
//  MainScreenListLayout.m
//  Lists
//
//  Created by Ali Fathalian on 4/8/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "CenteredListTableViewLayoutManager.h"

@implementation CenteredListTableViewLayoutManager

#define VER_OFFSET_TOP 100
#define ROW_SIZE_WIDTH 500
#define ROW_SIZE_HEIGHT 50
#define ROW_DIVIDER 5

- (CGRect) frameForRowforIndex:(int) index
          inSuperView:(UIView *) superView;
{
    
    CGPoint origin = CGPointMake(superView.bounds.size.width/2 - ROW_SIZE_WIDTH/2,
                                 VER_OFFSET_TOP + index * ROW_SIZE_HEIGHT + index * ROW_DIVIDER);
    return CGRectMake(origin.x, origin.y, ROW_SIZE_WIDTH, ROW_SIZE_HEIGHT);
}

- (CGPoint) originForFrameAfterFrame:(CGRect) frame
{
    CGPoint point = CGPointMake(frame.origin.x,
                                frame.origin.y + frame.size.height + ROW_DIVIDER);
    return point;
}

- (int) lowestRowIndexInFrame:(CGRect) frame
{
    CGFloat topVisiblePart = CGRectGetMinY(frame);
    CGFloat effectiveBottomVisiblePart = topVisiblePart - VER_OFFSET_TOP;
    //we give one row as a buffer
    int result = floorf(effectiveBottomVisiblePart / (ROW_SIZE_HEIGHT + ROW_DIVIDER)) - 1;
    return MAX(result,0);
}

- (int) highestRowIndexInFrame:(CGRect) frame
{
    CGFloat bottomVisiblePart =CGRectGetMaxY(frame);
    CGFloat effectiveBottomVisiblePart = bottomVisiblePart - VER_OFFSET_TOP;
    //we give one row as a buffer
    int result = floorf((effectiveBottomVisiblePart - 1)/ (ROW_SIZE_HEIGHT + ROW_DIVIDER))+1;
    return result;
}

@end
