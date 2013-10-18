//
//  AllCollectionsNavigationControllerViewController.h
//  Mindcloud
//
//  Created by Ali Fathalian on 9/23/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContainerViewController.h"
#import "CategoriesViewController.h"

@interface AllCollectionsNavigationControllerViewController : UINavigationController

@property (nonatomic, weak) ContainerViewController * parent;

-(void) toggleLeftPanel;

-(BOOL) isLeftPanelOpen;

-(void) disableLeftPanelToggling;

-(void) enableLeftPanelToggling;

-(CategoriesViewController *) viewControllerForCategories;

@end
