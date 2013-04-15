//
//  ScrollViewRowRecycler.m
//  Lists
//
//  Created by Ali Fathalian on 4/14/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ScrollViewRowRecycler.h"

@interface ScrollViewRowRecycler()

@property NSMutableSet * visibleViewsForMainScreen;
@property NSMutableSet * recycledViewsForMainScreen;

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
    self.visibleViewsForMainScreen = [NSMutableSet set];
    self.recycledViewsForMainScreen = [NSMutableSet set];
    return self;
}

-(void) recycleRows:(UIScrollView *)scrollView
{
//    CGRect visibleBounds = scrollView.bounds;
    
}

-(ListsCollectionRowView *) dequeueRowForMainScreen
{
    if([self.recycledViewsForMainScreen count] > 0)
    {
        ListsCollectionRowView * result = [self.recycledViewsForMainScreen anyObject];
        return result;
    }
    return [[ListsCollectionRowView alloc] init];
}

@end
