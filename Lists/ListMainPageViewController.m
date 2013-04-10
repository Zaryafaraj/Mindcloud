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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}

-(void) moveRowsDown
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
            
            [AnimationHelper slideDown:row toFrame:frame];
        }
    }
    [self extendScrollViewIfNecessaryForFrame: lowestFrame];
}

-(void) extendScrollViewIfNecessaryForFrame:(CGRect) frame
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
- (IBAction)addPressed:(id)sender {
    
    
    [self moveRowsDown];
    CGRect firstFrame = [MainScreenListLayout frameForRowforIndex:0
                                                      inSuperView:self.scrollView];
    ListsCollectionRowView * row = [[ListsCollectionRowView alloc] initWithFrame:firstFrame];
    row.backgroundView.alpha = 0.5;
    row.collectionLabel.text = [NSString stringWithFormat:@"%d",self.index];
    row.collectionImage.image = [UIImage imageNamed:@"Test.png"];
    row.index = 0;
    [self.scrollView addSubview:row];
    self.index++;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated
{
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
}

@end
