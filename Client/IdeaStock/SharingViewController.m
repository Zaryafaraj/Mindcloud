//
//  SharingViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/23/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "SharingViewController.h"

@interface SharingViewController()
@property (weak, nonatomic) IBOutlet UILabel *sharingLabel;
@property (weak, nonatomic) IBOutlet UITextField *SharingSecretText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
@implementation SharingViewController
-(void) sharingFinished
{
    [self.activityIndicator stopAnimating];
}
@end
