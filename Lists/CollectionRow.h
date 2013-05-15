//
//  ListsCollectionRowView.h
//  Lists
//
//  Created by Ali Fathalian on 4/8/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListRow.h"
#import "RowAnimatorProtocol.h"
#import "MainScreenRowViewDelegate.h"
#import "RowLayoutManagerProtocol.h"

@interface MainScreenRow : UIView <ListRow, UITextFieldDelegate>

@property (nonatomic, strong) id<MainScreenRowViewDelegate> delegate;

@property (nonatomic, strong) id<RowLayoutManagerProtocol> layoutManager;

@end
