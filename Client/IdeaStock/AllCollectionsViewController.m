//
//  MainScreenDropbox.m
//  IdeaStock
//
//  Created by Ali Fathalian on 4/24/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "AllCollectionsViewController.h"
#import "CollectionViewController.h"
#import "UserPropertiesHelper.h"
#import "MindcloudAllCollections.h"
#import "CollectionCell.h"
#import "IIViewDeckController.h"
#import "NetworkActivityHelper.h"
#import "UIEventTypes.h"
#import "SharingViewController.h"
#import "CategorizationViewController.h"
#import "NamingHelper.h"
@interface AllCollectionsViewController()

@property (weak, nonatomic) UIView * lastView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray * editToolbar;
@property (strong, nonatomic) NSArray * navigateToolbar;
@property (strong, nonatomic) NSArray * cancelToolbar;
@property (strong, nonatomic) NSArray * shareToolbar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *categorizeButton;
@property (strong, nonatomic) UIColor * lastCategorizeButtonColor;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *SharingModeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *unshareButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *SubscribeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *showSideMenuButton;

@property (strong, nonatomic) UIPopoverController * lastPopOver;
@property (weak, nonatomic) IBOutlet UILabel *pageTitle;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property BOOL isEditing;
@property (strong, nonatomic) NSString * currentCategory;
@property (weak, nonatomic) UIActionSheet * activeSheet;
@property BOOL didCategoriesPresentAlertView;
@property BOOL isInSharingMode;

@property MindcloudAllCollections * model;

@end

@implementation AllCollectionsViewController

@synthesize currentCategory = _currentCategory;

#define DELETE_BUTTON @"Delete"
#define CANCEL_BUTTON @"Cancel"
#define RENAME_BUTTON @"Rename"
#define EDIT_BUTTON @"Edit"
#define CATEGORIZE_BUTTON @"Categorize"
#define SHARE_BUTTON @"Share"
#define UNSHARE_BUTTON @"Unshare"
#define SUBSCRIBE_BUTTON @"Subscribe"
#define SHARING_MODE_BUTTON @"Sharing"
#define UNSHARE_ACTION @"Unshare Collection"
#define DELETE_ACTION @"Delete Collection"
#define SUBSCRIBE_BUTTON_TITLE @"Subscribe"
#define RENAME_BUTTON_TITLE @"Rename"
#define CREATE_CATEGORY_BUTTON @"Create"
#define ADD_BUTTON_TITLE @"Add"
#define CATEGORIZATION_ROW_HEIGHT 44

-(NSString *) currentCategory
{
    if (!_currentCategory)
    {
        _currentCategory = ALL;
        self.pageTitle.text = _currentCategory;
    }
    return _currentCategory;
}

-(void) setCurrentCategory:(NSString *)currentCategory
{
    _currentCategory = currentCategory;
    self.pageTitle.text = _currentCategory;
}

#pragma mark - UI events
-(void) disableEditButtons
{
    for(UIBarButtonItem * button in self.editToolbar)
    {
        if ([button.title isEqual:DELETE_BUTTON] ||
            [button.title isEqual:RENAME_BUTTON] ||
            [button.title isEqual:CATEGORIZE_BUTTON])
        {
            button.enabled = NO;
        }
    }
}

-(void) disableShareButtons
{
    self.shareButton.enabled = NO;
    self.unshareButton.enabled = NO;
}

