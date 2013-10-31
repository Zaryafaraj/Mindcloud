//
//  PaintColorViewController.h
//  Mindcloud
//
//  Created by Ali Fathalian on 10/29/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PaintColorDelegate <NSObject>

-(void) paintColorSelected:(UIColor *) color;

@end

@interface PaintColorViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) CGFloat currentBrushWidth;
@property (nonatomic, strong) UIColor * selectedColor;
@property (nonatomic, weak) id<PaintColorDelegate> delegate;

@end
