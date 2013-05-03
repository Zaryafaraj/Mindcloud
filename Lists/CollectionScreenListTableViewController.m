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
#import "CenteredListTableViewLayoutManager.h"
#import "NoteRow.h"

@interface CollectionScreenListTableViewController ()

@end

@implementation CollectionScreenListTableViewController

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.animationManager = [[ListTableSlideAnimationManager alloc] init];
        NoteRow * row = [[NoteRow alloc] init];
        row.delegate = self;
        self.prototypeRow = row;
        self.isInEditMode = NO;
        CGFloat divider = [[ThemeFactory currentTheme] spaceBetweenRowsInCollectionScreen];
        self.layoutManager = [[CenteredListTableViewLayoutManager alloc] initWithDivider:divider];
    }
    return self;
}

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

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationBar.alpha = 0;
}

-(void) viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    [self.animationManager showNavigationBar:self.navigationBar];
    self.navigationBar.backgroundColor = [[ThemeFactory currentTheme] colorForCollectionScreenNavigationBar];
}

#pragma mark - Note Row Delegate

-(void) deletePressed:(UIView<ListRow> *) sender
{
    
}

-(void) tappedRow:(UIView<ListRow> *) sender
{
    [self.editingRow disableEditing:NO];
    [sender enableEditing:NO];
    self.editingRow = sender;
    self.isInEditMode = YES;
}

-(BOOL) isEditingRows
{
    return self.isEditing;
}

@end
