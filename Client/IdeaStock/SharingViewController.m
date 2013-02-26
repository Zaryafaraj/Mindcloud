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
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        NSString * subject = [NSString stringWithFormat:@"Subscribe to my mindcloud: %@", self.collectionName];
        [mailer setSubject:subject];
        NSArray *toRecipients = @[];
        [mailer setToRecipients:toRecipients];
//        UIImage *myImage = [UIImage imageNamed:@"mobiletuts-logo.png"];
//        NSData *imageData = UIImagePNGRepresentation(myImage);
//        [mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"mobiletutsImage"];
        NSString *emailBody = [NSString stringWithFormat:@"I have shared a mindcloud named %@ with you.\n To subscribe, use the following secret key: %@ \n\n You can get mindcloud from :www.mindcloud.com", self.collectionName, self.SharingSecretText.text];
        [mailer setMessageBody:emailBody isHTML:NO];
        mailer.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentViewController:mailer animated:YES completion:^{}];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
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

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}
@end
