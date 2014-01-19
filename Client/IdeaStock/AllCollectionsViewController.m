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
#import "NetworkActivityHelper.h"
#import "UIEventTypes.h"
#import "SharingViewController.h"
#import "CategorizationViewController.h"
#import "NamingHelper.h"
#import "AllCollectionsNavigationControllerViewController.h"
#import "ThemeFactory.h"
#import "MindcloudAuthenticator.h"
#import "EventTypes.h"
#import "IntroScreenViewController.h"

@interface AllCollectionsViewController()

@property (strong, nonatomic) MindcloudAuthenticator * authenticator;

@property (weak, nonatomic) UIView * lastView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

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
@property (nonatomic, assign) BOOL isEditing;
@property (strong, nonatomic) NSString * currentCategory;
@property (weak, nonatomic) UIActionSheet * activeSheet;
@property BOOL didCategoriesPresentAlertView;
@property BOOL isInSharingMode;

@property (nonatomic, assign) BOOL isNewCollection;

@property MindcloudAllCollections * model;

@property (nonatomic, strong) NSString * workingCollectionName;
@property (nonatomic, strong) UITapGestureRecognizer * tgr;

@property (nonatomic, strong) CollectionCell * selectedCell;

@end

@implementation AllCollectionsViewController

@synthesize currentCategory = _currentCategory;

//TODO the spaces are used as a hack to create spacing in the UI
//between the buttons. If we find a better way to do it we should remove this ugly hack
#define DELETE_BUTTON @"Delete  "
#define CANCEL_BUTTON @"Done"
#define RENAME_BUTTON @"Rename  "
#define EDIT_BUTTON @"Edit"
#define CATEGORIZE_BUTTON @"  Categorize  "
#define SHARE_BUTTON @"Share  "
#define UNSHARE_BUTTON @"Unshare  "
#define SUBSCRIBE_BUTTON @"Subscribe"
#define SHARING_MODE_BUTTON @"Sharing"
#define UNSHARE_ACTION @"Unshare Collection"
#define DELETE_ACTION @"Delete Collection"
#define SUBSCRIBE_BUTTON_TITLE @"Subscribe  "
#define RENAME_BUTTON_TITLE @"Rename  "
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

-(void) setIsEditing:(BOOL)isEditing
{
    _isEditing = isEditing;
}

#pragma mark - UI events

-(void) disableShareButtons
{
    self.shareButton.enabled = NO;
    self.unshareButton.enabled = NO;
}

-(NSString *) addCollection: (NSString *) name
{
    
    NSSet * allNames = [self.model getAllCollectionNames];
    name = [NamingHelper validateCollectionName:name amongAllNames:allNames];
    
    [self.model addCollection:name toCategory:self.currentCategory];
    if ([self.currentCategory isEqualToString:SHARED_COLLECTIONS_KEY])
    {
        [self updateCollectionView:ALL];
    }
    else
    {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        
    }
    
    return name;
}

-(void) renameSelectedCollectionsToNewName:(NSString *) newName
{
    
    NSArray * selectedItems = [self.collectionView indexPathsForSelectedItems];
    for(NSIndexPath * selectedItem in selectedItems)
    {
        CollectionCell * selectedCell = (CollectionCell *)[self.collectionView cellForItemAtIndexPath:selectedItem];
        NSString * currentName = selectedCell.text;
        
        if ([newName isEqualToString:currentName]) continue;
        
        [self renameCollectionAtCell:selectedCell
                           toNewName:newName];
        
    }
}
-(void) renameCollectionAtCell: (CollectionCell *) oldCell
                     toNewName:(NSString *) newName
{
    
    NSSet * allNames = [self.model getAllCollectionNames];
    NSString * actualNewName = [NamingHelper validateCollectionName:newName amongAllNames:allNames];
    
    [self.model renameCollection:oldCell.text
                      inCategory:self.currentCategory
                 toNewCollection:actualNewName];
    
    oldCell.text = actualNewName;
}

