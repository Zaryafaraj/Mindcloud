//
//  ListMainPageViewController.m
//  Lists
//
//  Created by Ali Fathalian on 4/6/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ListMainPageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ThemeFactory.h"
#import "ITheme.h"
#import "ListsCollectionRowView.h"

@interface ListMainPageViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
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
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<ITheme> theme = [ThemeFactory currentTheme];
}

-(void) viewDidAppear:(BOOL)animated
{
    [self.scrollView setContentSize:CGSizeMake(10000* 10, 10000* 5)];
    [self.scrollView setContentInset:UIEdgeInsetsMake(100, 100, 100, 100)];
    CGRect frame = CGRectMake(50, 50, 300, 70);
    ListsCollectionRowView * row = [[ListsCollectionRowView alloc] initWithFrame:frame];
    row.collectionLabel.text = @"HI";
    row.collectionImage.image = [UIImage imageNamed:@"Test.png"];
    [self.scrollView addSubview:row];
}

@end
