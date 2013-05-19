//
//  ListTableViewController.m
//
//
//  Created by Ali Fathalian on 4/21/13.
//
//

#import "ListsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ThemeFactory.h"
#import "ThemeProtocol.h"
#import "CenteredTableLayoutManager.h"
#import "PaperTableAnimator.h"
#import "StubListTableViewDatasource.h"
#import "ScrollViewRowRecycler.h"
#import "ListRowProtocol.h"

@interface ListsViewController ()

@property (strong, nonatomic) ScrollViewRowRecycler * recycler;
@property UIEdgeInsets originalContentInset;
@property CGPoint originalContentOffset;
@property BOOL savedOriginalCoordinates;

@end
@implementation ListsViewController

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.layoutManager = [[CenteredTableLayoutManager alloc] init];
        self.animationManager = [[PaperTableAnimator alloc] init];
        self.dataSource = [[StubListTableViewDatasource alloc] init];
    }
    return self;
}

-(void) setPrototypeRow:(UIView<ListRowProtocol> *)prototypeRow
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

-(UIView<ListRowProtocol> *) addRowToTop
{
    [self.scrollView setContentOffset:CGPointZero animated:NO];
    
    NSString * title = [NSString stringWithFormat:@"%d", 0];
    ListItem * item = [[ListItem alloc] initWithName:title andIndex:0];
    [self.dataSource addItem:item atIndex:0];
    UIView<ListRowProtocol> * row =  [self.recycler dequeRowForAdditionTo:self.scrollView atIndex:0];
    
    row.text = title;
    if ([row respondsToSelector:@selector(setImage:)])
    {
        row.image = [self.dataSource imageForItemAtIndex:0];
    }
    row.index = 0;
    CGRect frame = [self.layoutManager frameForRowforIndex:0
                                               inSuperView:self.scrollView];
    
    [self moveRowsDownAfterIndex:-1];
    [self.animationManager animateAdditionForRow:row
                                         toFrame:frame
                                     inSuperView:self.scrollView
                           withCompletionHandler:^{[row enableEditing:YES];}];
    self.editingRow = row;
    self.isInEditMode = YES;
    return row;
}

-(void) removeRow:(UIView<ListRowProtocol> *) row
{
    int index = row.index;
    //get the frame
    [self.animationManager animateRemovalForRow:row
                                    inSuperView:self.scrollView
                          withCompletionHandler:^{
                              [row removeFromSuperview];
                              [self.dataSource removeItemAtIndex:index];
                              [self.recycler returnRowForRecyling:row
                                                     inScrollView:self.scrollView];
                          }];
    [self moveRowsUpAfterIndex:index];
}

- (void) moveRowsDownAfterIndex:(int) index
{
    int lowestIndex = [self.dataSource count];
    for(UIView<ListRowProtocol> * row in self.scrollView.subviews)
    {
        if ([row conformsToProtocol:@protocol(ListRowProtocol)])
        {
            if (row.index <= index) continue;
            
            row.index++;
            CGRect frame = [self.layoutManager frameForRowforIndex:row.index
                                                       inSuperView:self.scrollView];
            row.text = [NSString stringWithFormat:@"%d",row.index];
            [self.dataSource setTitle:row.text ForItemAtIndex:row.index];
            
            [self.animationManager slideMainScreenRow:row toFrame:frame fast:YES];
            if (row.contextualMenu != nil)
            {
                CGRect contextualMenuFrame = [self.layoutManager frameForContextualMenuInRow:row];
                [self.animationManager slideContextualMenu:row.contextualMenu
                                                   toFrame:contextualMenuFrame
                                                      fast:YES];
                
            }
        }
    }
    [self adjustScrollViewForLowestIndex:lowestIndex];
}

-(void) moveRowsUpAfterIndex:(int) index
{
    int lowestIndex = [self.dataSource count];
    for(UIView<ListRowProtocol> * row in self.scrollView.subviews)
    {
        if ([row conformsToProtocol:@protocol(ListRowProtocol)])
        {
            if (row.index > index)
            {
                row.index--;
                CGRect frame = [self.layoutManager frameForRowforIndex:row.index
                                                           inSuperView:self.scrollView];
                row.text = [NSString stringWithFormat:@"%d",row.index];
                [self.dataSource setTitle:row.text ForItemAtIndex:row.index];
                
                [self.animationManager slideMainScreenRow:row toFrame:frame fast:NO];
                
                if (row.contextualMenu !=nil)
                {
                    CGRect contextualMenuFrame = [self.layoutManager frameForContextualMenuInRow:row];
//                    row.contextualMenu.hidden = YES;
                    [self.animationManager slideContextualMenu:row.contextualMenu
                                                       toFrame:contextualMenuFrame
                                                          fast:NO];
                }
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

//-(void) adjustContextualViews
//{
//    for(UIView<ListRow> * row in self.scrollView.subviews)
//    {
//        if ([row conformsToProtocol:@protocol(ListRow)])
//        {
//            if (row.contextualMenu)
//            {
//                CGRect frame = [self.layoutManager frameForContextualMenuInRow:row];
//                row.contextualMenu.frame = frame;
//            }
//        }
//    }
//
//}
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
-(UIView<ListRowProtocol> *)rowForIndex:(int)index
                  withPrototype:(UIView<ListRowProtocol> *)prototype
{
    
    if (index >= [self.dataSource count]) return nil;
    
    prototype.text = [self.dataSource titleForItemAtIndex:index];
    if ([prototype respondsToSelector:@selector(setImage:)])
    {
        prototype.image = [self.dataSource imageForItemAtIndex:index];
    }
    
    prototype.frame = [self.layoutManager frameForRowforIndex:index
                                                  inSuperView:self.scrollView];
    CGRect frame = [self.layoutManager frameForContextualMenuInRow:prototype];
    if (prototype.contextualMenu == nil)
    {
        
    }
    prototype.contextualMenu.frame = frame;
    [self.scrollView addSubview:prototype.contextualMenu];
    return prototype;
}

-(void) didRecycledRow:(UIView<ListRowProtocol> *)recycledView
              ForIndex:(int)index
{
    
}

-(NSArray *) lowestAndHighestIndexInView
{
    return [self.layoutManager lowestAndHighestIndexForFrame:self.scrollView.bounds
                                                 inSuperView:self.scrollView];
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