-(void) addCollection: (NSString *) name
{
    NSSet * allNames = [self.model getAllCollectionNames];
    name = [NamingHelper validateCollectionName:name amongAllNames:allNames];
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.model addCollection:name toCategory:self.currentCategory];
    [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

-(void) renameCollection: (NSString *) newName
{
    NSArray * selectedItems = [self.collectionView indexPathsForSelectedItems];
    for(NSIndexPath * selectedItem in selectedItems)
    {
        CollectionCell * selectedCell = (CollectionCell *)[self.collectionView cellForItemAtIndexPath:selectedItem];
        NSString * currentName = selectedCell.text;
        
        if ([newName isEqualToString:currentName]) continue;
        
        NSSet * allNames = [self.model getAllCollectionNames];
        NSString * actualNewName = [NamingHelper validateCollectionName:currentName amongAllNames:allNames];
        
        [self.model renameCollection:currentName
                          inCategory:self.currentCategory
                     toNewCollection:actualNewName];
        
        selectedCell.text = actualNewName;
        
    }
}

-(void) deleteCollection
{
    NSArray * selectedItems = [self.collectionView indexPathsForSelectedItems];
    NSMutableArray * batchDeleteCollections = [NSMutableArray array];
    for (NSIndexPath * selectedItem in selectedItems)
    {
        NSString * collectionName = [self.model getCollectionAt:selectedItem.item forCategory:self.currentCategory];
        [batchDeleteCollections addObject:collectionName];
    }
    
    [self.model batchRemoveCollections:batchDeleteCollections fromCategory:self.currentCategory];
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:selectedItems];
    }completion:nil];
}

-(void) addNewCategory: (NSString *) categoryName
{
    //validate the name
    NSArray * categoryNames = [self.model getAllCategories];
    categoryName = [NamingHelper getBestNameFor:categoryName
                                  amongAllNAmes:categoryNames];
    [self.model addCategory:categoryName];
    //find the right place for the item in the sorted order
    int indexInt = [[self.model getAllCategories] indexOfObject:categoryName];
    NSIndexPath * index =  [NSIndexPath indexPathForItem:indexInt inSection:0];
    [self.categoriesController.table insertRowsAtIndexPaths:@[index] withRowAnimation: UITableViewRowAnimationAutomatic];
}

-(void) updateCollectionView:(NSString *) categoryName
{
    self.currentCategory = categoryName;
    [self.collectionView reloadData];
}

-(void) exitCategorizeMode
{
    self.isEditing = NO;
    [self.collectionView setAllowsMultipleSelection:NO];
    [self disableEditButtons];
    self.toolbar.items = self.navigateToolbar;
    [self.categoriesController exitEditMode];
}

-(void) dismissPopOver
{
    if (self.lastPopOver != nil){
        [self.lastPopOver dismissPopoverAnimated:YES];
        self.lastPopOver = nil;
    }
}

-(void) swithToCategory:(NSString *) newCategoryName
{
    [self disableEditButtons];
    [self updateCollectionView:newCategoryName];
    if (![self.currentCategory isEqualToString:ALL] &&
        ![self.currentCategory isEqualToString:UNCATEGORIZED_KEY] &&
        ![self.currentCategory isEqualToString:SHARED_COLLECTIONS_KEY])
    {
        self.categoriesController.renameMode = YES;
    }
}

- (IBAction)cancelPressed:(id)sender {
    
    self.isEditing = NO;
    self.isInSharingMode = NO;
    [self.collectionView setAllowsMultipleSelection:NO];
    self.toolbar.items = self.navigateToolbar;
    NSArray * selectedItem = [self.collectionView indexPathsForSelectedItems];
    for (NSIndexPath * selIndex in selectedItem)
    {
        [self.collectionView deselectItemAtIndexPath:selIndex animated:YES];
    }
    //make sure Delete and Rename buttons are in disabled state
    [self disableEditButtons];
    [self disableShareButtons];
    
    [self dismissPopOver];
    [self.activeSheet dismissWithClickedButtonIndex:-1 animated:YES];
}

- (IBAction)editPressed:(id)sender {
    
    [self.collectionView setAllowsMultipleSelection:YES];
    self.isEditing = YES;
    self.toolbar.items = self.editToolbar;
}
- (IBAction)SharingModePressed:(id)sender {
    [self.collectionView setAllowsMultipleSelection:NO];
    self.isInSharingMode = YES;
    self.toolbar.items = self.shareToolbar;
}
- (IBAction)unsharePressed:(id)sender {
    
    [self dismissPopOver];
    
    UIActionSheet * action = [[UIActionSheet alloc] initWithTitle:nil
                                                         delegate:self
                                                cancelButtonTitle:nil
                                           destructiveButtonTitle:UNSHARE_ACTION
                                                otherButtonTitles:nil,
                              nil];
    //make sure an actionsheet is not presented on top of another not dismissed one
    if (self.activeSheet)
    {
        [self.activeSheet dismissWithClickedButtonIndex:-1 animated:NO];
        self.activeSheet = nil;
    }
    [action showFromBarButtonItem:sender animated:NO];
    self.activeSheet = action;
}

