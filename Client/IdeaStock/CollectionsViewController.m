//
//  CollectionsViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/1/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CollectionsViewController.h"

@interface CollectionsViewController ()

@end

@implementation CollectionsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryBoard" bundle:nil];
    self = [super initWithCenterViewController:[storyboard instantiateViewControllerWithIdentifier:@"MainScreenViewController"]
                            leftViewController:[storyboard instantiateViewControllerWithIdentifier:@"CategoriesViewController"]];
    if (self) {
        // Add any extra init code here
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
