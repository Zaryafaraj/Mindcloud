//
//  ListsCollectionRowView.h
//  Lists
//
//  Created by Ali Fathalian on 4/8/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListRow.h"
#import "ListRowAnimationManager.h"
#import "MainScreenRowViewDelegate.h"

@interface MainScreenRow : UIView <ListRow>

@property (nonatomic, strong) id<MainScreenRowViewDelegate> delegate;

@end