- (IBAction)subscribePressed:(id)sender {
    
    [self.activeSheet dismissWithClickedButtonIndex:-1 animated:YES];
    [self dismissPopOver];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Enter The code received from the owner of the collection"
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:SUBSCRIBE_BUTTON_TITLE,nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(IBAction) addPressed:(id)sender {
    
    [self dismissPopOver];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Enter The Name of The Collection"
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:ADD_BUTTON_TITLE, nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (IBAction)renamePressed:(id)sender {
    [self dismissPopOver];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Enter The New Name of The Collection"
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:RENAME_BUTTON_TITLE,nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //perform add collection
    if (buttonIndex == 1){
        if (self.didCategoriesPresentAlertView)
        {
            if ([[alertView buttonTitleAtIndex:buttonIndex]
                 isEqualToString:RENAME_BUTTON_TITLE])
            {
                NSIndexPath * indexPath = [self.categoriesController.table indexPathForSelectedRow];
                UITableViewCell * selectedCell= [self.categoriesController.table cellForRowAtIndexPath:indexPath];
                NSString * categoryName = selectedCell.textLabel.text;
                NSString * newCategoryName = [[alertView textFieldAtIndex:0] text];
                [self.model renameCategory:categoryName toNewCategory:newCategoryName];
                selectedCell.textLabel.text = newCategoryName;
            }
        }
        else
        {
            if ([[alertView buttonTitleAtIndex:buttonIndex]
                 isEqualToString:ADD_BUTTON_TITLE])
            {
                NSString * name = [[alertView textFieldAtIndex:0] text];
                [self addCollection:name];
            }
            else if ([[alertView buttonTitleAtIndex:buttonIndex]
                      isEqualToString:RENAME_BUTTON_TITLE])
            {
                NSString * newName = [[alertView textFieldAtIndex:0] text];
                [self renameCollection:newName];
                [self disableEditButtons];
                self.toolbar.items = self.navigateToolbar;
                [self deselectAll];
                self.isInSharingMode = NO;
                self.isEditing = NO;
            }
            else if ([[alertView buttonTitleAtIndex:buttonIndex]
                      isEqualToString:CREATE_CATEGORY_BUTTON])
            {
                NSString * newName = [[alertView textFieldAtIndex:0] text];
                [self addNewCategory:newName];
            }
            else if ([[alertView buttonTitleAtIndex:buttonIndex]
                      isEqualToString:SUBSCRIBE_BUTTON_TITLE])
            {
                NSString * sharingSecret =[[alertView textFieldAtIndex:0] text];
                sharingSecret = [sharingSecret uppercaseString];
                [self.model subscribeToCollectionWithSecret:sharingSecret];
            }
        }
    }
}


-(void) deselectAll
{
    for (NSIndexPath * index in self.collectionView.indexPathsForSelectedItems)
    {
        [self.collectionView deselectItemAtIndexPath:index animated:YES];
    }
}

- (IBAction)deletePressed:(id)sender {
    [self dismissPopOver];
    UIActionSheet * action = [[UIActionSheet alloc] initWithTitle:nil
                                                         delegate:self
                                                cancelButtonTitle:nil
                                           destructiveButtonTitle:DELETE_ACTION
                                                otherButtonTitles:nil,
                              nil];
    //make sure an actionsheet is not presented on top of another not dismissed one
    if (self.activeSheet)
    {
        [self.activeSheet dismissWithClickedButtonIndex:-1 animated:NO];
        self.activeSheet = nil;
    }
    [action showFromBarButtonItem:sender animated:NO];
    self.activeSheet = action;
}


- (IBAction)refreshPressed:(id)sender {
    
    [self dismissPopOver];
    [self.model refresh];
}

- (IBAction)categorizedPressed:(id)sender {
    
    [self.activeSheet dismissWithClickedButtonIndex:-1 animated:YES];
    [self dismissPopOver];
    
    CategorizationViewController * categorizationController = [self.storyboard instantiateViewControllerWithIdentifier:@"CategorizationView"];
    
    categorizationController.delegate = self;
    categorizationController.rowHeight = CATEGORIZATION_ROW_HEIGHT;
    categorizationController.categories = [self.model getEditableCategories];
    CGSize popOverContentSize = [categorizationController getBestPopoverContentSize];
    UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:categorizationController];
    self.lastPopOver = popover;
    self.lastPopOver.delegate = self;
    if (popOverContentSize.height > 0 && popOverContentSize.width > 0)
    {
        popover.popoverContentSize = popOverContentSize;
    }
    else
    {
        popover.popoverContentSize = CGSizeMake(200, 400);
    }
    [popover presentPopoverFromBarButtonItem:self.categorizeButton
                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                    animated:YES];
    
}

- (IBAction)sharePressed:(id)sender {
    
    [self.activeSheet dismissWithClickedButtonIndex:-1 animated:YES];
    NSString * collectionName = [self getSelectedCollectionName];
    
    if (collectionName == nil) return;
    
    
    //manage the pop over
    [self dismissPopOver];
    SharingViewController * sharingController = [self.storyboard instantiateViewControllerWithIdentifier:@"SharingView"];
    sharingController.collectionName = collectionName;
    
    UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:sharingController];
    self.lastPopOver = popover;
    self.lastPopOver.delegate = self;
    //sharingController.contentSizeForViewInPopover = CGSizeMake(370, 200);
    popover.popoverContentSize = CGSizeMake(300, 70);
    [popover presentPopoverFromBarButtonItem:self.shareButton
                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                    animated:YES];
    
    [self.model shareCollection:collectionName];
}

