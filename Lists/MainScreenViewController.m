//
//  ListMainPageViewController.m
//  Lists
//
//  Created by Ali Fathalian on 4/6/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "MainScreenViewController.h"
#import "CollectionRow.h"
#import "CollectionViewController.h"
#import "ThemeFactory.h"
#import "CenteredTableLayoutManager.h"

@interface MainScreenViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation MainScreenViewController

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        CollectionRow * row = [[CollectionRow alloc] init];
        self.navigationBar.alpha = [[ThemeFactory currentTheme] alphaForMainScreenNavigationBar];
        self.navigationBar.tintColor = [[ThemeFactory currentTheme] colorForMainScreenNavigationBar];
        row.delegate = self;
        self.prototypeRow =row;
        self.isInEditMode = NO;
        CGFloat divider = [[ThemeFactory currentTheme] spaceBetweenRowsInMainScreen];
        self.layoutManager = [[CenteredTableLayoutManager alloc] initWithDivider:divider];
    }
    return self;
}

-(void) exitFromEditing
{
    if (self.isInEditMode)
    {
        [self.editingRow disableEditing:YES];
        self.editingRow = nil;
        self.isInEditMode = NO;
    }
}

-(void) screenDoubleTapped:(UITapGestureRecognizer *) sender
{
    [self exitFromEditing];
    [self addRowToTop];
}

- (IBAction)addPressed:(id)sender
{
    [self exitFromEditing];
    [self addRowToTop];
}

#pragma mark - MainScreenRow Delegate
-(void) deletePressed:(CollectionRow *)sender
{
    [self removeRow:sender];
}

-(void) sharePressed:(CollectionRow *)sender
{
    
}

-(void) renamePressed:(CollectionRow *)sender
{
    [sender enableEditing:YES];
    self.isInEditMode = YES;
    self.editingRow = sender;
}

-(void) tappedRow:(UIView<ListRowProtocol> *) sender
{
    if (self.isInEditMode)
    {
        [self.editingRow disableEditing:YES];
        self.editingRow = nil;
        self.isInEditMode = NO;
    }
}

-(void) doubleTappedRow:(UIView<ListRowProtocol> *)sender
{
    [self exitFromEditing];
    [self addRowToTop];
}

-(void) selectedRow:(UIView<ListRowProtocol> *)sender
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

-(void) viewDidLoad
{
    UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenDoubleTapped:)];
    tgr.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:tgr];
}
#pragma mark - Segue

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.animationManager hideNavigationBar:self.navigationBar];
    CollectionViewController * dest = segue.destinationViewController;
    CollectionRow * senderRow = sender;
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
