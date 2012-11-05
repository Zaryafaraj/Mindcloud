//
//  CategoriesViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/2/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CategoriesViewController.h"

@interface CategoriesViewController ()

@property UIColor * lastButtonColor;

@end

@implementation CategoriesViewController

- (void)viewDidLoad
{
    self.table.dataSource = self.dataSource;
    self.table.delegate = self.delegate;
}

#define CREATE_BUTTON_TITILE @"Create"
- (IBAction)addPressed:(id)sender {
    if (self.table.editing)
    {
        [self.table setEditing:NO animated:YES];
        UIBarButtonItem * button = (UIBarButtonItem *) sender;
        button.style = UIBarButtonItemStyleBordered;
        button.title = @"Edit";
        button.tintColor = self.lastButtonColor;
    }
    else
    {
        [self.table setEditing:YES animated:YES];
        UIBarButtonItem * button = (UIBarButtonItem *) sender;
        button.title = @"Cancel";
        button.style = UIBarButtonItemStyleBordered;
        self.lastButtonColor = button.tintColor;
        button.tintColor = [UIColor colorWithRed:0.12 green:0.23 blue:1 alpha:1];
    }
}
@end
