//
//  ContainerViewController.h
//  Mindcloud
//
//  Created by Ali Fathalian on 9/23/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDrawerController.h"
#import "CategoriesViewController.h"

@interface ContainerViewController : MMDrawerController

-(void) toggleSidePanel;

@property (nonatomic, strong) CategoriesViewController * leftPanel;

@end
