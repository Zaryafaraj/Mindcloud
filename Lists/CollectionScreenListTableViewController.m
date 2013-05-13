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
#import "AwesomeMenu.h"
#import "AwesomeMenuItem.h"

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

-(IBAction)addPressed:(id)sender
{
    if (self.isInEditMode)
    {
        [self.editingRow disableEditing:YES];
        self.editingRow = nil;
        self.isInEditMode = NO;
    }
    
    UIView<ListRow> * row = [self addRowToTop];
    AwesomeMenu * contextualMenu = [self createContextualMenu:row];
    row.contextualMenu = contextualMenu;

    NSDictionary * viewsDictionary = NSDictionaryOfVariableBindings(contextualMenu, row);
    CGFloat distance = [self.layoutManager distanceFromRowToContextualMenu];
    NSString * layoutFormat = [NSString stringWithFormat:@"[row]->=%f-[contextualMenu]", distance];
    NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:layoutFormat
                                                                    options:NSLayoutFormatAlignAllCenterY
                                                                    metrics:nil
                                                                      views:viewsDictionary];
    
    [self.scrollView addSubview:contextualMenu];
    [contextualMenu setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:constraints];
    [self.animationManager animateAdditionForContextualMenu:contextualMenu
                                                inSuperView:self.scrollView];
}

-(AwesomeMenu *) createContextualMenu:(UIView<ListRow> *) row
{
    id <ITheme> theme = [ThemeFactory currentTheme];
    UIImage * background = [theme getContextualMenuItemBackground];
    UIImage * backgroundHighlighted = [theme getContextualMenuItemBackgroundHighlighted];
    UIImage * doneContent = [theme getContextualMenuContentLeft];
    UIImage * expandContent = [theme getContextualMenuContentRight];
    UIImage * clockContent = [theme getContextualMenuContentTop];
    UIImage * startContent = [theme getContextualMenuContentBottom];
    UIImage * buttonBackgroundImage = [theme getContextualMenuButton];
    UIImage * buttonBackgroundImageHighlighted = [theme getContextualMenuButtonHighlighted];
    UIImage * buttonContent = [theme getContextualMenuButtonContent];
    UIImage * buttonContentHighlighted = [theme getContextualMenuButtonContentHighlighted];
    
    AwesomeMenuItem * doneItem = [[AwesomeMenuItem alloc] initWithImage:background
                                                       highlightedImage:backgroundHighlighted
                                                           ContentImage:doneContent
                                                highlightedContentImage:nil];
    
    AwesomeMenuItem * expandItem = [[AwesomeMenuItem alloc] initWithImage:background
                                                         highlightedImage:backgroundHighlighted
                                                             ContentImage:expandContent
                                                  highlightedContentImage:nil];
    
    AwesomeMenuItem * clockItem = [[AwesomeMenuItem alloc] initWithImage:background
                                                        highlightedImage:backgroundHighlighted
                                                            ContentImage:clockContent
                                                 highlightedContentImage:nil];
    
    AwesomeMenuItem * startItem = [[AwesomeMenuItem alloc] initWithImage:background
                                                        highlightedImage:backgroundHighlighted
                                                            ContentImage:startContent
                                                 highlightedContentImage:nil];
    
    CGRect contextualMenuFrame = [self.layoutManager frameForContextualMenuInRow:row];
    AwesomeMenu * menu = [[AwesomeMenu alloc] initWithFrame:contextualMenuFrame
                                                      menus:@[doneItem, expandItem, clockItem, startItem]
                                            backgroundImage:buttonBackgroundImage
                                 backgroundImageHighlighted:buttonBackgroundImageHighlighted
                                               contentImage:buttonContent
                                           highlightedImage:buttonContentHighlighted];
    menu.endRadius = 50.0f;
    menu.farRadius = 80.0f;
    menu.nearRadius = 30.0f;
    menu.frame = contextualMenuFrame;
    menu.startPoint = CGPointMake(0, 0);
    
    return menu;
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
    self.scrollView.delaysContentTouches = NO;
}

-(void) viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    [self.animationManager showNavigationBar:self.navigationBar];
    self.navigationBar.tintColor = [[ThemeFactory currentTheme] colorForCollectionScreenNavigationBar];
}

#pragma mark - recycler delegate

-(UIView<ListRow> *) rowForIndex:(int)index withPrototype:(id<ListRow>)prototype
{
    UIView<ListRow> * row = [super rowForIndex:index withPrototype:prototype];
    
    if (row == nil) return nil;
    
    CGRect frame = [self.layoutManager frameForContextualMenuInRow:row];
    
    AwesomeMenu * contextualMenu = nil;
    if (row.contextualMenu == nil)
    {
        contextualMenu = [self createContextualMenu:row];
        row.contextualMenu = contextualMenu;
    }
    row.contextualMenu.frame = frame;
    return row;
}

-(void) didRecycledRow:(UIView<ListRow> *)row
              ForIndex:(int)index
{
    AwesomeMenu * contextualMenu = row.contextualMenu;
    if (contextualMenu == nil) NSLog(@"WE ARE IN TROUBLE");
    
    NSDictionary * viewsDictionary = NSDictionaryOfVariableBindings(contextualMenu, row);
    CGFloat distance = [self.layoutManager distanceFromRowToContextualMenu];
    NSString * layoutFormat = [NSString stringWithFormat:@"[row]->=%f-[contextualMenu]", distance];
    NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:layoutFormat
                                                                    options:NSLayoutFormatAlignAllCenterY
                                                                    metrics:nil
                                                                      views:viewsDictionary];
    
    [self.scrollView addSubview:contextualMenu];
    [row.contextualMenu setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (constraints != nil)
    {
        [self.view addConstraints:constraints];
    }
}

#pragma mark - Note Row Delegate

-(void) deletePressed:(UIView<ListRow> *) sender
{
    [self removeRow:sender];
    [self.animationManager animateRemovalForContextualMenu:sender.contextualMenu inSuperView:self.scrollView withCompletionHandler:^{
        [sender.contextualMenu removeFromSuperview];
    }];
}

-(void) doneTaskPressed:(UIView<ListRow> *)sender
{
    [self.animationManager animateSetToDone:sender];
}

-(void) undoneTaskPressed:(UIView<ListRow> *) sender
{
    [self.animationManager animateSetToUndone:sender];
}

-(void) starPressed:(UIView<ListRow> *) sender
{
    [self.animationManager animateSetToStar:sender];
}

-(void) clockPressed:(UIView<ListRow> *) sender
{
    [self.animationManager animateSetTimer:sender];
}

-(void) expandPressed:(UIView<ListRow> *) sender
{
    [self.animationManager animateExpandRow:sender];
}


-(void) tappedRow:(UIView<ListRow> *) sender
{
    [self.editingRow disableEditing:NO];
    [sender enableEditing:NO];
    self.editingRow = sender;
    self.isInEditMode = YES;
}

-(void) openSpaceForSubnotes:(int) noOfSubNotes
{
    
}
-(BOOL) isEditingRows
{
    return self.isEditing;
}

@end
