//
//  ListMainPageViewController.h
//  Lists
//
//  Created by Ali Fathalian on 4/6/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollViewRecyclerDelegate.h"
#import "ListTableViewLayoutManager.h"
#import "ListTableAnimationManager.h"
#import "ListTableViewDatasource.h"

@interface ListTableViewController : UIViewController <UIScrollViewDelegate, ScrollViewRecyclerDelegate>

@property (nonatomic, strong) id<ListTableViewLayoutManager> layoutManager;
@property (nonatomic, strong) id<ListTableAnimationManager> animationManager;

@property (nonatomic, strong) id<ListTableViewDatasource> dataSource;

-(void) addRowToTop;

-(void) removeRowFromIndex: (int) index;

@end
