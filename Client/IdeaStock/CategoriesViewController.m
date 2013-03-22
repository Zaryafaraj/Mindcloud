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
@property (weak, nonatomic) IBOutlet UIToolbar *viewToolbar;
@property (strong, nonatomic) NSArray * editToolbarItems;
@property (strong, nonatomic) NSArray * navigateToolbarItems;

@end

@implementation CategoriesViewController

#define CREATE_BUTTON_TITILE @"Create"
#define RENAME_BUTTON_TITLE @"Rename"

@synthesize renameMode = _renameMode;

- (void) setRenameMode:(BOOL)renameMode
{
    for(UIBarButtonItem * button in self.editToolbarItems)
    {
        if ([button.title isEqualToString:RENAME_BUTTON_TITLE])
        {
            button.enabled = renameMode;
        }
    }
}

-(BOOL)renameMode
{
    return _renameMode;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.table.dataSource = self.dataSource;
    self.table.delegate = self.delegate;
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    self.editToolbarItems = [self.viewToolbar.items copy];
    NSMutableArray * tempToolbar = [self.viewToolbar.items mutableCopy];
    for(UIBarButtonItem * button in tempToolbar)
    {
        if ([button.title isEqual:RENAME_BUTTON_TITLE])
        {
            [tempToolbar removeObject:button];
        }
    }
    self.navigateToolbarItems = [tempToolbar copy];
    self.viewToolbar.items = self.navigateToolbarItems;
}

#define EDIT_BUTTON_TITLE @"Edit"
#define CANCEL_BUTTON_TITLE @"Cancel"
- (IBAction)editPressed:(id)sender {
    if (self.table.editing)
    {
        [self.table setEditing:NO animated:YES];
        UIBarButtonItem * button = (UIBarButtonItem *) sender;
        button.style = UIBarButtonItemStyleBordered;
        button.title = EDIT_BUTTON_TITLE;
        button.tintColor = self.lastButtonColor;
        self.viewToolbar.items = self.navigateToolbarItems;
    }
    else
    {
        [self.table setEditing:YES animated:YES];
        UIBarButtonItem * button = (UIBarButtonItem *) sender;
        button.title = CANCEL_BUTTON_TITLE;
        button.style = UIBarButtonItemStyleBordered;
        self.lastButtonColor = button.tintColor;
        button.tintColor = [UIColor colorWithRed:0.12 green:0.23 blue:1 alpha:1];
        self.viewToolbar.items = self.editToolbarItems;
    }
}

- (IBAction)renamePressed:(id)sender
{
    [self.delegate tableView:self.table renamePressedForItemAt:[self.table indexPathForSelectedRow]];
}

-(void) exitEditMode{
    for(UIBarButtonItem * button in self.viewToolbar.items)
    {
        if ([button.title isEqualToString:CANCEL_BUTTON_TITLE])
        {
            button.style = UIBarButtonItemStyleBordered;
            button.title = EDIT_BUTTON_TITLE;
            button.tintColor = self.lastButtonColor;
        }
    }
    self.viewToolbar.items = self.navigateToolbarItems;
    [self.table setEditing:NO];
}

@end
