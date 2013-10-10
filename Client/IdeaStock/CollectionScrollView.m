//
//  DummyScrollView.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/9/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionScrollView.h"

@interface CollectionScrollView()

//this is strong reference because it is referencing a subview inside a view and once
//the view (this object) goes out of scope the children including this property
//will go out of view
@property (strong, nonatomic) IBOutlet UIView *  surrogateView;

@end

@implementation CollectionScrollView

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
    self.surrogateView.transform = CGAffineTransformMakeScale(targetZoomFactor, targetZoomFactor);
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


@end
