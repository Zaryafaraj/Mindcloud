//
//  MainScreenListLayout.m
//  Lists
//
//  Created by Ali Fathalian on 4/8/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "MainScreenListLayout.h"

@implementation MainScreenListLayout

#define HOR_OFFSET_PORTRAIT_LEFT 100
#define HOR_OFFSET_PORTRAIT_RIGHT 100
#define VER_OFFSET_PORTRAIT_TOP 100
#define VER_OFFSET_PORTRAIT_BOTTOM 50
#define HOR_OFFSET_LANDSCAPE_LEFT 200
#define HOR_OFFSET_LANDSCAPE_RIGHT 200
#define HOR_OFFSET_LANDSCAPE_TOP 100
#define HOR_OFFSET_LANDSCAPE_BOTTOM 100

#define ROW_SIZE_PORTRAIT_WIDTH 500
#define ROW_SIZE_PORTRAIT_HEIGHT 50
#define ROW_SIZE_LANDSCAPE_WIDTH 400
#define ROW_SIZE_LANDSCAPE_HEIGHT 50

#define ROW_DIVIDER 5

+(CGRect) frameForRowforIndex:(int) index
          inSuperView:(UIView *) superView;
{
    
    CGPoint origin = CGPointMake(superView.bounds.size.width/2 - ROW_SIZE_PORTRAIT_WIDTH/2,
                                 VER_OFFSET_PORTRAIT_TOP + index * ROW_SIZE_PORTRAIT_HEIGHT + index * ROW_DIVIDER);
    return CGRectMake(origin.x, origin.y, ROW_SIZE_PORTRAIT_WIDTH, ROW_SIZE_PORTRAIT_HEIGHT);
}

+ (CGPoint) originForFrameAfterFrame:(CGRect) frame
{
    CGPoint point = CGPointMake(frame.origin.x,
                                frame.origin.y + frame.size.height + ROW_DIVIDER);
    return point;
}

+ (int) lowestRowIndexInFrame:(CGRect) frame
{
    CGFloat topVisiblePart = CGRectGetMinY(frame);
    CGFloat effectiveBottomVisiblePart = topVisiblePart - VER_OFFSET_PORTRAIT_TOP;
    //we give one row as a buffer
    int result = floorf(effectiveBottomVisiblePart / (ROW_SIZE_PORTRAIT_HEIGHT + ROW_DIVIDER)) - 1;
    return MAX(result,0);
}

+ (int) highestRowIndexInFrame:(CGRect) frame
{
    CGFloat bottomVisiblePart =CGRectGetMaxY(frame);
    CGFloat effectiveBottomVisiblePart = bottomVisiblePart - VER_OFFSET_PORTRAIT_TOP;
    //we give one row as a buffer
    int result = floorf((effectiveBottomVisiblePart - 1)/ (ROW_SIZE_PORTRAIT_HEIGHT + ROW_DIVIDER))+1;
    return result;
}

@end
