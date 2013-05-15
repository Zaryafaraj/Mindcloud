//
//  ListMainPageViewController.h
//  Lists
//
//  Created by Ali Fathalian on 4/6/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionRowDelegate.h"
#import "ListsViewController.h"
#import "CollectionViewParentProtocol.h"

@interface MainScreenViewController : ListsViewController <CollectionRowDelegate, CollectionViewParentProtocol>


@end
