//
//  CollectionsViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/1/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CollectionsViewController.h"
#import "MainScreenViewController.h"
#import "CategoriesViewController.h"

@interface CollectionsViewController ()

@end

@implementation CollectionsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryBoard" bundle:nil];
        MainScreenViewController * mainScreen = [storyboard instantiateViewControllerWithIdentifier:@"MainScreenViewController"];
        CategoriesViewController * categoriesScreen = [storyboard instantiateViewControllerWithIdentifier:@"CategoriesViewController"];
        categoriesScreen.tableView.dataSource = mainScreen;
        categoriesScreen.tableView.delegate = mainScreen;
        self = [super initWithCenterViewController: mainScreen
                                leftViewController: categoriesScreen];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            CGFloat screenHeight = screenRect.size.height;
            self.leftLedge = 2 * screenHeight / 3 ;
        }
        else
        {
            CGFloat screenWidth = screenRect.size.width;
            self.leftLedge = 1.75 * screenWidth / 3 ;
        }
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
