//
//  ListMainPageViewController.m
//  Lists
//
//  Created by Ali Fathalian on 4/6/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "MainScreenListTableViewController.h"
#import "MainScreenRow.h"
#import "CollectionScreenListTableViewController.h"
#import "ThemeFactory.h"

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
        self.navigationBar.alpha = [[ThemeFactory currentTheme] alphaForMainScreenNavigationBar];
        self.navigationBar.backgroundColor = [[ThemeFactory currentTheme] colorForMainScreenNavigationBar];
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

-(void) tappedRow:(UIView<ListRow> *) sender
{
    if (self.isInEditMode)
    {
        [self.editingRow disableEditing:YES];
        self.editingRow = nil;
        self.isInEditMode = NO;
    }
}
-(void) selectedRow:(UIView<ListRow> *)sender
{
    [self performSegueWithIdentifier:@"RollingSegue" sender:sender];
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

-(BOOL) isEditingRows
{
    return self.isInEditMode;
}

#pragma mark - Segue

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.animationManager hideNavigationBar:self.navigationBar];
    CollectionScreenListTableViewController * dest = segue.destinationViewController;
    MainScreenRow * senderRow = sender;
    dest.name = senderRow.text;
    dest.navigationBar.alpha = 0;
    dest.parentDelegate = self;
}

#pragma  mark - ListCollectionViewDelegate
-(void) finishedWorkingWithCollection:(NSString *) collectionController
{
    [self.animationManager showNavigationBar:self.navigationBar];
    [self dismissViewControllerAnimated:YES completion:^{}];
}
@end
