//
//  ListRowSlideAnimationManager.m
//  Lists
//
//  Created by Ali Fathalian on 4/20/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ListRowSlideAnimationManager.h"

@implementation ListRowSlideAnimationManager

-(void) slideOpenMainScreenRow:(UIView *) row withButtons:(NSArray *)buttons
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

-(void) slideCloseMainScreenRow:(UIView *) row withButtons:(NSArray *)buttons
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
                     }];
}
@end
