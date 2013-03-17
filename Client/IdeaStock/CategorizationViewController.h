//
//  CategorizationViewController.h
//  Mindcloud
//
//  Created by Ali Fathalian on 3/17/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategorizationViewDelegate.h"

@interface CategorizationViewController : UITableViewController
@property (nonatomic, strong) NSArray * categories;
@property (nonatomic, weak) id<CategorizationViewDelegate> delegate;

@property CGFloat rowHeight;

-(CGSize) getBestPopoverContentSize;

@end