- (IBAction)showCategoriesPressed:(id)sender {
    
    [self.viewDeckController toggleLeftViewAnimated:YES];
}


-(void) addInitialListeners
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ApplicationHasGoneInBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resizePopOver:)
                                                 name:RESIZE_POPOVER_FOR_SECRET
                                               object:nil];
    
    
}

-(void) viewDidLoad{
    [super viewDidLoad];
    [self.collectionView setAllowsMultipleSelection:NO];
    [self manageToolbars];
    self.isEditing = NO;
    self.isInSharingMode = NO;
    self.toolbar.items = self.navigateToolbar;
    [self configureCategoriesPanel];
    [self addInitialListeners];
    
    self.model = [[MindcloudAllCollections alloc] initWithDelegate:self];
    
    [self.categoriesController.table reloadData];
    //to synchronize the categories with reality
    [self configureCategoriesPanel];
    [self.collectionView reloadData];
}

-(void) configureCategoriesPanel
{
    //make sure that viewDecks ledges are correct
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        CGFloat screenHeight = screenRect.size.height;
        self.viewDeckController.leftLedge = 2.25 * screenHeight / 3 ;
        CGRect newFrame = CGRectMake(self.categoriesController.view.frame.origin.x,
                                     self.categoriesController.view.frame.origin.y,
                                     screenHeight - self.viewDeckController.leftLedge,
                                     self.categoriesController.view.frame.size.height);
        self.categoriesController.table.frame = newFrame;
        
    }
    else
    {
        CGFloat screenWidth = screenRect.size.width;
        self.viewDeckController.leftLedge = 2.00 * screenWidth / 3 ;
        
        CGRect newFrame = CGRectMake(self.categoriesController.view.frame.origin.x,
                                     self.categoriesController.view.frame.origin.y,
                                     screenWidth - self.viewDeckController.leftLedge,
                                     self.categoriesController.view.frame.size.height);
        self.categoriesController.table.frame = newFrame;
    }
}

