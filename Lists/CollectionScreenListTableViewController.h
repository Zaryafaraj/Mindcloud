//
//  CollectionScreenListTableViewController.h
//  Lists
//
//  Created by Ali Fathalian on 4/28/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ListTableViewController.h"
#import "ListCollectionViewDelegate.h"
#import "ListTableAnimationManager.h"

@interface CollectionScreenListTableViewController : ListTableViewController

@property (strong ,nonatomic) NSString * name;
@property (nonatomic, readwrite)IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) id<ListCollectionViewDelegate> parentDelegate;
@property (nonatomic, strong) id<ListTableAnimationManager> animationManager;
@end
