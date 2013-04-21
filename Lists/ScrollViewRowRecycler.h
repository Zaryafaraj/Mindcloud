//
//  ScrollViewRowRecycler.h
//  Lists
//
//  Created by Ali Fathalian on 4/14/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainScreenRow.h"
#import "ScrollViewRecyclerDelegate.h"

@interface ScrollViewRowRecycler : NSObject

@property (nonatomic, strong) id<ScrollViewRecyclerDelegate> delegate;
@property (nonatomic, strong) UIView<ListRow> * prototype;

+(ScrollViewRowRecycler *) recycler;

-(void) recycleRows:(UIScrollView *)scrollView;

-(UIView<ListRow> *) dequeRowForAdditionTo:(UIScrollView *) scrollView
                                   atIndex:(int) newRowIndex;
@end
