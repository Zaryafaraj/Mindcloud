//
//  ListMainPageViewController.m
//  Lists
//
//  Created by Ali Fathalian on 4/6/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "MainScreenListTableViewController.h"
#import "MainScreenRow.h"

@interface MainScreenListTableViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation MainScreenListTableViewController

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        MainScreenRow * row = [[MainScreenRow alloc] init];
        self.navigationBar.alpha = 0.7;
        row.delegate = self;
        self.prototypeRow =row;
        self.isInEditMode = NO;
    }
    return self;
}

- (IBAction)addPressed:(id)sender
{
    if (self.isInEditMode)
    {
        [self.editingRow disableEditing:YES];
        self.editingRow = nil;
        self.isInEditMode = NO;
    }
    
    [self addRowToTop];
}

#pragma mark - MainScreenRow Delegate
-(void) deletePressed:(MainScreenRow *)sender
{
    [self removeRow:sender];
}

-(void) sharePressed:(MainScreenRow *)sender
{
    
}

-(void) renamePressed:(MainScreenRow *)sender
{
    [sender enableEditing:YES];
    self.isInEditMode = YES;
    self.editingRow = sender;
}

-(void) selectedRow:(UIView<ListRow> *)sender
{
    if (self.isInEditMode)
    {
        [self.editingRow disableEditing:YES];
        self.editingRow = nil;
        self.isInEditMode = NO;
    }
    else
    {
        //segue
    }
}

-(void) scrollViewTapped:(UISwipeGestureRecognizer *) sender
{
    [super scrollViewTapped:sender];
    if (self.isInEditMode)
    {
        [self.editingRow disableEditing:YES];
        self.editingRow = nil;
        self.isInEditMode = NO;
    }
}


@end
