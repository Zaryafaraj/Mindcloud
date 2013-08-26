//
//  SignInViewController.m
//  IdeaStock
//
//  Created by Ali Fathalian on 10/20/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "SignInViewController.h"
#import "UserPropertiesHelper.h"
#import "MindcloudAuthenticationGordon.h"

@interface SignInViewController ()

@property (atomic, strong) MindcloudAuthenticationGordon * gordonAuthorizer;

@end

@implementation SignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)signInPressed:(id)sender
{
    //open safari with the link to dropbox signin page
    //The call back after user signs in is in the appDelegate.m class
    if ([self.gordonAuthorizer authenticationURL])
    {
        NSURL * url = [NSURL URLWithString:[self.gordonAuthorizer authenticationURL]];
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        //we are in trouble
        //kill the app ? 
        NSLog(@"Authentication params not set");
    }
}

- (void)viewDidLoad
{
    //do the authorization from background
    [super viewDidLoad];
    NSString * userID = [UserPropertiesHelper userID];
    [self.gordonAuthorizer authorizeUser:userID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) userIsAuthenticatedAndAuthorized:(NSString *) userID
{
    
    [self performSegueWithIdentifier:@"MainScreenSegue" sender:self];
}
@end
