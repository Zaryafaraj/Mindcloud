//
//  AllCollectionsNavigationControllerViewController.h
//  Mindcloud
//
//  Created by Ali Fathalian on 9/23/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContainerViewController.h"

@interface AllCollectionsNavigationControllerViewController : UINavigationController

@property (nonatomic, weak) ContainerViewController * parent;

-(void) toggleLeftPanel;

-(BOOL) isLeftPanelOpen;

@end
