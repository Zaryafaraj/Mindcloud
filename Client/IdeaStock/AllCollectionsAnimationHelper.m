//
//  AllCollectionsAnimationHelper.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/6/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "AllCollectionsAnimationHelper.h"

@implementation AllCollectionsAnimationHelper

-(void) animateSwitchCategory:(UIColor *) categoryBackgroundColor
        withCategoryTitleView:(UIView *) titleView
{
    CGFloat duration = 0.3;
    UIView * backgroundView = titleView.superview;
    [UIView animateWithDuration: duration
                     animations:^{
                         backgroundView.backgroundColor = categoryBackgroundColor;
                     }];
    
}

@end
