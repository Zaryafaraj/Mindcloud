//
//  PaintbrushViewController.h
//  Mindcloud
//
//  Created by Ali Fathalian on 10/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PaintbrushDelegate <NSObject>

-(void) brushSelectedWithWidth:(CGFloat) width;

@end

@interface PaintbrushViewController : UIViewController

@property (nonatomic) CGFloat maxBrushWidth;
@property (nonatomic) CGFloat minBrushWidth;
@property (nonatomic) CGFloat currentBrushWidth;
@property (nonatomic, strong) UIColor * currentColor;
@property (nonatomic, weak) id<PaintbrushDelegate> delegate;


@end
