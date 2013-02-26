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
@property (weak, nonatomic) IBOutlet UIButton *textCopyButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@end
@implementation SharingViewController

-(void) viewWillAppear:(BOOL)animated
{
    [self.sharingLabel setHidden:YES];
    [self.SharingSecretText setHidden:YES];
    [self.emailButton setHidden:YES];
    [self.textCopyButton setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sharingSecretReceived:)
                                                 name:COLLECTION_SHARED
                                               object:nil];
}

- (IBAction)textCopyPressed:(id)sender {
    NSString *copyString = [[NSString alloc] initWithFormat:@"%@",
                            self.SharingSecretText.text];
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:copyString];
}

- (IBAction)emailPressed:(id)sender {
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
        [self.activityIndicator stopAnimating];
        [self.activityIndicator setHidden:YES];
        NSString * sharingSecret = result[@"sharingSecret"];
        [self.sharingLabel setHidden:NO];
        if (sharingSecret != nil)
        {
            [self.SharingSecretText setHidden:NO];
            self.SharingSecretText.text = sharingSecret;
            self.SharingSecretText.enabled = NO;
            [self.emailButton setHidden:NO];
            [self.textCopyButton setHidden:NO];
        }
        else
        {
            self.sharingLabel.text = @"There was a problem with sharing the collection. Try again later";
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RESIZE_POPOVER_FOR_SECRET object:self];
    }
}


@end
