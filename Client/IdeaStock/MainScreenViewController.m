//
//  MainScreenDropbox.m
//  IdeaStock
//
//  Created by Ali Fathalian on 4/24/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MainScreenViewController.h"
#import "CollectionViewController.h"
#import "Mindcloud.h"
#import "UserPropertiesHelper.h"
#import "CollectionsModel.h"
#import "CollectionCell.h"
#import "IIViewDeckController.h"
#import "XoomlCategoryParser.h"
#import "CachedMindCloudDataSource.h"
#import "NetworkActivityHelper.h"
#import "EventTypes.h"
#import "CollectionDataSource.h"
#import "CachedMindCloudDataSource.h"

#define ACTION_TYPE_CREATE_FOLDER @"createFolder"
#define ACTION_TYPE_UPLOAD_FILE @"uploadFile"

@interface MainScreenViewController()

@property (weak, nonatomic) UIView * lastView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray * editToolbar;
@property (strong, nonatomic) NSArray * navigateToolbar;
@property (strong, nonatomic) NSArray * cancelToolbar;
@property (weak, nonatomic) IBOutlet UILabel *pageTitle;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property BOOL isEditing;
@property (strong, nonatomic) NSString * currentCategory;
@property (weak, nonatomic) UIActionSheet * activeSheet;
@property BOOL didCategoriesPresentAlertView;
@property BOOL isInCategorizeMode;
@property CollectionsModel * model;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *categorizeButton;
@property (strong, nonatomic) UIColor * lastCategorizeButtonColor;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property BOOL shouldSaveCategories;
@property (atomic,strong) NSTimer * timer;
@property (strong, nonatomic) id<MindcloudDataSource> dataSource;
@end

@implementation MainScreenViewController

@synthesize currentCategory = _currentCategory;
@synthesize isInCategorizeMode = _isInCategorizeMode;

#define DONE_BUTTON @"Done"
#define DELETE_BUTTON @"Delete"
#define CANCEL_BUTTON @"Cancel"
#define RENAME_BUTTON @"Rename"
#define EDIT_BUTTON @"Edit"
#define CATEGORIZE_BUTTON @"Categorize"

-(BOOL) isInCategorizeMode
{
    return _isInCategorizeMode;
}

-(void) setIsInCategorizeMode:(BOOL)isInCategorizeMode
{
    _isInCategorizeMode = isInCategorizeMode;
    if (_isInCategorizeMode)
    {
        //        self.categorizeButton.title = DONE_BUTTON;
        //        self.lastCategorizeButtonColor = self.categorizeButton.tintColor;
        //        self.categorizeButton.tintColor = self.cancelButton.tintColor;
        [self.viewDeckController openLeftViewAnimated:YES];
        self.toolbar.items = self.cancelToolbar;
    }
    else
    {
        self.categorizeButton.title = CATEGORIZE_BUTTON;
        self.categorizeButton.tintColor = self.lastCategorizeButtonColor;
        [self.viewDeckController closeLeftViewAnimated:YES];
        self.toolbar.items = self.navigateToolbar;
    }
}
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

-(id<MindcloudDataSource>) dataSource
{
    if (!_dataSource)
    {
        _dataSource = [[CachedMindCloudDataSource alloc] init];
    }
    return _dataSource;
}

#pragma mark - Timer
#define SYNCHRONIZATION_PERIOD 3
-(void) startTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval: SYNCHRONIZATION_PERIOD
                                                  target:self
                                                selector:@selector(saveCategories:)
                                                userInfo:nil
                                                 repeats:YES];
}

-(void) stopTimer{
    [self.timer invalidate];
}

#pragma mark - Initilizers

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - UI Events Helpers

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

-(void) addCollection: (NSString *) name
{
    name = [self validateName: name];
    [self.dataSource addCollectionWithName:name];
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
        
        NSString * actualNewName = [self validateName:newName];
        [self.dataSource renameCollectionWithName:currentName to:newName];
        
        [self.model renameCollection:currentName
                          inCategory:self.currentCategory
                     toNewCollection:actualNewName];
        
        selectedCell.text = actualNewName;
        
    }
}

/*
 Perform some simple error checking on a collection name
 Return the suggested name
 */
