//
//  SlidingTableRowLayoutManager.m
//  Lists
//
//  Created by Ali Fathalian on 4/26/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "SlidingTableRowLayoutManager.h"

@implementation SlidingTableRowLayoutManager

- (CGRect) frameForOpenedRow:(UIView *) row
{
    CGRect result = CGRectMake(row.frame.origin.x + row.frame.size.width/3,
                               row.frame.origin.y,
                               2*row.frame.size.width/3,
                               row.frame.size.height);
    return result;
}

@end
