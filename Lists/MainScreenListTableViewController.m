//
//  ListMainPageViewController.m
//  Lists
//
//  Created by Ali Fathalian on 4/6/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "MainScreenListTableViewController.h"


@interface MainScreenListTableViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation MainScreenListTableViewController

- (IBAction)addPressed:(id)sender
{
    [self addRowToTop];
}

@end
