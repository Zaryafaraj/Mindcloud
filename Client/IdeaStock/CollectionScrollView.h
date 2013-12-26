//
//  DummyScrollView.h
//  Mindcloud
//
//  Created by Ali Fathalian on 10/9/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CollectionScrollviewDelegate <NSObject>

-(void) viewDidZoomWithZoomScale:(int) zoomScale;
-(void) viewFinishedZoomingWithScale:(int) zoomScale;

@end

@interface CollectionScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, weak) id<CollectionScrollviewDelegate> collectionDel;

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation) orientation;

-(void) adjustSizeForKeyboardAppearing:(CGSize) kbSize
                      overSelectedView:(UIView *) activeView;

-(void) adjustSizeForKeyboardDisappearingOverSelectedView:(UIView *) activeView;

-(void) enablePaintMode;

-(void) disablePaintMode;
@end
