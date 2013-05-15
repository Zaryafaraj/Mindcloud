//
//  MainScreenListLayout.m
//  Lists
//
//  Created by Ali Fathalian on 4/8/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "CenteredTableLayoutManager.h"
#import "ListRowProtocol.h"

@implementation CenteredTableLayoutManager

-(CGFloat) verticalOffsetFromTop
{
    if (!_verticalOffsetFromTop)
    {
        _verticalOffsetFromTop = 100;
    }
    return _verticalOffsetFromTop;
}

-(CGFloat) rowWidth
{
    if (!_rowWidth)
    {
        _rowWidth = 500;
    }
    return _rowWidth;
}

-(CGFloat) rowHeight
{
    if (!_rowHeight)
    {
        _rowHeight = 50;
    }
    return _rowHeight;
}

-(CGFloat) contextualMenuHoriziontalOffset
{
    if (!_contextualMenuHoriziontalOffset)
    {
        _contextualMenuHoriziontalOffset = 40;
    }
    return _contextualMenuHoriziontalOffset;
}

-(id) initWithDivider:(CGFloat) dividerSpace
{
    self = [super init];
    if (self)
    {
        self.rowDivider = dividerSpace;
    }
    return self;
}

- (CGRect) frameForRowforIndex:(int) index
          inSuperView:(UIView *) superView;
{
    
    CGPoint origin = CGPointMake(superView.bounds.size.width/2 - self.rowWidth/2,
                                 self.verticalOffsetFromTop + index * self.rowHeight + index * self.rowDivider);
    return CGRectMake(origin.x, origin.y, self.rowWidth, self.rowHeight);
}

- (CGPoint) originForFrameAfterFrame:(CGRect) frame
{
    CGPoint point = CGPointMake(frame.origin.x,
                                frame.origin.y + frame.size.height + self.rowDivider);
    return point;
}

- (int) lowestRowIndexInFrame:(CGRect) frame
{
    CGFloat topVisiblePart = CGRectGetMinY(frame);
    CGFloat effectiveBottomVisiblePart = topVisiblePart - self.verticalOffsetFromTop;
    //we give one row as a buffer
    int result = floorf(effectiveBottomVisiblePart / (self.rowHeight + self.rowDivider)) - 1;
    return MAX(result,0);
}

- (int) highestRowIndexInFrame:(CGRect) frame
{
    CGFloat bottomVisiblePart =CGRectGetMaxY(frame);
    CGFloat effectiveBottomVisiblePart = bottomVisiblePart - self.verticalOffsetFromTop;
    //we give one row as a buffer
    int result = floorf((effectiveBottomVisiblePart - 1)/ (self.rowHeight + self.rowDivider))+1;
    result += 4;
    return result;
}

-(CGRect) frameForContextualMenuInRow:(UIView<ListRowProtocol> *) row
{
    //the menu resizes to the image so this size doesn matter . Only the origins
    CGSize menuSize = CGSizeMake(row.frame.size.width/4, row.frame.size.height);
    CGRect contextMenuFrame = CGRectMake(row.frame.origin.x + row.frame.size.width + self.contextualMenuHoriziontalOffset,
                                         row.frame.origin.y + row.frame.size.height/8,
                                         menuSize.width,
                                         menuSize.height);
    return contextMenuFrame;
}

-(CGFloat) distanceFromRowToContextualMenu
{
    return 40;
}

@end
