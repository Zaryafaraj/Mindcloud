//
//  ListMainPageViewController.m
//  Lists
//
//  Created by Ali Fathalian on 4/6/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ListMainPageViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ListMainPageViewController ()
@property (weak, nonatomic) IBOutlet UIView *toolbar;
@end

@implementation ListMainPageViewController

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
    [self.toolbar.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.toolbar.layer setShadowOpacity:1.0];
    self.toolbar.layer.opaque = YES;
    self.toolbar.layer.shouldRasterize = YES;
    [self.toolbar.layer setShadowRadius:3.0];
    [self.toolbar.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
@end
