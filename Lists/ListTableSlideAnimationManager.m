//
//  AnimationHelper.m
//  Lists
//
//  Created by Ali Fathalian on 4/9/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ListTableSlideAnimationManager.h"

@implementation ListTableSlideAnimationManager

-(void) slideMainScreenRowDown:(UIView *) row
                       toFrame:(CGRect) frame
{
    [UIView animateWithDuration:0.25 animations:^{
        row.frame = frame;
    }];
}


@end
