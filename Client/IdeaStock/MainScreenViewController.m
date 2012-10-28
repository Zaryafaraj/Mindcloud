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

#define ACTION_TYPE_CREATE_FOLDER @"createFolder"
#define ACTION_TYPE_UPLOAD_FILE @"uploadFile"

@interface MainScreenViewController()

/*------------------------------------------------
 UI properties
 -------------------------------------------------*/
@property (weak, nonatomic) IBOutlet UIScrollView *mainView;
@property (weak, nonatomic) UIView * lastView;

/*------------------------------------------------
 Model
 -------------------------------------------------*/

@end

@implementation MainScreenViewController
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

/*------------------------------------------------
 UI Events
 -------------------------------------------------*/

-(IBAction) AddPressed:(id)sender {
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Enter The Name of The Collection" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (IBAction)refreshPressed:(id)sender {
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1){
        NSString * name = [[alertView textFieldAtIndex:0] text];
        //create new view
    }
    
}

-(void) viewWillAppear:(BOOL)animated{
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    [self.mainView setBackgroundColor: [UIColor clearColor]];
    [self.mainView setContentSize:self.mainView.bounds.size];
    
    //TODO what does this do ?
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bulletinBoardsRead:)
                                                 name:@"BulletinboardsLoaded" 
                                               object:nil];
    
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    [mindcloud getAllCollectionsFor:userId
                          WithCallback:^(NSArray * collection)
                 {
                     NSLog(@"Collections Retrieved");
                 }];
}

-(void) viewDidUnload{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setMainView:nil];
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

@end