-(NSString *) validateName: (NSString *) name
{
    int counter = 1;
    NSString * finalName = name;
    while ([self.model doesNameExist:finalName])
    {
        finalName = [NSString stringWithFormat:@"%@%d",name,counter];
        counter++;
    }
    
    //so that no one can hack folder hierarchy
    finalName = [finalName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    //protect escape characters
    finalName = [finalName stringByReplacingOccurrencesOfString:@"\\" withString:@"_"];
    finalName = [finalName stringByReplacingOccurrencesOfString:@"~" withString:@"_"];
    NSString * withoutSpaces = [finalName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (withoutSpaces.length == 0)
    {
        finalName = [finalName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    }
    
    return finalName;
}


-(void) deleteCollection
{
    NSArray * selectedItems = [self.collectionView indexPathsForSelectedItems];
    for (NSIndexPath * selectedItem in selectedItems)
    {
        CollectionCell * selectedCell = (CollectionCell *)[self.collectionView cellForItemAtIndexPath:selectedItem];
        NSString * collectionName = selectedCell.text;
        [self.model removeCollection:collectionName fromCategory:self.currentCategory];
        [self.dataSource deleteCollectionFor:collectionName];
    }
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:selectedItems];
    }completion:nil];
}

-(void) addNewCategory: (NSString *) categoryName
{
    //validate the name
    categoryName = [self validateCategoryName:categoryName];
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
    self.isInCategorizeMode = NO;
    self.isEditing = NO;
    [self.collectionView setAllowsMultipleSelection:NO];
    [self disableEditButtons];
    self.toolbar.items = self.navigateToolbar;
    [self.categoriesController exitEditMode];
}
-(NSString *) validateCategoryName: (NSString *) candidateName
{
    //fix duplicates
    NSArray * categoryNames = [self.model getAllCategories];
    NSString * tempName = candidateName;
    int counter = 1;
    while ([categoryNames containsObject:tempName])
    {
        tempName = [candidateName stringByAppendingFormat:@"%d",counter];
        counter++;
    }
    return tempName;
}

#pragma mark - UI Events

- (IBAction)cancelPressed:(id)sender {
    
    self.isEditing = NO;
    [self.collectionView setAllowsMultipleSelection:NO];
    self.toolbar.items = self.navigateToolbar;
    NSArray * selectedItem = [self.collectionView indexPathsForSelectedItems];
    for (NSIndexPath * selIndex in selectedItem)
    {
        [self.collectionView deselectItemAtIndexPath:selIndex animated:YES];
    }
    //make sure Delete and Rename buttons are in disabled state
    [self disableEditButtons];
    if (self.isInCategorizeMode)
        self.isInCategorizeMode = NO;
}

- (IBAction)editPressed:(id)sender {
    
    [self.collectionView setAllowsMultipleSelection:YES];
    self.isEditing = YES;
    self.toolbar.items = self.editToolbar;
}

#define ADD_BUTTON_TITLE @"Add"
-(IBAction) addPressed:(id)sender {
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Enter The Name of The Collection"
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:ADD_BUTTON_TITLE, nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}
#define RENAME_BUTTON_TITLE @"Rename"
#define CREATE_CATEGORY_BUTTON @"Create"

- (IBAction)renamePressed:(id)sender {
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
                self.shouldSaveCategories = YES;
            }
        }
        else
        {
            if ([[alertView buttonTitleAtIndex:buttonIndex]
                 isEqualToString:ADD_BUTTON_TITLE])
            {
                NSString * name = [[alertView textFieldAtIndex:0] text];
                [self addCollection:name];
                self.shouldSaveCategories = YES;
            }
            else if ([[alertView buttonTitleAtIndex:buttonIndex]
                      isEqualToString:RENAME_BUTTON_TITLE])
            {
                NSString * newName = [[alertView textFieldAtIndex:0] text];
                [self renameCollection:newName];
                self.shouldSaveCategories = YES;
            }
            else if ([[alertView buttonTitleAtIndex:buttonIndex]
                      isEqualToString:CREATE_CATEGORY_BUTTON])
            {
                NSString * newName = [[alertView textFieldAtIndex:0] text];
                [self addNewCategory:newName];
                self.shouldSaveCategories = YES;
            }
        }
    }
}


- (IBAction)deletePressed:(id)sender {
    UIActionSheet * action = [[UIActionSheet alloc] initWithTitle:nil
                                                         delegate:self
                                                cancelButtonTitle:nil
                                           destructiveButtonTitle:@"Delete Collection"
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

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) return;
    [self deleteCollection];
    self.shouldSaveCategories = YES;
    //make sure after deletion DELETE and RENAME buttons are disabled
    [self disableEditButtons];
    
}

- (IBAction)refreshPressed:(id)sender {
    
    //wait for the notification  of the retrieval
   [self.dataSource getAllCollections];
}

- (IBAction)categorizedPressed:(id)sender {
    
    self.isInCategorizeMode = !self.isInCategorizeMode;
}

- (IBAction)showCategoriesPressed:(id)sender {
    
    [self.viewDeckController toggleLeftViewAnimated:YES];
}

