//
//  ListsCollectionRowView.h
//  Lists
//
//  Created by Ali Fathalian on 4/8/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListRowProtocol.h"
#import "RowAnimatorProtocol.h"
#import "CollectionRowDelegate.h"
#import "RowLayoutManagerProtocol.h"

@interface CollectionRow : UIView <ListRowProtocol, UITextFieldDelegate>

@property (nonatomic, strong) id<CollectionRowDelegate> delegate;

@property (nonatomic, strong) id<RowLayoutManagerProtocol> layoutManager;

@end