-(void) renameCollectionCell: (CollectionCell *) cell
                 WithOldName:(NSString *) oldName
                   toNewName:(NSString *) newName
{
    NSSet * allNames = [self.model getAllCollectionNames];
    NSString * actualNewName = [NamingHelper validateCollectionName:newName amongAllNames:allNames];
    
    [self.model renameCollection:oldName
                      inCategory:self.currentCategory
                 toNewCollection:actualNewName];
    
    if (![cell.text isEqualToString:actualNewName])
    {
        cell.text = actualNewName;
    }
}
-(void) deleteCollection:(CollectionCell *) cell
{
    NSString * collectionName = cell.text;
    [self.model batchRemoveCollections:@[collectionName] fromCategory:self.currentCategory];
    
    [self.collectionView performBatchUpdates:^{
        NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
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
    [self.categoriesController exitEditMode];
}

-(void) dismissPopOver
{
    if (self.lastPopOver != nil){
        [self.lastPopOver dismissPopoverAnimated:NO];
        self.lastPopOver = nil;
    }
}

-(void) swithToCategory:(NSString *) newCategoryName
{
    [self updateCollectionView:newCategoryName];
    self.currentCategory = newCategoryName;
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
    NSArray * selectedItem = [self.collectionView indexPathsForSelectedItems];
    for (NSIndexPath * selIndex in selectedItem)
    {
        [self.collectionView deselectItemAtIndexPath:selIndex animated:YES];
    }
    //make sure Delete and Rename buttons are in disabled state
    [self disableShareButtons];
    
    [self dismissPopOver];
    [self.activeSheet dismissWithClickedButtonIndex:-1 animated:YES];
}

- (IBAction)editPressed:(id)sender {
    
    
}

-(void) enterEditMode
{
    self.isEditing = YES;
    self.tgr.cancelsTouchesInView = YES;
    self.collectionView.allowsSelection = NO;
    [self makeEveryThingSmaller];
}

-(void) exitEditMode
{
    
    [self makeEveryThingBigger];
    [self resignAllResponders];
    double delayInSeconds = 0.2;
    
    //the reason that we run this code after a delay is that, when a touch ends two gesture recognizers recognize it simultanously.
    //The first one that it recognizes it is the super view which is the one who runs this block
    //now if we didn't have the delay it would set isEditing to NO and the second gesture recognizers
    //which is for the cell (probably a tap on cell) would say oh you are not editing then i can
    //select. The end cause of this would be the ability to select a cell and go the collection
    //while still in edit mode
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.collectionView.allowsSelection = YES;
        self.isEditing = NO;
        self.tgr.cancelsTouchesInView = NO;
    });
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

-(NSString *) generateNameForUntitledCollection
{
    NSDate * date = [NSDate date];
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    NSString * dateString = [dateFormat stringFromDate:date];
    dateString = [dateString stringByReplacingOccurrencesOfString:@":" withString:@"."];
    return [NSString stringWithFormat:@"Ideas for %@", dateString];
}

-(IBAction) addPressed
{
    
    [self dismissPopOver];
    [self deselectAll];
    NSString * name = [self generateNameForUntitledCollection];
    name = [self addCollection:name];
    
    self.workingCollectionName = name;
    [self disableTogglingLeftPanel];
    self.isNewCollection = YES;
    [self performSegueWithIdentifier:@"CollectionViewSegue" sender:self];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //perform add collection
    if (buttonIndex == 1)
    {
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
                      isEqualToString:RENAME_BUTTON_TITLE])
            {
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
    for (NSIndexPath * index in self.collectionView.indexPathsForVisibleItems)
    {
        [self.collectionView deselectItemAtIndexPath:index animated:YES];
    }
}

-(void) makeEveryThingSmaller
{
    
    for (NSIndexPath * index in self.collectionView.indexPathsForVisibleItems)
    {
        UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:index];
        if ([cell isKindOfClass:[CollectionCell class]])
        {
            CollectionCell * colCell = (CollectionCell *) cell;
            [colCell shrink:YES];
        }
    }
}

