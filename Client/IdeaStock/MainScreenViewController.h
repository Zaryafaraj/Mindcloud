//
//  MainScreenDropbox.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/24/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoriesViewController.h"
#import "UIEditableTableViewDelegate.h"

@interface MainScreenViewController : UIViewController
<UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UICollectionViewDelegate,
UIActionSheetDelegate,
UITableViewDataSource,
UIEditableTableViewDelegate>

@property (atomic) BOOL actionInProgress;
@property (weak, nonatomic) CategoriesViewController * categoriesController;
//maybe better to make this private
-(void) finishedWorkingWithBulletinBoard;

@end
