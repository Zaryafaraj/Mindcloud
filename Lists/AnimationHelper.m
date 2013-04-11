//
//  AnimationHelper.m
//  Lists
//
//  Created by Ali Fathalian on 4/9/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "AnimationHelper.h"

@implementation AnimationHelper

+(void) slideMainScreenRowDown:(UIView *) row
                       toFrame:(CGRect) frame
{
    [UIView animateWithDuration:0.25 animations:^{
        row.frame = frame;
    }];
}

+(void) slideOpenMainScreenRow:(UIView *) row
{
    [UIView animateWithDuration:0.30
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         row.frame = CGRectMake(row.frame.origin.x + row.frame.size.width/3,
                                                row.frame.origin.y,
                                                row.frame.size.width - row.frame.size.width/3,
                                                row.frame.size.height);
                     } completion:nil];
}

+(void) slideCloseMainScreenRow:(UIView *) row
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         row.frame = row.superview.bounds;
                     }completion:nil];
}
@end
