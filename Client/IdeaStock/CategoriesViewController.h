//
//  CategoriesViewController.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/2/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIEditableTableViewDelegate.h"
@interface CategoriesViewController: UIViewController <UITextFieldDelegate>

@property (weak,nonatomic) id<UITableViewDataSource> dataSource;
@property (weak, nonatomic) id<UIEditableTableViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property BOOL renameMode;
-(void) exitEditMode;


@end
