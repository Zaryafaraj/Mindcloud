//
//  SlidingTableRowLayoutManager.m
//  Lists
//
//  Created by Ali Fathalian on 4/26/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "SlidingTableRowLayoutManager.h"

@implementation SlidingTableRowLayoutManager

- (CGRect) frameForOpenedRow:(CGRect) closedFrame;
{
    CGRect result = CGRectMake(closedFrame.origin.x + closedFrame.size.width/3,
                               closedFrame.origin.y,
                               2*closedFrame.size.width/3,
                               closedFrame.size.height);
    return result;
}

@end
