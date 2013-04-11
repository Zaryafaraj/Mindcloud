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
#import "AnimationHelper.h"

@interface ListMainPageViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property int index;
@end

@implementation ListMainPageViewController

- (IBAction)addPressed:(id)sender {
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    [self moveRowsDown];
    CGRect firstFrame = [MainScreenListLayout frameForRowforIndex:0
                                                      inSuperView:self.scrollView];
    ListsCollectionRowView * row = [[ListsCollectionRowView alloc] initWithFrame:firstFrame];
    row.collectionLabel.text = [NSString stringWithFormat:@"%d",self.index];
    row.collectionImage.image = [UIImage imageNamed:@"Test.png"];
    row.index = 0;
    [self.scrollView addSubview:row];
    self.index++;
    
}

- (void) moveRowsDown
{
    CGRect lowestFrame = CGRectMake(0, 0, 0, 0);
    for(ListsCollectionRowView * row in self.scrollView.subviews)
    {
        if ([row isKindOfClass:[ListsCollectionRowView class]])
        {
            row.index++;
            CGRect frame = [MainScreenListLayout frameForRowforIndex:row.index
                                                         inSuperView:self.scrollView];
            if (frame.origin.x > lowestFrame.origin.x)
            {
                lowestFrame = frame;
            }
            
            [AnimationHelper slideMainScreenRowDown:row toFrame:frame];
        }
    }
    [self extendScrollViewIfNecessaryForFrame: lowestFrame];
}

- (void) extendScrollViewIfNecessaryForFrame:(CGRect) frame
{
    CGSize contentSize = self.scrollView.contentSize;
    CGPoint lowerPart = [MainScreenListLayout originForFrameAfterFrame:frame];
    if (lowerPart.y > self.scrollView.bounds.size.height)
    {
        CGSize newContentSize = CGSizeMake(contentSize.width,
                                           lowerPart.y);
        self.scrollView.contentSize = newContentSize;
    }
    
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat contentOffsetY = self.scrollView.contentOffset.y;
    CGFloat contentWidth = self.scrollView.bounds.size.width;
    CGFloat contentHeight = self.scrollView.bounds.size.height;
    self.scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
    
    CGRect lowestFrame = CGRectMake(0, 0, 0, 0);
    for(ListsCollectionRowView * row in self.scrollView.subviews)
    {
        if ([row isKindOfClass:[ListsCollectionRowView class]])
        {
            CGRect frame = [MainScreenListLayout frameForRowforIndex:row.index
                                                         inSuperView:self.scrollView];
            if (frame.origin.x > lowestFrame.origin.x)
            {
                lowestFrame = frame;
            }
        }
    }
    [self extendScrollViewIfNecessaryForFrame: lowestFrame];
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, contentOffsetY);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
}

@end