-(void) makeEveryThingBigger
{
    
    for (NSIndexPath * index in self.collectionView.indexPathsForVisibleItems)
    {
        UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:index];
        if ([cell isKindOfClass:[CollectionCell class]])
        {
            CollectionCell * colCell = (CollectionCell *) cell;
            [colCell unshrink:YES];
        }
    }
    
}

- (IBAction)refreshPressed:(id)sender {
    
    [self dismissPopOver];
    [self.model refresh];
}

- (void)showCategoriesPressed:(id)sender {
    
    if ([self.navigationController isKindOfClass:[AllCollectionsNavigationControllerViewController class]])
    {
        AllCollectionsNavigationControllerViewController * parent = (AllCollectionsNavigationControllerViewController *) self.navigationController;
        [parent toggleLeftPanel];
    }
}

-(void) disableTogglingLeftPanel
{
    
    if ([self.navigationController isKindOfClass:[AllCollectionsNavigationControllerViewController class]])
    {
        AllCollectionsNavigationControllerViewController * parent = (AllCollectionsNavigationControllerViewController *) self.navigationController;
        [parent disableLeftPanelToggling];
    }
}

-(void) enableTogglingLeftPanel
{
    
    if ([self.navigationController isKindOfClass:[AllCollectionsNavigationControllerViewController class]])
    {
        AllCollectionsNavigationControllerViewController * parent = (AllCollectionsNavigationControllerViewController *) self.navigationController;
        [parent enableLeftPanelToggling];
    }
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userIsOffline:)
                                                 name:USER_OFFLINE
                                               object:nil];
    
    
    
}

-(void) userIsOffline:(NSNotification *) notification
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Could Not Connect To Mindcloud"
                                                     message:@"Please check your internet connection.\n You can still use mindcloud when you are offline and your changes will be saved the next time you are online."
                                                    delegate:Nil
                                           cancelButtonTitle:@"ok"
                                           otherButtonTitles: nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

-(void) configureNavigationBar
{
    
    //left button
    UIImage * showPanelImg = [UIImage imageNamed:@"ButtonMenu"];
    UIBarButtonItem * showPanel = [[UIBarButtonItem alloc] initWithImage:showPanelImg
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(showCategoriesPressed:)];
    showPanel.tintColor = [[ThemeFactory currentTheme] navigationBarButtonItemColor];
    self.navigationItem.leftBarButtonItem = showPanel;
    
    
    UIBarButtonItem * edit = self.editButtonItem;
    edit.tintColor = [[ThemeFactory currentTheme] navigationBarButtonItemColor];
    //right buttons
    UIBarButtonItem * fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                  target:self
                                                  action:nil];
    fixedSpace.width = 10;
    self.navigationItem.rightBarButtonItems = @[edit, fixedSpace, self.SubscribeButton];
    
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if(self.isEditing)
    {
        self.isEditing = NO;
        [self exitEditMode];
    }
    else
    {
        self.isEditing = YES;
        [self enterEditMode];
    }
}
#define SKIP_BUTTON_TITLE @"Continue without an account"
#define LOGIN_BUTTON_TITLE @"Login with Dropbox"

-(void) showIntroIfNeccessary
{
    if (![UserPropertiesHelper hasUserBeenRegesitered])
    {
        self.authenticator = [[MindcloudAuthenticator alloc] init];
        self.authenticator.delegate = self;
        [self.authenticator authorizeUser];
        IntroScreenViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroScreenVC"];
        vc.delegate = self;
        [self presentViewController:vc animated:NO
                         completion:^(void){}];
    }
}

-(void) addGestureRecognizers
{
    UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)];
    tgr.delegate = self;
    tgr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tgr];
    self.tgr = tgr;
}

-(void) resignAllResponders{
    for(NSIndexPath * indx in [self.collectionView indexPathsForVisibleItems])
    {
        UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:indx];
        [cell resignFirstResponder];
    }
}
-(void) screenTapped:(UITapGestureRecognizer *) gr
{
    if (gr.state == UIGestureRecognizerStateEnded)
    {

        
//        [self resignAllResponders];
        if (self.isEditing)
        {
            [self setEditing:NO animated:YES];
        }
    }
}

