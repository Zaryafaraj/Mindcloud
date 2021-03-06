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
    NSArray * lowestandHighestIndex = [self.delegate lowestAndHighestIndexInView];
    NSNumber * lowestIndexNumber = lowestandHighestIndex[0];
    NSNumber * highestIndexNumber = lowestandHighestIndex[1];
    int lowestIndex = [lowestIndexNumber intValue];
    int highestIndex = [highestIndexNumber intValue];
    
    //recycle
    for (UIView <ListRowProtocol> * row in self.visibleViews)
    {
        if (row.index < lowestIndex)
        {
            [row removeFromSuperview];
            [self.recycledViews addObject:row];
        }
        if (row.index > highestIndex)
        {
            
            [row removeFromSuperview];
            [self.recycledViews addObject:row];
        }
    }
    [self.visibleViews minusSet:self.recycledViews];
    
    //add the new ones
    for (int index = lowestIndex ; index <= highestIndex ; index++)
    {
        if (![self isDisplayingRowForIndex:index])
        {
            UIView<ListRowProtocol> * prototype = [self dequeueRow];
            UIView<ListRowProtocol> * recycledView = [self.delegate rowForIndex:index
                                                          withPrototype:prototype];
            if (recycledView != nil)
            {
                
                recycledView.index = index;
                [scrollView addSubview:recycledView];
                [self.delegate didRecycledRow:recycledView
                                     ForIndex:index];
                [self.visibleViews addObject:recycledView];
            }
            else
            {
                [prototype removeFromSuperview];
                if (prototype != nil)
                    [self.recycledViews addObject:prototype];
            }
        }
    }
//        NSLog(@"Visible --> %d", [self.visibleViews count]);
//        NSLog(@"Recycled --> %d", [self.recycledViews count]);
}

-(BOOL) isDisplayingRowForIndex:(int) index
{
    for(UIView<ListRowProtocol> * row in self.visibleViews)
    {
        if (row.index == index)
        {
            return YES;
        }
    }
    return NO;
}

-(UIView<ListRowProtocol> *) dequeueRow
{
    if([self.recycledViews count] > 0)
    {
        UIView<ListRowProtocol> * result = [self.recycledViews anyObject];
        [self.recycledViews removeObject:result];
        [result reset];
        return result;
    }
    else
    {
        UIView<ListRowProtocol> * result = [self.prototype prototypeSelf];
        [result reset];
        return result;
    }
}

-(UIView<ListRowProtocol> *) dequeRowForAdditionTo:(UIScrollView *) scrollView
                                   atIndex:(int) newRowIndex;
{
    if (self.prototype == nil) return nil;
    NSArray * lowestandHighestIndex = [self.delegate lowestAndHighestIndexInView];
    NSNumber * lowestIndexNumber = lowestandHighestIndex[0];
    NSNumber * highestIndexNumber = lowestandHighestIndex[1];
    int lowestIndex = [lowestIndexNumber intValue];
    int highestIndex = [highestIndexNumber intValue];
 
    //recycle
    for (UIView <ListRowProtocol> * row in self.visibleViews)
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
        if (newRowIndex != index && ![self isDisplayingRowForIndex:index])
        {
            UIView<ListRowProtocol> * prototype = [self dequeueRow];
            UIView<ListRowProtocol> * recycledView = [self.delegate rowForIndex:index
                                                          withPrototype:prototype];
            if (recycledView != nil)
            {
                recycledView.index = index;
                [self.visibleViews addObject:recycledView];
            }
            else
            {
                [self.recycledViews addObject:prototype];
            }
        }
    }
    
    UIView<ListRowProtocol> * result = nil;
    if([self.recycledViews count] > 0)
    {
        result = [self.recycledViews anyObject];
        [self.recycledViews removeObject:result];
    }
    else
    {
        result = [self.prototype prototypeSelf];
    }
    
    [self.visibleViews addObject:result];
    //    NSLog(@"Visible ==> %d", [self.visibleViews count]);
    //    NSLog(@"Recycled ==> %d", [self.recycledViews count]);
    [result removeFromSuperview];
    [result reset];
    return result;
    
}

-(void) returnRowForRecyling:(UIView<ListRowProtocol> *) row
                inScrollView:(UIScrollView *) scrollView
{
    
    [self.visibleViews removeObject:row];
    
    NSArray * lowestandHighestIndex = [self.delegate lowestAndHighestIndexInView];
    NSNumber * lowestIndexNumber = lowestandHighestIndex[0];
    NSNumber * highestIndexNumber = lowestandHighestIndex[1];
    int lowestIndex = [lowestIndexNumber intValue];
    int highestIndex = [highestIndexNumber intValue];
 
    //recycle
    for (UIView <ListRowProtocol> * row in self.visibleViews)
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
            UIView<ListRowProtocol> * prototype = [self dequeueRow];
            UIView<ListRowProtocol> * recycledView = [self.delegate rowForIndex:index
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
@end
