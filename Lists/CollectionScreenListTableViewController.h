//
//  CollectionScreenListTableViewController.h
//  Lists
//
//  Created by Ali Fathalian on 4/28/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ListTableViewController.h"
#import "ListCollectionViewDelegate.h"
#import "TableAnimator.h"
#import "NoteRowDelegate.h"

@interface CollectionScreenListTableViewController : ListTableViewController <NoteRowDelegate>

@property (strong ,nonatomic) NSString * name;
@property (nonatomic, readwrite)IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) id<ListCollectionViewDelegate> parentDelegate;
@property (nonatomic, strong) id<TableAnimator> animationManager;
@end
