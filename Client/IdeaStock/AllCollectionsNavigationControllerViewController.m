//
//  AllCollectionsNavigationControllerViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 9/23/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "AllCollectionsNavigationControllerViewController.h"

@interface AllCollectionsNavigationControllerViewController ()

@end

@implementation AllCollectionsNavigationControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

-(void) toggleLeftPanel
{
    if (self.parent)
    {
        ContainerViewController * temp = self.parent;
        [temp toggleSidePanel];
    }
}

-(BOOL) isLeftPanelOpen
{
    return NO;
}

-(void) disableLeftPanelToggling
{
    if (self.parent)
    {
        ContainerViewController * temp = self.parent;
        [temp disableLeftPanel];
    }
}

-(void) enableLeftPanelToggling
{
    if (self.parent)
    {
        ContainerViewController * temp = self.parent;
        [temp enableLeftPanel];
    }
}

-(CategoriesViewController *) viewControllerForCategories
{
    if (self.parent)
    {
        ContainerViewController * temp = self.parent;
        return temp.leftPanel;
    }
    return nil;
}
@end
