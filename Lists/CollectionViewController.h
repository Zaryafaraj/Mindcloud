//
//  CollectionScreenListTableViewController.h
//  Lists
//
//  Created by Ali Fathalian on 4/28/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ListsViewController.h"
#import "CollectionViewParentProtocol.h"
#import "TableAnimatorProtocol.h"
#import "NoteRowDelegate.h"

@interface CollectionViewController : ListsViewController <NoteRowDelegate>

@property (strong ,nonatomic) NSString * name;
@property (nonatomic, readwrite)IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) id<CollectionViewParentProtocol> parentDelegate;
@property (nonatomic, strong) id<TableAnimatorProtocol> animationManager;
@end
