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
#import "NoteRow.h"

@interface CollectionScreenListTableViewController ()

@end

@implementation CollectionScreenListTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self = [self init];
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
    self.animationManager = [[ListTableSlideAnimationManager alloc] init];
    NoteRow * row = [[NoteRow alloc] init];
    self.prototypeRow = row;
    self.isInEditMode = NO;
}

-(IBAction)addPressed:(id)sender
{
    if (self.isInEditMode)
    {
        [self.editingRow disableEditing:YES];
        self.editingRow = nil;
        self.isInEditMode = NO;
    }
    [self addRowToTop];
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