-(void) manageToolbars
{
    NSMutableArray *  editbar = [NSMutableArray array];
    NSMutableArray *  navbar = [NSMutableArray array];
    NSMutableArray *  cancelbar = [NSMutableArray array];
    NSMutableArray * sharebar = [NSMutableArray array];
    for (UIBarButtonItem * barButton in self.toolbar.items)
    {
        if ([barButton.title isEqualToString:CANCEL_BUTTON])
        {
            [cancelbar addObject:barButton];
            [editbar addObject:barButton];
            [sharebar addObject:barButton];
        }
        else if ([barButton.title isEqual: RENAME_BUTTON] ||
                 [barButton.title isEqual: DELETE_BUTTON] ||
                 [barButton.title isEqual: CATEGORIZE_BUTTON])
        {
            [editbar addObject:barButton];
        }
        else if ([barButton.title isEqual:EDIT_BUTTON] ||
                 [barButton.title isEqual:SHARING_MODE_BUTTON] ||
                 barButton == self.showSideMenuButton)
        {
            [navbar addObject:barButton];
        }
        else if ([barButton.title isEqual:SHARE_BUTTON] ||
                 [barButton.title isEqual:UNSHARE_BUTTON] ||
                 [barButton.title isEqual:SUBSCRIBE_BUTTON])
        {
            [sharebar addObject:barButton];
        }
        else
        {
            [editbar addObject:barButton];
            [navbar  addObject:barButton];
            [cancelbar addObject:barButton];
            [sharebar addObject:barButton];
        }
    }
    self.editToolbar = [editbar copy];
    self.navigateToolbar = [navbar copy];
    self.cancelToolbar = [cancelbar copy];
    self.shareToolbar = [sharebar copy];
}


-(void) viewDidUnload{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self configureCategoriesPanel];
}

#pragma mark - Notifications

-(void) ApplicationHasGoneInBackground:(NSNotification *) notification
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) applicationWillEnterForeground:(NSNotification *) notification
{
    //[self addInitialListeners];
    if (self.presentedViewController &&
        [self.presentedViewController isKindOfClass:[CollectionViewController class]])
    {
        
        CollectionViewController * controller = (CollectionViewController *) self.presentedViewController;
        [controller applicationWillEnterForeground:notification];
    }
}

-(void) resizePopOver:(NSNotification * )notification
{
    //    [self.lastPopOver dismissPopoverAnimated:YES];
    if (self.lastPopOver != nil)
    {
        CGSize bigSize = CGSizeMake(320, 200);
        [self.lastPopOver setPopoverContentSize:bigSize animated:YES];
    }
}



#pragma mark - Operation Helpers

- (NSString *) getSelectedCollectionName
{
    
    NSArray * selectedItems = [self.collectionView indexPathsForSelectedItems];
    if ([selectedItems count] == 0)
    {
        return nil;
    }
    else
    {
        CollectionCell * selectedItem = (CollectionCell *) [self.collectionView cellForItemAtIndexPath:selectedItems[0]];
        NSString * collectionName = selectedItem.text;
        return collectionName;
    }
}

- (NSIndexPath *) getIndexPathForCollectionIfVisible:(NSString *) collectionName
{
    for (NSIndexPath * index in self.collectionView.indexPathsForVisibleItems)
    {
        UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:index];
        if ([cell isKindOfClass:[CollectionCell class]])
        {
            CollectionCell * answer = (CollectionCell *) cell;
            if ([answer.text isEqualToString:collectionName])
            {
                return index;
            }
        }
    }
    return nil;
}

#pragma mark - CollectionViewController Delegates

-(void) finishedWorkingWithCollection:(NSString *)collectionName
                    withThumbnailData:(NSData *)imgData
{
    NSIndexPath * cellIndex  = [self getIndexPathForCollectionIfVisible:collectionName];
    CollectionCell * updatedItem = (CollectionCell * )[self.collectionView cellForItemAtIndexPath:cellIndex];
    if (imgData)
    {
        [self.model setImageData:imgData forCollection:collectionName];
        updatedItem.img = [UIImage imageWithData:imgData];
    }
    [self.collectionView deselectItemAtIndexPath:cellIndex animated:NO];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView Delegates

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.model numberOfCollectionsInCategory:self.currentCategory] ;
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    NSString * collectionName = [self.model getCollectionAt:indexPath.item forCategory:self.currentCategory];
    if ([cell isKindOfClass:[CollectionCell class]])
    {
        CollectionCell * colCell = (CollectionCell *)cell;
        colCell.text = collectionName;
        
        //we lazily load images and make sure we cache them
        //so any time that a cell is asked for we retrieve and cache the imag
        NSData * previewImageData = [self.model getImageDataForCollection: collectionName];
        
        
        if (previewImageData == nil)
        {
            colCell.img = [UIImage imageNamed:@"felt-red-ipad-background.jpg"];
        }
        else if ([colCell.text isEqualToString:collectionName])
        {
            colCell.img = [UIImage imageWithData:previewImageData];
        }
    }
    
    return cell;
}

