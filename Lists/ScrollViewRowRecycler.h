//
//  ScrollViewRowRecycler.h
//  Lists
//
//  Created by Ali Fathalian on 4/14/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListsCollectionRowView.h"

@interface ScrollViewRowRecycler : NSObject

+(ScrollViewRowRecycler *) recycler;

-(void) recycleRows:(UIScrollView *)scrollView;

-(ListsCollectionRowView *) dequeueRowForMainScreen;

@end
