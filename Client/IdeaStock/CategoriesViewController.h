//
//  CategoriesViewController.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/2/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoriesViewController: UIViewController

@property (weak,nonatomic) id<UITableViewDataSource> dataSource;
@property (weak, nonatomic) id<UITableViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *table;

@end
