//
//  MainScreenListLayout.m
//  Lists
//
//  Created by Ali Fathalian on 4/8/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "CenteredListTableViewLayoutManager.h"
#import "ListRow.h"

@implementation CenteredListTableViewLayoutManager

#define VER_OFFSET_TOP 100
#define ROW_SIZE_WIDTH 500
#define ROW_SIZE_HEIGHT 50
#define CONTEXTUAL_MENU_OFFSET 40

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
    
    CGPoint origin = CGPointMake(superView.bounds.size.width/2 - ROW_SIZE_WIDTH/2,
                                 VER_OFFSET_TOP + index * ROW_SIZE_HEIGHT + index * self.rowDivider);
    return CGRectMake(origin.x, origin.y, ROW_SIZE_WIDTH, ROW_SIZE_HEIGHT);
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
    CGFloat effectiveBottomVisiblePart = topVisiblePart - VER_OFFSET_TOP;
    //we give one row as a buffer
    int result = floorf(effectiveBottomVisiblePart / (ROW_SIZE_HEIGHT + self.rowDivider)) - 1;
    return MAX(result,0);
}

- (int) highestRowIndexInFrame:(CGRect) frame
{
    CGFloat bottomVisiblePart =CGRectGetMaxY(frame);
    CGFloat effectiveBottomVisiblePart = bottomVisiblePart - VER_OFFSET_TOP;
    //we give one row as a buffer
    int result = floorf((effectiveBottomVisiblePart - 1)/ (ROW_SIZE_HEIGHT + self.rowDivider))+1;
    result += 4;
    return result;
}

-(CGRect) frameForContextualMenuInRow:(UIView<ListRow> *) row
{
    //the menu resizes to the image so this size doesn matter . Only the origins
    CGSize menuSize = CGSizeMake(row.frame.size.width/4, row.frame.size.height);
    CGRect contextMenuFrame = CGRectMake(row.frame.origin.x + row.frame.size.width + CONTEXTUAL_MENU_OFFSET,
                                         row.frame.origin.y + row.frame.size.height/8,
                                         menuSize.width,
                                         menuSize.height);
//    CGSize menuSize = CGSizeMake(row.frame.size.width/4, row.frame.size.height);
//    CGRect contextMenuFrame = CGRectMake(row.frame.origin.x + row.frame.size.width/2 + 20,
//                                         row.index * (row.frame.size.height/2 + self.rowDivider) + VER_OFFSET_TOP,
//                                         menuSize.width,
//                                         menuSize.height);
    return contextMenuFrame;
}

@end
