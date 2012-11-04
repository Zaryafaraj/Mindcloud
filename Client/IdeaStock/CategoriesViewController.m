//
//  CategoriesViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/2/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CategoriesViewController.h"

@interface CategoriesViewController ()

@end

@implementation CategoriesViewController

- (void)viewDidLoad
{
    self.table.dataSource = self.dataSource;
    self.table.delegate = self.delegate;
}


@end
