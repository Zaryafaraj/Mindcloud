//
//  BrushSelectionView.h
//  Mindcloud
//
//  Created by Ali Fathalian on 10/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrushSelectionView : UIView

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) UIColor * lineColor;

-(void) redrawSamplePath;

@end