//-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    if (self.isEditing)
//    {
//        return NO;
//    }
//    else
//    {
//        return YES;
//    }
//}

-(void) viewDidLoad{
    
    [super viewDidLoad];
    [self showIntroIfNeccessary];
    [self.collectionView setAllowsMultipleSelection:NO];
    self.isEditing = NO;
    self.isInSharingMode = NO;
    self.toolbar.hidden = YES;
    
    self.view.backgroundColor = [[ThemeFactory currentTheme] noisePatternForCollection];
    [self configureCategoriesPanel];
    [self addGestureRecognizers];
    [self configureNavigationBar];
    [self addInitialListeners];
    
    self.model = [[MindcloudAllCollections alloc] initWithDelegate:self];
    
    [self.categoriesController.table reloadData];
    //to synchronize the categories with reality
    [self.collectionView reloadData];
}

-(void) configureCategoriesPanel
{
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                       forBarMetrics:UIBarMetricsDefault];
    
    //this is not a good design. This view controller going all the way up the hierarchy to get categories controller. They should be uncoupled.
    if ([self.navigationController isKindOfClass:[AllCollectionsNavigationControllerViewController class]])
    {
        AllCollectionsNavigationControllerViewController * parent = (AllCollectionsNavigationControllerViewController *) self.navigationController;
        self.categoriesController = [parent viewControllerForCategories];
        self.categoriesController.dataSource = self;
        self.categoriesController.delegate = self;
        [self.categoriesController.table reloadData];
    }
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
    if (self.presentedViewController &&
        [self.presentedViewController isKindOfClass:[CollectionViewController class]])
    {
        
        CollectionViewController * controller = (CollectionViewController *) self.presentedViewController;
        [controller applicationHasGoneInBackground:notification];
    }
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

#pragma mark - thumbnail delegates
-(void) thumbnailCreatedForCollectionName:(NSString *) collectionName
                                 withData:(NSData *) imgData
{
    NSIndexPath * cellIndex  = [self getIndexPathForCollectionIfVisible:collectionName];
    CollectionCell * updatedItem = (CollectionCell * )[self.collectionView cellForItemAtIndexPath:cellIndex];
    if (imgData)
    {
        [self.model setImageData:imgData forCollection:collectionName];
        updatedItem.img = [UIImage imageWithData:imgData];
    }
}
#pragma mark - CollectionViewController Delegates

-(void) finishedWorkingWithCollection:(NSString *)collectionName
{
    
    NSIndexPath * cellIndex  = [self getIndexPathForCollectionIfVisible:collectionName];
    [self.collectionView deselectItemAtIndexPath:cellIndex animated:NO];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    [self enableTogglingLeftPanel];
    self.workingCollectionName = nil;
}

-(void) renamedCollectionWithName:(NSString *) collectionName
              toNewCollectionName:(NSString *) newName
{
    NSIndexPath * ip = [self getIndexPathForCollectionIfVisible:collectionName];
    [self.collectionView selectItemAtIndexPath:ip
                                      animated:NO
                                scrollPosition:UICollectionViewScrollPositionNone];
    [self renameSelectedCollectionsToNewName:newName];
    [self deselectAll];
}

#pragma mark - UICollectionView Delegates

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.model numberOfCollectionsInCategory:self.currentCategory] + 1;
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    for(UIGestureRecognizer * gr in cell.gestureRecognizers)
    {
        [self.tgr requireGestureRecognizerToFail:gr];
    }
    if ([cell isKindOfClass:[CollectionCell class]])
    {
        CollectionCell * colCell = (CollectionCell *)cell;
        [colCell reset];
        colCell.isInSelectMode = NO;
        if (self.isEditing)
        {
            [colCell shrink:NO];
        }
        else
        {
            [colCell unshrink:NO];
        }
        
        if (indexPath.item == 0)
        {
            colCell.placeholderForAdd = YES;
            colCell.text = @"New";
        }
        else
        {
            
            NSString * collectionName = [self.model getCollectionAt:indexPath.item  - 1
                                                        forCategory:self.currentCategory];
            colCell.placeholderForAdd = NO;
            colCell.text = collectionName;
            colCell.delegate = self;
            //we lazily load images and make sure we cache them
            //so any time that a cell is asked for we retrieve and cache the imag
            NSData * previewImageData = [self.model getImageDataForCollection: collectionName];
            
            
            if (previewImageData == nil)
            {
                colCell.img = nil;
            }
            else if ([colCell.text isEqualToString:collectionName])
            {
                
                colCell.img = [UIImage imageWithData:previewImageData];
            }
        }
    }
    
    return cell;
}

