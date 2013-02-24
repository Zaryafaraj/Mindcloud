//
//  SharingViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/23/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "SharingViewController.h"
#import "EventTypes.h"

@interface SharingViewController()
@property (weak, nonatomic) IBOutlet UILabel *sharingLabel;
@property (weak, nonatomic) IBOutlet UITextField *SharingSecretText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
@implementation SharingViewController

-(void) viewWillAppear:(BOOL)animated
{
    [self.sharingLabel setHidden:YES];
    [self.SharingSecretText setHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sharingSecretReceived:)
                                                 name:COLLECTION_SHARED
                                               object:nil];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) sharingSecretReceived:(NSNotification *) notification
{
    NSDictionary * result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    if ([collectionName isEqualToString:self.collectionName])
    {
        NSString * sharingSecret = result[@"sharingSecret"];
        if (sharingSecret != nil)
        {
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];
            [self.SharingSecretText setHidden:NO];
            [self.sharingLabel setHidden:NO];
            self.sharingLabel.text = sharingSecret;
            [self.sharingLabel setEnabled:NO];
            [[NSNotificationCenter defaultCenter] postNotification:RESIZE_POPOVER_FOR_SECRET];
        }
    }
}
@end
