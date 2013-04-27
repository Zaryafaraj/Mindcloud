//
//  ListRowSlideAnimationManager.m
//  Lists
//
//  Created by Ali Fathalian on 4/20/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ListRowSlideAnimationManager.h"

@implementation ListRowSlideAnimationManager



-(void) slideOpenMainScreenRow:(UIView *) row
                   withButtons: (NSArray *) buttons
                        toRect:(CGRect) openRect;
{
    [UIView animateWithDuration:0.30
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         row.frame = openRect;
                     } completion:nil];
}

-(void) slideCloseMainScreenRow:(UIView *) row
                    withButtons: (NSArray *) buttons
                 withCompletion:(row_animation_completion_callback) callback;
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         row.frame = row.superview.bounds;
                     }completion:^(BOOL finished){
                         for (UIButton * button in buttons)
                         {
                             button.hidden = YES;
                         }
                         callback();
                     }];
}
@end
