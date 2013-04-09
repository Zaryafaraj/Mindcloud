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
#import "MainScreenListLayout.h"

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
    [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, 2 * self.view.bounds.size.height)];
    for (int i = 0 ; i <= 5; i++)
    {
        CGRect frame = [MainScreenListLayout frameForRowforIndex:i inSuperView:self.scrollView];
        ListsCollectionRowView * row = [[ListsCollectionRowView alloc] initWithFrame:frame];
        row.backgroundView.alpha = 0.5;
        row.collectionLabel.text = @"HI";
        row.collectionImage.image = [UIImage imageNamed:@"Test.png"];
        [self.scrollView addSubview:row];
    }
}

@end