-(void) viewWillAppear:(BOOL)animated{
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

-(void) viewDidLoad{
    
    [super viewDidLoad];
    [self.collectionView setAllowsMultipleSelection:NO];
    [self manageToolbars];
    self.isEditing = NO;
    self.toolbar.items = self.navigateToolbar;
    [self configureCategoriesPanel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ApplicationHasGoneInBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(allCollectionsReceived:)
                                                 name: ALL_COLLECTIONS_LIST_DOWNLOADED_EVENT
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(categoriesReceived:)
                                                 name: CATEGORIES_RECEIVED_EVENT
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(thumbnailReceived:)
                                                 name: THUMBNAIL_RECEIVED_EVENT
                                               object:nil];
    
    //temproary use this tell you get further notification
    NSArray * allCollections = [self.dataSource getAllCollections];
    
    self.model = [[CollectionsModel alloc] initWithCollections:allCollections];
    
    NSDictionary* dict = [self.dataSource getCategories];
    [self.model applyCategories:dict];
    [self.categoriesController.table reloadData];
    //to synchronize the categories with reality
    [self configureCategoriesPanel];
    [self.collectionView reloadData];
    [self startTimer];
}

-(void) allCollectionsReceived:(NSNotification *) notification
{
    NSArray* allCollections = notification.userInfo[@"result"];
    self.model = [[CollectionsModel alloc] initWithCollections:allCollections];
    [self.collectionView reloadData];
    [self.categoriesController.table reloadData];
}

-(void) categoriesReceived:(NSNotification *) notification
{
    
    NSDictionary * dict = notification.userInfo[@"result"];
    [self.model applyCategories:dict];
    [self.collectionView reloadData];
    [self.categoriesController.table reloadData];
    //to synchronize the categories with reality
    self.shouldSaveCategories = YES;
    [self saveCategories];
    [self configureCategoriesPanel];
}

-(void) thumbnailReceived:(NSNotification *) notification
{
    
    NSDictionary * dict = notification.userInfo[@"result"];
    NSString * collectionName = dict[@"collectionName"];
    NSData * imgData = dict[@"data"];
    //if there is no image on the server use our default image
    if (!imgData)
    {
        UIImage * defaultImage = [UIImage imageNamed: @"felt-red-ipad-background.jpg"];
        imgData = UIImageJPEGRepresentation(defaultImage, 1);
    }
    
    [self.model setImageData:imgData forCollection:collectionName];
    
    NSIndexPath * updatedItem = [self getIndexPathForCollectionIfVisible:collectionName];
    if (updatedItem)
    {
        //[self.collectionView reloadItemsAtIndexPaths:@[updatedItem]];
        UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:updatedItem];
        CollectionCell * actualCell = (CollectionCell *) cell;
        actualCell.img =[UIImage imageWithData:imgData];
    }
    [NetworkActivityHelper removeActivityInProgress];
}
-(void) configureCategoriesPanel
{
    //make sure that viewDecks ledges are correct
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        CGFloat screenHeight = screenRect.size.height;
        self.viewDeckController.leftLedge = 2 * screenHeight / 3 ;
        CGRect newFrame = CGRectMake(self.categoriesController.view.frame.origin.x,
                                     self.categoriesController.view.frame.origin.y,
                                     screenHeight - self.viewDeckController.leftLedge,
                                     self.categoriesController.view.frame.size.height);
        self.categoriesController.table.frame = newFrame;
    }
    else
    {
        CGFloat screenWidth = screenRect.size.width;
        self.viewDeckController.leftLedge = 1.75 * screenWidth / 3 ;
        CGRect newFrame = CGRectMake(self.categoriesController.view.frame.origin.x,
                                     self.categoriesController.view.frame.origin.y,
                                     screenWidth - self.viewDeckController.leftLedge,
                                     self.categoriesController.view.frame.size.height);
        self.categoriesController.table.frame = newFrame;
    }
    
    if (self.viewDeckController.leftControllerIsOpen)
        [self.viewDeckController openLeftView];
    
}
-(void) manageToolbars
{
    NSMutableArray *  editbar = [NSMutableArray array];
    NSMutableArray *  navbar = [NSMutableArray array];
    NSMutableArray *  cancelbar = [NSMutableArray array];
    for (UIBarButtonItem * barButton in self.toolbar.items)
    {
        if ([barButton.title isEqualToString:CANCEL_BUTTON])
        {
            [cancelbar addObject:barButton];
            [editbar addObject:barButton];
        }
        else if ([barButton.title isEqual: RENAME_BUTTON] ||
                 [barButton.title isEqual: DELETE_BUTTON] ||
                 [barButton.title isEqual: CATEGORIZE_BUTTON])
        {
            [editbar addObject:barButton];
        }
        else if ([barButton.title isEqual:EDIT_BUTTON])
        {
            [navbar addObject:barButton];
        }
        else
        {
            [editbar addObject:barButton];
            [navbar  addObject:barButton];
            [cancelbar addObject:barButton];
        }
    }
    self.editToolbar = [editbar copy];
    self.navigateToolbar = [navbar copy];
    self.cancelToolbar = [cancelbar copy];
    
}