-(BOOL) collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
-(BOOL) collectionView:(UICollectionView *) collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing)
    {
        [self exitEditMode];
        return NO;
    }
    else
    {
        return YES;
    }
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0)
    {
        [self addPressed];
        return;
    }
    
    //enable the edit bar buttons
    if (self.isEditing)
    {
        for (UIBarButtonItem * button in self.navigationItem.rightBarButtonItems)
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
        
        NSString * name = [self getSelectedCollectionName];
        
        self.workingCollectionName = name;
        
        if (!name) return;
        
        self.workingCollectionName = name;
        [self disableTogglingLeftPanel];
        self.isNewCollection = NO;
        [self performSegueWithIdentifier:@"CollectionViewSegue" sender:self];
    }
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CollectionViewSegue"])
    {
        NSString * name = nil;
        if ([sender isKindOfClass:[self class]])
        {
            name = ((AllCollectionsViewController *) sender).workingCollectionName;
        }
        
        if (name == nil)
        {
            name = [self getSelectedCollectionName];
        }
    
        
        if (name == nil) return;
        
        CollectionViewController * dest = [segue destinationViewController];
        //present the collection view
        if (self.isNewCollection)
        {
            dest.isNewCollection = YES;
        }
        
        dest.bulletinBoardName = name;
        dest.parent = self;
        MindcloudCollection * board = [[MindcloudCollection alloc] initCollection:name];
        dest.board = board;
        
    }
}

-(CGSize) collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(355, 269);
}

-(UIEdgeInsets) collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10,0, 10);
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
    return [self.model numberOfCategories] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [[ThemeFactory currentTheme] colorForContainerBackground];
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
    if ([actionName isEqualToString:UNSHARE_ACTION])
    {
        CollectionCell * selectedCell = self.selectedCell;
        self.selectedCell = nil;
        NSString * collectionName = selectedCell.text;
        if (collectionName != nil)
        {
            [self.model unshareCollection:collectionName];
            
        }
        NSArray * selectedItems = [self.collectionView indexPathsForSelectedItems];
        for (NSIndexPath * index in selectedItems)
        {
            [self.collectionView deselectItemAtIndexPath:index animated:YES];
        }
        
        if ([self.currentCategory isEqualToString:SHARED_COLLECTIONS_KEY])
        {
            [self.collectionView deleteItemsAtIndexPaths:selectedItems];
        }
        self.unshareButton.enabled = NO;
        self.shareButton.enabled = NO;
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
    self.isInSharingMode = NO;
    
}

#pragma mark - Categorization delegate

/*! Following rules apply: 
    1- You can't move any collection to ALL category
    2- You can't move any collection to SHARED category by the act of categorization
        Moving stuff in and out of the SHARED category is done by the action of 
        Sharing/subscribing
    3- A collection can have only one category. Except ALL Category and SHARED category. 
        In addition to their original category (UNCATEGORIZED, ...) all
        the collections belong to the ALL category -> Not enforced in this class
        In addition to their original category (UNCATEGORIZED, ...) any collection 
        that is shared belongs to the SHARED category
    4- You can't move a collection between SHARED category and UNCATEGORIZED. 
        You can move the the collection however to any other category
 */
