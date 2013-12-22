//
//  PaintConfigView.h
//  Mindcloud
//
//  Created by Ali Fathalian on 12/19/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PaintConfigDelegate <NSObject>

-(void) paintColorSelected:(UIColor *) currentColor;
-(void) brushSelectedWithWidth:(CGFloat) width;

-(void) undoPressed;
-(void) paintPressed;
-(void) clearPressed;
-(void) eraserPressed;
-(void) paintModeActivated;

@end

@interface PaintConfigView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) id<PaintConfigDelegate> delegate;
@property (nonatomic) CGFloat currentBrushWidth;
@property (nonatomic, strong) UIColor * selectedColor;
@property (nonatomic) CGFloat maxBrushWidth;
@property (nonatomic) CGFloat minBrushWidth;

-(void) redrawSamplePath;

@end
