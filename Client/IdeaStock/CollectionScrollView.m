//
//  DummyScrollView.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/9/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionScrollView.h"
#import "CollectionBoardView.h"

@interface CollectionScrollView()

//this is strong reference because it is referencing a subview inside a view and once
//the view (this object) goes out of scope the children including this property
//will go out of view
@property (strong, nonatomic) IBOutlet CollectionBoardView *  surrogateView;
@property CGRect originalSize;
@property CGPoint originalContentOffset;
@property BOOL viewIsAdjusted;

@end

@implementation CollectionScrollView

#define OFFSET_FROM_BOTTOM 10

-(id) awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    self = [super awakeAfterUsingCoder:aDecoder];
       if (self)
       {
           [self configureView];
       }
    return self;
}

-(void) configureView
{
    self.delegate = self;
    self.minimumZoomScale = 0.5;
    self.scrollEnabled = YES;
    self.maximumZoomScale = 2;
}

//this assumes that bounds have already made it to the target orientation sizes
-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation) orientation
{
    CGFloat surrogateWidth = self.surrogateView.bounds.size.width;
    CGFloat surrogateHeight = self.surrogateView.bounds.size.height;
    CGFloat minZoomWidth =  self.bounds.size.width / surrogateWidth;
    CGFloat minZoomHeight =  self.bounds.size.height / surrogateHeight;
    CGFloat targetZoomFactor = MAX(minZoomHeight, minZoomWidth);
    
    //this is a relative transform. If we were all zoomed out the minimum zoom scale should
    //be target zoom scale. Right now the minimum scale is self.minimumZoomScale. So the
    //ration by which the scaling should be changed is the targetMinZoomScale/currentMinZoomScale. We can then use the ratio to update the current transform
    
    CGFloat scaleRatio = targetZoomFactor / self.minimumZoomScale;
    
    self.surrogateView.transform = CGAffineTransformScale(self.surrogateView.transform, scaleRatio, scaleRatio);
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    CGFloat surrogateWidth = self.surrogateView.bounds.size.width;
    CGFloat surrogateHeight = self.surrogateView.bounds.size.height;
    
    CGFloat minZoomWidth =  self.bounds.size.width / surrogateWidth;
    CGFloat minZoomHeight =  self.bounds.size.height / surrogateHeight;
    CGFloat actualZoomFactor = MAX(minZoomHeight, minZoomWidth);
    self.minimumZoomScale = actualZoomFactor;
    
    return self.surrogateView;
}

-(void) adjustSizeForKeyboardAppearing:(CGSize) kbSize
                      overSelectedView:(UIView *) activeView
{
    float keyboardHeight = MIN(kbSize.height, kbSize.width);
    
    CGRect aRect = CGRectMake(self.contentOffset.x,
                              self.contentOffset.y,
                              self.bounds.size.width,
                              self.bounds.size.height);
    
    CGRect currentViewBounds = aRect;
    
    CGPoint noteViewCenter = activeView.center;
    noteViewCenter = CGPointMake(noteViewCenter.x * self.zoomScale,
                                 noteViewCenter.y * self.zoomScale);
    CGRect scaledActiveViewBounds = CGRectMake(activeView.bounds.origin.x * self.zoomScale,
                                               activeView.bounds.origin.y * self.zoomScale,
                                               activeView.bounds.size.width * self.zoomScale,
                                               activeView.bounds.size.height * self.zoomScale);
    //the -1 is there because we dont want the rightestCornerToNotFallInside
    //we will take the note width or the screen width whichever is minimum
    //the reason is that half of the note maybe outside and hence the rightest most part
    //might not fall inside the keyboard rectangle
    CGFloat noteViewRightestCornerX = MIN(noteViewCenter.x + scaledActiveViewBounds.size.width/2,
                                         aRect.origin.x + aRect.size.width - 1);
    CGPoint noteViewRightCorner = CGPointMake(noteViewRightestCornerX,
                                              noteViewCenter.y + scaledActiveViewBounds.size.height/2);
    //view size without the keyboard
    aRect.size.height -= keyboardHeight;
    
    //if the rightest lowest part of the note does not fall inside the view without
    //the keyboard then we need to adjust
    if (!CGRectContainsPoint(aRect,noteViewRightCorner))
    {
        CGFloat spaceFromLowerCornerToBottom = currentViewBounds.origin.y + currentViewBounds.size.height - noteViewRightCorner.y;
        CGFloat addedVisibleSpaceY = keyboardHeight - spaceFromLowerCornerToBottom;
        self.originalContentOffset = self.contentOffset;
        CGPoint scrollPoint = CGPointMake(self.contentOffset.x, self.contentOffset.y + addedVisibleSpaceY + OFFSET_FROM_BOTTOM);
        [self setContentOffset:scrollPoint animated:YES];
        self.viewIsAdjusted = YES;
    }
}

-(void) adjustSizeForKeyboardDisappearingOverSelectedView:(UIView *) activeView
{
    if (self.viewIsAdjusted)
    {
        [self setContentOffset:self.originalContentOffset animated:YES];
        self.viewIsAdjusted = NO;
    }
}

-(void) enablePaintMode
{
    
}

-(void) disablePaintMode
{
    
}

@end
