//
//  CollectionScreenListTableViewController.m
//  Lists
//
//  Created by Ali Fathalian on 4/28/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "CollectionScreenListTableViewController.h"
#import "ThemeFactory.h"
#import "ListTableSlideAnimationManager.h"

@interface CollectionScreenListTableViewController ()

@end

@implementation CollectionScreenListTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.animationManager = [[ListTableSlideAnimationManager alloc] init];
    }
    return self;
}

- (IBAction)donePressed:(id)sender {
    [self.animationManager hideNavigationBar:self.navigationBar];
    [self.parentDelegate finishedWorkingWithCollection:self.name];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    self.navigationBar.alpha = 0;
}

-(void) viewDidAppear:(BOOL)animated
{
    
    [self.animationManager showNavigationBar:self.navigationBar];
    self.navigationBar.backgroundColor = [[ThemeFactory currentTheme] colorForCollectionScreenNavigationBar];
}


@end
