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
//    CGSize totalSize = [self fixedContentSizeForScrollView];
//    CGRect frame = CGRectMake(0,
//                              0,
//                              totalSize.width,
//                              totalSize.height);
//    self.surrogateView = self.subviews[0];
////    self.surrogateView.frame = frame;
//    self.surrogateView.backgroundColor = [UIColor blueColor];
//    UIView * view = [[UIView alloc] initWithFrame:frame];
//    view.backgroundColor = [UIColor clearColor];
//    [super addSubview:view];
}

//-(void) addSubview:(UIView *)view
//{
//    [self.surrogateView addSubview:view];
//}
//
//-(NSArray *) subviews
//{
//   return [self.surrogateView subviews];
//}
//
//-(void) insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview
//{
//    [self.surrogateView insertSubview:view aboveSubview:siblingSubview];
//}
//
//-(void) insertSubview:(UIView *)view atIndex:(NSInteger)index
//{
//    [self.surrogateView insertSubview:view atIndex:index];
//}
//
//-(void) insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview
//{
//    [self.surrogateView insertSubview:view belowSubview:siblingSubview];
//}

-(CGSize) fixedContentSizeForScrollView
{
    
    //its 4 landscape ipads
    CGFloat totalWidth = self.bounds.size.width;
    CGFloat totalHeight = self.bounds.size.height;
    
    //the size is for landscape ipads sitting next to each other
    if (totalWidth < totalHeight)
    {
        CGFloat temp = totalWidth;
        totalWidth = totalHeight;
        totalHeight = temp;
    }

    CGSize totalContentSize = CGSizeMake( 4* totalWidth, 4 * totalHeight);
    return totalContentSize;
}

-(void) setContentSize:(CGSize)contentSize
{
    NSLog(@"contentSize %f - %f" , contentSize.width, contentSize.height);
    [super setContentSize:contentSize];
    
//    CGSize totalContentSize = [self fixedContentSizeForScrollView];
//    [super setContentSize:totalContentSize];
//    self.surrogateView.frame = CGRectMake(0,
//                                          0,
//                                          totalContentSize.width,
//                                          totalContentSize.height);
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.surrogateView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
