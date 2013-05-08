//
//  SlidingTableRowLayoutManager.m
//  Lists
//
//  Created by Ali Fathalian on 4/26/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "SlidingTableRowLayoutManager.h"

@implementation SlidingTableRowLayoutManager

- (CGRect) frameForOpenedRow:(CGRect) closedFrame
{
    CGRect result = CGRectMake(closedFrame.origin.x + closedFrame.size.width/3,
                               closedFrame.origin.y,
                               2*closedFrame.size.width/3,
                               closedFrame.size.height);
    return result;
}

-(CGRect) frameForButtonInBounds:(CGRect) parentBounds
              WithBackgroundView:(UIView *) backgroundView
{
    CGSize buttonSize = CGSizeMake(parentBounds.size.width/9,
                                   parentBounds.size.height);
    CGRect addButtonFrame = CGRectMake(backgroundView.bounds.origin.x,
                                       backgroundView.bounds.origin.y,
                                       buttonSize.width,
                                       buttonSize.height);
    
    
    return addButtonFrame;
}

-(CGRect) frameForContextualMenuInRow:(UIView *)row
{
    CGSize menuSize = CGSizeMake(row.bounds.size.width/4, row.bounds.size.height);
    CGRect contextMenuFrame = CGRectMake(row.bounds.size.width - menuSize.width,
                                         row.frame.origin.y,
                                         menuSize.width,
                                         menuSize.height);
    return contextMenuFrame;
}

@end
