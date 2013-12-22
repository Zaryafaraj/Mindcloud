//
//  PaintConfigViewController.h
//  Mindcloud
//
//  Created by Ali Fathalian on 12/19/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintConfigView.h"

@interface PaintConfigViewController : UIViewController

@property (nonatomic, strong) UIColor * currentColor;
@property (nonatomic) CGFloat currentWidth;

@property (nonatomic, weak) id<PaintConfigDelegate> delegate;

@end