-(void) viewDidUnload{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self saveCategories];
    [self stopTimer];
    [super viewDidUnload];
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self configureCategoriesPanel];
}

#pragma mark - Notifications

-(void) ApplicationHasGoneInBackground:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self saveCategories];
    [self stopTimer];
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

#pragma mark - Bulletinboard Delegates


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

#pragma mark - CollectionView Delegates

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
            [NetworkActivityHelper addActivityInProgress];
            NSData * imgData = [self.dataSource getThumbnailForCollection:collectionName];
            
             if (imgData)
             {
                 [self.model setImageData: imgData forCollection: collectionName];
                 if ([colCell.text isEqualToString:collectionName])
                 {
                     colCell.img = [UIImage imageWithData:imgData];
                 }
             }
            else
            {
                colCell.img = [UIImage imageNamed:@"felt-red-ipad-background.jpg"];
            }
        }
        else
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
    else
    {
        //present the collection view
        NSString * name = [self getSelectedCollectionName];
        
        if (!name) return;
        
        CollectionViewController * collectionView = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectionView"];
        collectionView.bulletinBoardName = name;
        collectionView.parent = self;
        MindcloudCollection * board =
        [[MindcloudCollection alloc] initCollection:name withDataSource:[CachedMindCloudDataSource getInstance:name]];
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
    return UIEdgeInsetsMake(20, 20, 30, 20);
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
    self.shouldSaveCategories = YES;
}

-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < [self.model numberOfCategories])
    {
        //its the edit place holder
        NSString * selectedCellText = [self.categoriesController.table cellForRowAtIndexPath:indexPath].textLabel.text;
        //ALL and Uncategorized cateogires are uneditable
        if ([selectedCellText isEqual:ALL] ||
            [selectedCellText isEqual:UNCATEGORIZED_KEY])
        {
            return UITableViewCellEditingStyleNone;
        }
        return UITableViewCellEditingStyleDelete;
        
    }
    else if (indexPath.item ==[self.model numberOfCategories] )
        return UITableViewCellEditingStyleInsert;
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

#pragma mark - Table view delegate

//don't show filler cells
-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isInCategorizeMode)
    {
        return indexPath;
    }
    else
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.isInCategorizeMode)
    {
        NSString * categoryName = cell.textLabel.text;
        
        if ([self.currentCategory isEqualToString:categoryName]) return;
        
        if ([categoryName isEqualToString:ALL]) return;
        
        for(NSIndexPath * index in [self.collectionView indexPathsForSelectedItems])
        {
            CollectionCell * collectionCell = (CollectionCell *)[self.collectionView cellForItemAtIndexPath:index];
            NSString * collectionName = collectionCell.text;
            [self.model moveCollection:collectionName fromCategory:self.currentCategory toNewCategory:categoryName];
        }
        if (![self.currentCategory isEqual:ALL])
        {
            [self.collectionView performBatchUpdates:^{
                [self.collectionView deleteItemsAtIndexPaths:[self.collectionView indexPathsForSelectedItems]];
            }completion:^(BOOL finished){
                //give user some fraction of second to see what is happening
                [self performSelector:@selector(updateCollectionView:) withObject:categoryName afterDelay:0.35];
                [self exitCategorizeMode];
                
            }];
        }
        else
        {
            [self updateCollectionView:categoryName];
            [self exitCategorizeMode];
        }
        self.shouldSaveCategories = YES;
    }
    else
    {
        [self disableEditButtons];
        [self updateCollectionView:cell.textLabel.text];
        if (![self.currentCategory isEqualToString:ALL] &&
            ![self.currentCategory isEqualToString:UNCATEGORIZED_KEY])
        {
            self.categoriesController.renameMode = YES;
        }
    }
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

-(void) saveCategories:(NSTimer *) timer
{
    [self saveCategories];
}

-(void) saveCategories
{
    if (self.shouldSaveCategories)
    {
        NSData * categoriesData = [XoomlCategoryParser serializeToXooml:self.model];
        [self.dataSource saveCategories:categoriesData];
        self.shouldSaveCategories = NO;
    }
}
@end