-(BOOL) collectionView:(UICollectionView *) collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //enable the edit bar buttons
    if (self.isEditing)
    {
        for (UIBarButtonItem * button in self.toolbar.items)
        {
            button.enabled = YES;
        }
    }
    else if (self.isInSharingMode)
    {
        self.shareButton.enabled = YES;
        self.unshareButton.enabled = YES;
    }
    else
    {
        //present the collection view
        NSString * name = [self getSelectedCollectionName];
        
        if (!name) return;
        
        CollectionViewController * collectionView = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectionView"];
        collectionView.bulletinBoardName = name;
        collectionView.parent = self;
        MindcloudCollection * board =
        [[MindcloudCollection alloc] initCollection:name];
        collectionView.board = board;
        
        collectionView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:collectionView animated:YES completion:^(void){}];
    }
    
}

-(void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //if nothing is selected disable edit buttons
    if ([[self.collectionView indexPathsForSelectedItems] count] == 0)
    {
        [self disableEditButtons];
    }
}

-(BOOL) collectionView:(UICollectionView *) collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(CGSize) collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(250, 250);
}

-(UIEdgeInsets) collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 5,40, 20);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section + 1 for add place holder
    //FIXME: a hack to add an empty cell below everything else so that the last cel won't get cut off
    return [self.model numberOfCategories] + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.item < [self.model numberOfCategories])
    {
        //if its not the placeholder
        NSString * categoryName = [self.model getAllCategories][indexPath.item];
        cell.textLabel.text = categoryName;
    }
    else
    {
        cell.textLabel.text = @"";
    }
    return cell;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        UITableViewCell * cell = [self.categoriesController.table cellForRowAtIndexPath:indexPath];
        NSString * categoryName = cell.textLabel.text;
        [self.model removeCategory:categoryName];
        if ([self.model canRemoveCategory: categoryName])
        {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Enter The Name of The Category"
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:CREATE_CATEGORY_BUTTON, nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
}

-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < [self.model numberOfCategories])
    {
        //its the edit place holder
        NSString * selectedCellText = [self.categoriesController.table cellForRowAtIndexPath:indexPath].textLabel.text;
        //ALL and Uncategorized cateogires are uneditable
        if (![self.model isCategoryEditable:selectedCellText])
        {
            return UITableViewCellEditingStyleNone;
        }
        else
        {
            return UITableViewCellEditingStyleDelete;
        }
        
    }
    else if (indexPath.item ==[self.model numberOfCategories] )
        return UITableViewCellEditingStyleInsert;
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

#pragma mark - action sheet delegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) return;
    NSString * actionName = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([actionName isEqualToString:DELETE_ACTION])
    {
        [self deleteCollection];
        //make sure after deletion DELETE and RENAME buttons are disabled
        [self disableEditButtons];
        self.toolbar.items = self.navigateToolbar;
        self.isEditing = NO;
        self.isInSharingMode = NO;
    }
    else if ([actionName isEqualToString:UNSHARE_ACTION])
    {
        NSString * collectionName = [self getSelectedCollectionName];
        if (collectionName != nil)
        {
            [self.model unshareCollection:collectionName];
        }
        NSArray * selectedItems = [self.collectionView indexPathsForSelectedItems];
        for (NSIndexPath * index in selectedItems)
        {
            [self.collectionView deselectItemAtIndexPath:index animated:YES];
        }
        self.unshareButton.enabled = NO;
        self.shareButton.enabled = NO;
        self.toolbar.items = self.navigateToolbar;
        self.isEditing = NO;
        self.isInSharingMode = NO;
    }
    
}

#pragma mark - Table view delegate

//don't show filler cells
-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < [self.model numberOfCategories])
    {
        return indexPath;
        
    }
    else
    {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString * categoryName = cell.textLabel.text;
    [self swithToCategory:categoryName];
}

- (void) tableView: (UITableView *) tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.categoriesController.renameMode = NO;
}


