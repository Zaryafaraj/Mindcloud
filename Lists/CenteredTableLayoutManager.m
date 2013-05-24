//
//  MainScreenListLayout.m
//  Lists
//
//  Created by Ali Fathalian on 4/8/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "CenteredTableLayoutManager.h"
#import "ListRowProtocol.h"
#import "ThemeFactory.h"

@implementation CenteredTableLayoutManager

-(CGFloat) verticalOffsetFromTop
{
    return [[ThemeFactory currentTheme] verticalDistanceFromTop];
}

-(CGFloat) rowWidth
{
    return [[ThemeFactory currentTheme] rowWidth];
}

-(CGFloat) subItemHeight
{
    return [[ThemeFactory currentTheme] subItemHeight];
}

-(CGFloat) rowHeight
{
    return [[ThemeFactory currentTheme] rowHeight];
}

-(CGFloat) contextualMenuHoriziontalOffset
{
    
    return [[ThemeFactory currentTheme] contextualMenuOffset];
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
          inSuperView:(UIView *) superView
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


-(NSArray *) lowestAndHighestIndexForFrame:(CGRect)frame
                               inSuperView:(UIView *) superView
{
    int lowest = [self lowestRowIndexInFrame:frame];
    int highest = [self highestRowIndexInFrame:frame];
    NSNumber * lowestNumber = [NSNumber numberWithInt:lowest];
    NSNumber * highestNumber = [NSNumber numberWithInt:highest];
    return @[lowestNumber, highestNumber];
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
