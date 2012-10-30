//
//  MainScreenDropbox.m
//  IdeaStock
//
//  Created by Ali Fathalian on 4/24/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MainScreenViewController.h"
#import "BulletinBoardViewController.h"
#import "Mindcloud.h"
#import "UserPropertiesHelper.h"
#import "CollectionsModel.h"
#import "CollectionCell.h"

#define ACTION_TYPE_CREATE_FOLDER @"createFolder"
#define ACTION_TYPE_UPLOAD_FILE @"uploadFile"

@interface MainScreenViewController()

/*------------------------------------------------
 UI properties
 -------------------------------------------------*/
@property (weak, nonatomic) UIView * lastView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray * editToolbar;
@property (strong, nonatomic) NSArray * navigateToolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property BOOL isEditing;
@property (strong, nonatomic) NSString * currentCategory;
/*------------------------------------------------
 Model
 -------------------------------------------------*/
@property CollectionsModel * model;
@end

@implementation MainScreenViewController

-(NSString *) currentCategory
{
    if (!_currentCategory) _currentCategory = UNCATEGORIZED_KEY;
    return _currentCategory;
}

/*------------------------------------------------
 Initializers
 -------------------------------------------------*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*------------------------------------------------
 UI Event helpers
 -------------------------------------------------*/

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"bulletinBoardSegue"]){
        
        NSString * name = ((UILabel *)[((UIView *) sender) subviews][0]).text;
        DropBoxAssociativeBulletinBoard * board = [[DropBoxAssociativeBulletinBoard alloc] initBulletinBoardFromXoomlWithName:name];
        ((BulletinBoardViewController *) segue.destinationViewController).bulletinBoardName = name; 
        ((BulletinBoardViewController *) segue.destinationViewController).parent = self;
        ((BulletinBoardViewController *) segue.destinationViewController).board = board;
    }
}

#define DELETE_BUTTON @"Delete"
#define CANCEL_BUTTON @"Cancel"
#define RENAME_BUTTON @"Rename"
#define EDIT_BUTTON @"Edit"
/*------------------------------------------------
 UI Events
 -------------------------------------------------*/
- (IBAction)cancelPressed:(id)sender {
    self.isEditing = NO;
    self.toolbar.items = self.navigateToolbar;
    NSArray * selectedItem = [self.collectionView indexPathsForSelectedItems];
    for (NSIndexPath * selIndex in selectedItem)
    {
        [self.collectionView deselectItemAtIndexPath:selIndex animated:YES];
    }
    //make sure Delete and Rename buttons are in disabled state
    for(UIBarButtonItem * button in self.editToolbar)
    {
        if ([button.title isEqual:DELETE_BUTTON] ||
            [button.title isEqual:RENAME_BUTTON])
        {
            button.enabled = NO;
        }
    }
}
- (IBAction)editPressed:(id)sender {
    self.isEditing = YES;
    self.toolbar.items = self.editToolbar;
}

-(IBAction) AddPressed:(id)sender {
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Enter The Name of The Collection" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (IBAction)deletePressed:(id)sender {
    NSArray * selectedItems = [self.collectionView indexPathsForSelectedItems];
    CollectionCell * selectedCell = (CollectionCell *)[self.collectionView cellForItemAtIndexPath:selectedItems[0]];
    [self.collectionView performBatchUpdates:^{
        [self.model removeCollection:selectedCell.text fromCategory:self.currentCategory];
        [self.collectionView deleteItemsAtIndexPaths:selectedItems];
    }completion:nil];
}

- (IBAction)refreshPressed:(id)sender {
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1){
        NSString * name = [[alertView textFieldAtIndex:0] text];
        //TODO: do error checking here
        [self.model addCollection:name toCategory:self.currentCategory];
        [self.collectionView performBatchUpdates:^{
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        }completion:nil];
        
    }
    
}

-(void) viewWillAppear:(BOOL)animated{
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

-(void) viewDidLoad{
    
    [super viewDidLoad];
    [self.collectionView setAllowsMultipleSelection:NO];
    [self manageToolbars];
    self.toolbar.items = self.navigateToolbar;
    
    //TODO what does this do ?
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bulletinBoardsRead:)
                                                 name:@"BulletinboardsLoaded" 
                                               object:nil];
    
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    self.model = [[CollectionsModel alloc] initWithCollections:[NSArray arrayWithObject:@"Tutorial"]];
    [mindcloud getAllCollectionsFor:userId
                          WithCallback:^(NSArray * collection)
                 {
                     NSLog(@"Collections Retrieved");
                     NSLog(@"%@", collection);
                     self.model = [[CollectionsModel alloc] initWithCollections:collection];
                     [self.collectionView reloadData];
                 }];
}

-(void) manageToolbars
{
    NSMutableArray *  editbar = [NSMutableArray array];
    NSMutableArray *  navbar = [NSMutableArray array];
    for (UIBarButtonItem * barButton in self.toolbar.items)
    {
        if ([barButton.title isEqual: RENAME_BUTTON] ||
            [barButton.title isEqual: DELETE_BUTTON] ||
            [barButton.title isEqual: CANCEL_BUTTON])
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
        }
    }
    self.editToolbar = [editbar copy];
    self.navigateToolbar = [navbar copy];

}
-(void) viewDidUnload{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}

/*------------------------------------------------
 Bulletinboard Delegate Protocol
 -------------------------------------------------*/

-(void) finishedWorkingWithBulletinBoard{
    [self dismissModalViewControllerAnimated:YES];
}

/*-------------------------------------------------
 Collectionview Delegate methods
 --------------------------------------------------*/

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self.model getCollectionsForCategory:self.currentCategory] count];
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    NSString * text = [self.model getCollectionAt:indexPath.item forCategory:self.currentCategory];
    if ([cell isKindOfClass:[CollectionCell class]])
    {
        CollectionCell * colCell = (CollectionCell *)cell;
        colCell.text = text;
    }
    
    return cell;
}


-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //enable the edit bar buttons
    for (UIBarButtonItem * button in self.toolbar.items)
    {
        button.enabled = YES;
    }
    
}

-(BOOL) collectionView:(UICollectionView *) collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isEditing;
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
@end