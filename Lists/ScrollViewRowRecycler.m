//
//  ScrollViewRowRecycler.m
//  Lists
//
//  Created by Ali Fathalian on 4/14/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ScrollViewRowRecycler.h"

@interface ScrollViewRowRecycler()

@property NSMutableSet * visibleViews;
@property NSMutableSet * recycledViews;

@end

@implementation ScrollViewRowRecycler

+(ScrollViewRowRecycler *) recycler
{
    static ScrollViewRowRecycler * recycler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recycler = [[ScrollViewRowRecycler alloc] init];
    });
    return recycler;
}

-(id) init
{
    self = [super init];
    self.visibleViews = [NSMutableSet set];
    self.recycledViews = [NSMutableSet set];
    return self;
}

-(void) recycleRows:(UIScrollView *)scrollView
{
    NSLog(@"Visible views --> %d", [self.visibleViews count]);
    NSLog(@"Recycled views --> %d", [self.recycledViews count]);
    int lowestIndex = [self.delegate lowestIndexInView];
    int highestIndex = [self.delegate highestIndexInView];
    
    //recycle
    for (UIView <ListRow> * row in self.visibleViews)
    {
        if (row.index < lowestIndex || row.index > highestIndex)
        {
            [self.recycledViews addObject:row];
            [row removeFromSuperview];
        }
    }
    [self.visibleViews minusSet:self.recycledViews];
    
    //add the new ones
    for (int index = lowestIndex ; index <= highestIndex ; index++)
    {
        if (![self isDisplayingRowForIndex:index])
        {
            UIView<ListRow> * prototype = [self dequeueRow];
            UIView<ListRow> * recycledView = [self.delegate rowForIndex:index
                                                          withPrototype:prototype];
            if (recycledView != nil)
            {
                
                recycledView.index = index;
                [scrollView addSubview:recycledView];
                [self.visibleViews addObject:recycledView];
            }
            else
            {
                [self.recycledViews addObject:prototype];
            }
        }
    }
}

-(BOOL) isDisplayingRowForIndex:(int) index
{
    for(UIView<ListRow> * row in self.visibleViews)
    {
        if (row.index == index)
        {
            return YES;
        }
    }
    return NO;
}

-(UIView<ListRow> *) dequeueRow
{
    if([self.recycledViews count] > 0)
    {
        UIView<ListRow> * result = [self.recycledViews anyObject];
        [self.recycledViews removeObject:result];
        return result;
    }
    else
    {
        NSLog(@"Creating NEW");
        return [self.prototype prototypeSelf];
    }
}

@end
