//
//  CategoriesViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/2/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CategoriesViewController.h"

@interface CategoriesViewController ()

@end

@implementation CategoriesViewController

- (void)viewDidLoad
{
    self.table.dataSource = self.dataSource;
    self.table.delegate = self.delegate;
}

#define CREATE_BUTTON_TITILE @"Create"
- (IBAction)addPressed:(id)sender {
    [self.table setEditing:YES animated:YES];
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Enter The Name of The Category"
//                                                     message:nil
//                                                    delegate:self
//                                           cancelButtonTitle:@"Cancel"
//                                           otherButtonTitles:CREATE_BUTTON_TITILE, nil];
//    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [alert show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //perform add collection
    if (buttonIndex == 1)
    {
        if ([[alertView buttonTitleAtIndex:buttonIndex]
             isEqualToString:CREATE_BUTTON_TITILE])
        {
            NSString * name = [[alertView textFieldAtIndex:0] text];
        }
    }
}
@end
