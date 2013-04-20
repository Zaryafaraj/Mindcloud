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
#import "MainScreenRow.h"
#import "CenteredListTableViewLayoutManager.h"
#import "ListTableSlideAnimationManager.h"
#import "ScrollViewRowRecycler.h"
#import "ListRow.h"

@interface ListMainPageViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property int index;
@property (strong, nonatomic) ScrollViewRowRecycler * recycler;

@end

@implementation ListMainPageViewController

-(ScrollViewRowRecycler *) recycler
{
    if (_recycler == nil)
    {
        _recycler = [[ScrollViewRowRecycler alloc] init];
        _recycler.delegate = self;
        _recycler.prototype = [[MainScreenRow alloc] init];
    }
    return _recycler;
}

-(id<ListTableViewLayoutManager>) layoutManager
{
    if (_layoutManager == nil)
    {
        _layoutManager = [[CenteredListTableViewLayoutManager alloc] init];
    }
    return _layoutManager;
}

-(id<ListTableAnimationManager>) animationManager
{
    if (_animationManager == nil)
    {
        _animationManager = [[ListTableSlideAnimationManager alloc] init];
    }
    return _animationManager;
}

- (IBAction)addPressed:(id)sender
{
    [self addRowToTop];
}


-(void) addRowToTop
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    [self moveRowsDown];
    self.index++;
    [self.recycler recycleRows:self.scrollView];
}

-(void) removeRowFromIndex:(int)index
{
    
}

- (void) moveRowsDown
{
    CGRect lowestFrame = CGRectMake(0, 0, 0, 0);
    for(UIView<ListRow> * row in self.scrollView.subviews)
    {
        if ([row conformsToProtocol:@protocol(ListRow)])
        {
            row.index++;
            CGRect frame = [self.layoutManager frameForRowforIndex:row.index
                                                       inSuperView:self.scrollView];
            row.text = [NSString stringWithFormat:@"%d",row.index];
            if (frame.origin.x > lowestFrame.origin.x)
            {
                lowestFrame = frame;
            }
            
            [self.animationManager slideMainScreenRowDown:row toFrame:frame];
        }
    }
    [self extendScrollViewIfNecessaryForFrame: lowestFrame];
}

- (void) extendScrollViewIfNecessaryForFrame:(CGRect) frame
{
    CGSize contentSize = self.scrollView.contentSize;
    CGPoint lowerPart = [self.layoutManager originForFrameAfterFrame:frame];
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
    for(id<ListRow> row in self.scrollView.subviews)
    {
        if ([row conformsToProtocol:@protocol(ListRow)])
        {
            CGRect frame = [self.layoutManager frameForRowforIndex:row.index
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

- (void) viewDidAppear:(BOOL)animated
{
    self.scrollView.delegate = self;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
}

#pragma mark - scroll view delegate
-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.recycler recycleRows:self.scrollView];
}

#pragma mark - recycler delegate
-(UIView<ListRow> *)rowForIndex:(int)index
                  withPrototype:(UIView<ListRow> *)prototype
{
    
    if (index >= self.index) return nil;
    
    prototype.text = [NSString stringWithFormat:@"%d",prototype.index];
    prototype.image = [UIImage imageNamed:@"Test.png"];
    prototype.frame = [self.layoutManager frameForRowforIndex:index
                                                  inSuperView:self.scrollView];
    return prototype;
}

- (int) lowestIndexInView
{
    return [self.layoutManager lowestRowIndexInFrame:self.scrollView.bounds];
}

- (int) highestIndexInView
{
    return [self.layoutManager highestRowIndexInFrame:self.scrollView.bounds];
}

@end
