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
                      andLabel:(UIView *) label
              toForegroundRect:(CGRect) openRect
                  andLabelRect:(CGRect) labelRect
{
    [UIView animateWithDuration:0.30
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         row.frame = openRect;
                         label.frame = labelRect;
                     } completion:^(BOOL finished){
                     }];
}

-(void) slideCloseMainScreenRow:(UIView *) row
                    withButtons: (NSArray *) buttons
                       andLabel:(UIView *) label
               toForegroundRect: (CGRect) foregroundRect
                   andLabelRect:(CGRect) labelRect
withCompletion:(row_animation_completion_callback) callback;
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         row.frame = foregroundRect;
                         label.frame = labelRect;
                     }completion:^(BOOL finished){
                         for (UIButton * button in buttons)
                         {
                             button.hidden = YES;
                         }
                         callback();
                     }];
}
@end