-(void) tableView:(UITableView *)tableView renamePressedForItemAt: (NSIndexPath *) index
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Enter The New Name of The Category"
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:RENAME_BUTTON_TITLE, nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    self.didCategoriesPresentAlertView = YES;
    [alert show];
    
}

#pragma mark - pop over delegate
-(void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self deselectAll];
    [self disableShareButtons];
    [self disableEditButtons];
    self.toolbar.items = self.navigateToolbar;
    self.isEditing = NO;
    self.isInSharingMode = NO;
    
}

#pragma mark - Categorization delegate

-(void) categorizationHappenedForCategory:(NSString *) categoryName
{
    [self dismissPopOver];
    
    if ([self.currentCategory isEqualToString:categoryName]) return;
    
    if ([categoryName isEqualToString:ALL]
        || [categoryName isEqualToString:SHARED_COLLECTIONS_KEY] )
    {
        return;
    }
    
    for(NSIndexPath * index in [self.collectionView indexPathsForSelectedItems])
    {
        CollectionCell * collectionCell = (CollectionCell *)[self.collectionView cellForItemAtIndexPath:index];
        NSString * collectionName = collectionCell.text;
        [self.model moveCollection:collectionName fromCategory:self.currentCategory toNewCategory:categoryName];
    }
    if (![self.currentCategory isEqual:ALL] &&
        ![self.currentCategory isEqualToString:SHARED_COLLECTIONS_KEY])
    {
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:[self.collectionView indexPathsForSelectedItems]];
        }completion:^(BOOL finished){
            
            [self exitCategorizeMode];
        }];
    }
    else
    {
        [self exitCategorizeMode];
    }
    [self deselectAll];
    
}

#pragma mark - MindcloudAllCollectionsDelegate
-(NSString *) activeCategory
{
    return self.currentCategory;
}

-(void) collectionsLoaded;
{
    [self.collectionView reloadData];
    [self.categoriesController.table reloadData];
}

-(void) categoriesLoaded
{
    [self.collectionView reloadData];
    [self.categoriesController.table reloadData];
    [self configureCategoriesPanel];
}

-(void) thumbnailLoadedForCollection:(NSString *) collectionName
                       withImageData:(NSData *) imgData
{
    NSIndexPath * updatedItem = [self getIndexPathForCollectionIfVisible:collectionName];
    if (updatedItem)
    {
        //[self.collectionView reloadItemsAtIndexPaths:@[updatedItem]];
        UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:updatedItem];
        CollectionCell * actualCell = (CollectionCell *) cell;
        actualCell.img =[UIImage imageWithData:imgData];
    }
}

-(void) sharedCollection:(NSString *)collectionName
              withSecret:(NSString *)sharingSecret
{
   //highlight the sharedcollection
    //see if the last pop over is still for sharingViewController and pass the
    //sharing secret to it if it is
    if (self.lastPopOver != nil)
    {
        UIViewController * vc = self.lastPopOver.contentViewController;
        if (vc != nil && [vc isKindOfClass:[SharingViewController class]])
        {
            SharingViewController * presentedPopOver = (SharingViewController *) vc;
            NSString * presentedCollectionName = presentedPopOver.collectionName;
            if ([presentedCollectionName isEqualToString:collectionName])
            {
                presentedPopOver.sharingSecret = sharingSecret;
            }
        }
    }
}
-(void) failedToSubscribeToSecret
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sharing Secret Not Recognized, Try again"
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:SUBSCRIBE_BUTTON_TITLE,nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void) subscribedToCollectionWithName:(NSString *) collectionName
{
    //highlight the colleciton in the UI
    [self swithToCategory:SHARED_COLLECTIONS_KEY];
    self.isInSharingMode = NO;
    self.isEditing = NO;
    self.toolbar.items = self.navigateToolbar;
}

-(void) alreadySubscribedToCollectionWithName:(NSString *) collectionName
{
    NSString * alertViewMsg = [NSString stringWithFormat:@"You have already subscribed to collection %@", collectionName];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Existing Subscription"
                                                     message:alertViewMsg
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [self swithToCategory:SHARED_COLLECTIONS_KEY];
    [alert show];
}

@end