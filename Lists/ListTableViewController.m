//
//  ListTableViewController.m
//
//
//  Created by Ali Fathalian on 4/21/13.
//
//

#import "ListTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ThemeFactory.h"
#import "ITheme.h"
#import "CenteredListTableViewLayoutManager.h"
#import "ListTableSlideAnimationManager.h"
#import "StubListTableViewDatasource.h"
#import "ScrollViewRowRecycler.h"
#import "ListRow.h"

@interface ListTableViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) ScrollViewRowRecycler * recycler;
@property UIEdgeInsets originalContentInset;
@property CGPoint originalContentOffset;
@property BOOL savedOriginalCoordinates;

@end
@implementation ListTableViewController

-(void) setPrototypeRow:(UIView<ListRow> *)prototypeRow
{
    _prototypeRow = prototypeRow;
    self.recycler.prototype = prototypeRow;
}

-(ScrollViewRowRecycler *) recycler
{
    if (_recycler == nil)
    {
        _recycler = [[ScrollViewRowRecycler alloc] init];
        _recycler.delegate = self;
    }
    if (_recycler.prototype == nil)
    {
        _recycler.prototype = self.prototypeRow;
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

-(id<ListTableViewDatasource>) dataSource
{
    if (_dataSource == nil)
    {
        _dataSource = [[StubListTableViewDatasource alloc] init];
    }
    return _dataSource;
}

-(void) addRowToTop
{
    [self.scrollView setContentOffset:CGPointZero animated:NO];
    
    NSString * title = [NSString stringWithFormat:@"%d", 0];
    [self.dataSource addItemWithTitle:title atIndex:0];
    UIView<ListRow> * row =  [self.recycler dequeRowForAdditionTo:self.scrollView atIndex:0];
    
    row.text = title;
    if ([row respondsToSelector:@selector(setImage:)])
    {
        row.image = [self.dataSource imageForItemAtIndex:0];
    }
    row.index = 0;
    CGRect frame = [self.layoutManager frameForRowforIndex:0
                                               inSuperView:self.scrollView];
    
    [self moveRowsDown];
    [self.animationManager animateAdditionForRow:row
                                         toFrame:frame
                                     inSuperView:self.scrollView
                           withCompletionHandler:^{[row enableEditing:YES];}];
    self.editingRow = row;
    self.isInEditMode = YES;
}

-(void) removeRow:(UIView<ListRow> *) row
{
    int index = row.index;
    //get the frame
    [self.animationManager animateRemovalForRow:row
                                    inSuperView:self.scrollView
                          withCompletionHandler:^{
                              [self.dataSource removeItemAtIndex:index];
                              [row removeFromSuperview];
                              [self moveRowsUpAfterIndex:index];
                              [self.recycler returnRowForRecyling:row
                                                     inScrollView:self.scrollView];
                          }];
}

- (void) moveRowsDown
{
    int lowestIndex = [self.dataSource count];
    for(UIView<ListRow> * row in self.scrollView.subviews)
    {
        if ([row conformsToProtocol:@protocol(ListRow)])
        {
            row.index++;
            CGRect frame = [self.layoutManager frameForRowforIndex:row.index
                                                       inSuperView:self.scrollView];
            row.text = [NSString stringWithFormat:@"%d",row.index];
            [self.dataSource setTitle:row.text ForItemAtIndex:row.index];
            
            [self.animationManager slideMainScreenRow:row toFrame:frame];
        }
    }
    [self adjustScrollViewForLowestIndex:lowestIndex];
}

-(void) moveRowsUpAfterIndex:(int) index
{
    int lowestIndex = [self.dataSource count];
    for(UIView<ListRow> * row in self.scrollView.subviews)
    {
        if ([row conformsToProtocol:@protocol(ListRow)])
        {
            if (row.index > index)
            {
                row.index--;
                CGRect frame = [self.layoutManager frameForRowforIndex:row.index
                                                           inSuperView:self.scrollView];
                row.text = [NSString stringWithFormat:@"%d",row.index];
                [self.dataSource setTitle:row.text ForItemAtIndex:row.index];
                
                [self.animationManager slideMainScreenRow:row toFrame:frame];
            }
        }
    }
    [self adjustScrollViewForLowestIndex:lowestIndex];
}

- (void) adjustScrollViewForLowestIndex:(int) index
{
    CGSize contentSize = self.scrollView.contentSize;
    CGRect frame = [self.layoutManager frameForRowforIndex:index
                                               inSuperView:self.scrollView];
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
    
    int lowestIndex = [self.dataSource count];
    [self adjustScrollViewForLowestIndex:lowestIndex];
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, contentOffsetY);
    [self.recycler recycleRows:self.scrollView];
}

-(void) configureScrollView
{
    
    self.scrollView.delegate = self;
    UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(scrollViewTapped:)];
    [self.scrollView addGestureRecognizer:tgr];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
}

-(void) addInitialNotifications
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAppeared:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDisappeared:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    
    [self configureScrollView];
    [self addInitialNotifications];
    
}

#pragma mark - gesture recognizer
-(void) scrollViewTapped:(UISwipeGestureRecognizer *) sender
{
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
    
    if (index >= [self.dataSource count]) return nil;
    
    prototype.text = [self.dataSource titleForItemAtIndex:index];
    prototype.image = [self.dataSource imageForItemAtIndex:index];
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

#pragma mark - keyboard notification
-(void) keyboardAppeared:(NSNotification *) notification
{
    NSDictionary * info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
    float keyboardHeight = MIN(kbSize.height, kbSize.width);
        
    CGRect aRect = self.scrollView.frame;
        
    if (self.editingRow == nil) return;
        
    CGRect editingRowFrame = self.editingRow.frame;
        //the -1 is there because we dont want the rightestCornerToNotFallInside
    
    CGFloat rowRightesCorner = MIN(editingRowFrame.origin.x + editingRowFrame.size.width,
                                         aRect.origin.x + aRect.size.width - 1);
    CGPoint rowRightCorner = CGPointMake(rowRightesCorner,
                                              editingRowFrame.origin.y + editingRowFrame.size.height);
    aRect.size.height -= keyboardHeight;
    if (!CGRectContainsPoint(aRect,rowRightCorner))
    {
        CGFloat spaceFromLowerCornerToBottom = self.scrollView.frame.size.height - rowRightCorner.y;
        CGFloat addedVisibleSpaceY = keyboardHeight - spaceFromLowerCornerToBottom;
        CGPoint scrollPoint = CGPointMake(0.0, self.scrollView.frame.origin.y + addedVisibleSpaceY);
        self.savedOriginalCoordinates = YES;
        self.originalContentInset = self.scrollView.contentInset;
        self.originalContentOffset = self.scrollView.contentOffset;
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

-(void) keyboardDisappeared:(NSNotification *) notification
{
    if (self.savedOriginalCoordinates)
    {
        [self.scrollView setContentOffset:self.originalContentOffset animated:YES];
        self.savedOriginalCoordinates = NO;
    }
}

@end
