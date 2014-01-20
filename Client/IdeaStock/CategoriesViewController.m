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
@property (strong, nonatomic) UITapGestureRecognizer * tgr;
@property (weak, nonatomic) UITextField * activeTextField;

@end

@implementation CategoriesViewController

#define CREATE_BUTTON_TITILE @"Create"
#define RENAME_BUTTON_TITLE @"Rename"

@synthesize renameMode = _renameMode;

-(void) setDelegate:(id<UIEditableTableViewDelegate>)delegate
{
    _delegate = delegate;
    self.table.delegate = delegate;
}

-(void) setDataSource:(id<UITableViewDataSource>)dataSource
{
    self.table.dataSource = dataSource;
}

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

-(void) screenTapped:(UITapGestureRecognizer *) gr
{
    if (self.table.editing)
    {
        [self resignFirstResponder];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.table.dataSource = self.dataSource;
    self.table.delegate = self.delegate;
    
    UITapGestureRecognizer * gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    self.tgr = gestureRecognizer;
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
#define CANCEL_BUTTON_TITLE @"Done"
- (IBAction)editPressed:(id)sender {
    if (self.table.editing)
    {
        
        [self adjustCellsForEditMode:NO];
        [self.table setEditing:NO animated:YES];
        UIBarButtonItem * button = (UIBarButtonItem *) sender;
        button.style = UIBarButtonItemStyleBordered;
        button.title = EDIT_BUTTON_TITLE;
        button.tintColor = self.lastButtonColor;
        self.viewToolbar.items = self.navigateToolbarItems;
    }
    else
    {
        [self adjustCellsForEditMode:YES];
        [self.table setEditing:YES animated:YES];
        UIBarButtonItem * button = (UIBarButtonItem *) sender;
        button.title = CANCEL_BUTTON_TITLE;
        button.style = UIBarButtonItemStyleBordered;
        self.lastButtonColor = button.tintColor;
        self.viewToolbar.items = self.editToolbarItems;
    }
}

-(void) adjustCellsForEditMode:(BOOL) isEditing
{
    for(UITableViewCell * cell in self.table.visibleCells)
    {
        NSString * categoryName = cell.textLabel.text;
        BOOL shouldRename = NO;
        id<UIEditableTableViewDelegate> temp = self.delegate;
        if (temp)
        {
            shouldRename = [temp shouldRenameCategory:categoryName];
        }
        if (isEditing && shouldRename)
        {
            cell.textLabel.hidden = YES;
            [self addEditableTextFieldToTableCell:cell];
        }
        else
        {
            cell.textLabel.hidden = NO;
            for(UIView * view in cell.textLabel.superview.subviews)
            {
                if([view isKindOfClass:[UITextField class]])
                {
                    [view removeFromSuperview];
                }
            }
        }
    }
}

-(void) addEditableTextFieldToTableCell:(UITableViewCell *) cell;
{
    
    UITextField * textField = [[UITextField alloc] initWithFrame:cell.textLabel.frame];
    textField.text = cell.textLabel.text;
    textField.font = cell.textLabel.font;
    textField.textColor = cell.textLabel.textColor;
    textField.backgroundColor = cell.textLabel.backgroundColor;
    textField.textAlignment = cell.textLabel.textAlignment;
    textField.delegate = self;
    [cell.textLabel.superview addSubview:textField];
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

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    //very hacky
    UITableViewCell * cell = (UITableViewCell *)((UIView *)((UIView *)textField.superview).superview).superview;
    NSString * beforeText = cell.textLabel.text;
    NSString * newText = textField.text;
    id<UIEditableTableViewDelegate> temp = self.delegate;
    if (temp)
    {
        [temp tableView:self.table
                renamed:cell
            fromOldName:beforeText
              toNewName:newText];
    }
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    self.tgr.cancelsTouchesInView = YES;
    self.activeTextField = textField;
}

-(BOOL) resignFirstResponder
{
    [super resignFirstResponder];
    [self.activeTextField resignFirstResponder];
    return YES;
}
@end