-(void) categorizationHappenedForCategory:(NSString *) categoryName
{
    [self dismissPopOver];
    
    if ([self.currentCategory isEqualToString:categoryName]) return;
    
    //RULE 1 & 2
    if ([categoryName isEqualToString:ALL]
        || [categoryName isEqualToString:SHARED_COLLECTIONS_KEY] )
    {
        return;
    }
    
    
    //Rule 4
    if ([self.currentCategory isEqualToString:SHARED_COLLECTIONS_KEY] &&
        [categoryName isEqualToString:UNCATEGORIZED_KEY])
    {
        return;
    }
    
    [self.model moveCollections:@[self.selectedCell.text]
                fromCategory:self.currentCategory
                  toNewCategory:categoryName];
    
    if (![self.currentCategory isEqualToString:ALL] &&
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
        [self swithToCategory:categoryName];
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
    
    //only if we were in the uncategorized switch to shared
    if ([self.currentCategory isEqualToString:UNCATEGORIZED_KEY])
    {
        [self swithToCategory:SHARED_COLLECTIONS_KEY];
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

#pragma mark IntroScreen Delagte

- (void)introScreenFinished:(BOOL)skipped
{
    if (skipped)
    {
        //set a flag somewhere
    }
    [self.presentedViewController dismissViewControllerAnimated:NO
                                                     completion:^{}];
    
}

- (void) signInPressed
{
    [self.authenticator authenticateUser];
}


#pragma mark MindcloudAuthenticatorDelegate
-(void) userFinishedAuthenticating:(BOOL)success
{
    [self introScreenFinished:success];
}

#pragma mark CollectionCellDelegate
-(void) cellLongPressed:(UICollectionViewCell *)cell
{
    
//    if ([cell isKindOfClass:[CollectionCell class]])
//    {
//        CollectionCell * colCell = (CollectionCell *) cell;
//        [colCell setIsInSelectMode:YES animated:YES];
//    }
    if (!self.isEditing)
    {
        [self enterEditMode];
        self.isEditing = YES;
    }
    [self deselectAll];
}

-(void) deletePressed:(UICollectionViewCell *) cell
{
    [self dismissPopOver];
    //make sure an actionsheet is not presented on top of another not dismissed one
    if ([cell isKindOfClass:[CollectionCell class]])
    {
        CollectionCell * colCell = (CollectionCell *) cell;
        
        [self deleteCollection:colCell];
        //make sure after deletion DELETE and RENAME buttons are disabled
        self.isInSharingMode = NO;
        
    }
}

-(void) sharePressed:(UICollectionViewCell *) cell fromButton:(UIButton *)button
{
    
    
    [self.activeSheet dismissWithClickedButtonIndex:-1 animated:NO];
    
    NSString * collectionName = nil;
    if ([cell isKindOfClass:[CollectionCell class]])
    {
        CollectionCell * colCell = (CollectionCell *) cell;
        collectionName = colCell.text;
    }
    
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
    [popover presentPopoverFromRect:button.frame
                             inView:button.superview
           permittedArrowDirections:UIPopoverArrowDirectionAny
                           animated:YES];
    
    [self.model shareCollection:collectionName];
    
}

-(void) categorizedPressed:(UICollectionViewCell *) cell fromButton:(UIButton *)button
{
    
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
    
    self.selectedCell = (CollectionCell *)cell;
    [popover presentPopoverFromRect:button.frame
                             inView:button.superview
           permittedArrowDirections:UIPopoverArrowDirectionAny
                           animated:YES];
}

-(void) renamePressed:(UICollectionViewCell *) cell
          fromOldName:(NSString *)oldName
{
    
    [self dismissPopOver];
    
    
    if ([cell isKindOfClass:[CollectionCell class]])
    {
        CollectionCell * colCell = (CollectionCell *) cell;
        NSString * newName = colCell.text;
        [self renameCollectionCell:colCell
                       WithOldName:oldName
                         toNewName:newName];
        [self deselectAll];
    }
}

- (void)unsharePressed:(UICollectionViewCell *) cell
                fromButton:(UIButton *) button
{
    
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
    self.selectedCell = (CollectionCell*) cell;
    [action showFromRect:button.frame
                  inView:button.superview
                animated:YES];
    self.activeSheet = action;
    
}
-(void) becameFirstResponder:(UICollectionViewCell *)cell
{
    if (!self.isEditing)
    {
        [self enterEditMode];
    }
}
@end