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
           // Initialization code
       }
    return self;
}

-(void) configureView
{
    self.delegate = self;
    self.minimumZoomScale = 0.25;
    self.scrollEnabled = YES;
    self.maximumZoomScale = 4;
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.surrogateView;
}


@end
