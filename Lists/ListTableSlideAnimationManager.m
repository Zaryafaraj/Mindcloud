//
//  AnimationHelper.m
//  Lists
//
//  Created by Ali Fathalian on 4/9/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ListTableSlideAnimationManager.h"

@implementation ListTableSlideAnimationManager

-(void) slideMainScreenRow:(UIView *) row
                   toFrame:(CGRect) frame
{
    [UIView animateWithDuration:0.25 animations:^{
        row.frame = frame;
    }];
}


-(void) animateAdditionForRow:(UIView *) row
                      toFrame:(CGRect) frame
                  inSuperView:(UIView *) superView
        withCompletionHandler:(row_modification_callback) callback
{
    [superView addSubview:row];
    row.alpha = 0;
    row.frame = CGRectMake(-frame.origin.x,frame.origin.y, frame.size.width, frame.size.height);
    [UIView animateWithDuration:0.4 animations:^{
        row.alpha = 1;
        row.frame = frame;
    }];
}

-(void) animateRemovalForRow:(UIView *) row
                  inSuperView:(UIView *) superView
       withCompletionHandler:(row_modification_callback) callback
{
    [UIView animateWithDuration:0.25 animations:^{
        row.alpha = 0;
    }completion:^(BOOL finished){
        if (finished)
        {
            callback();
        }
    }];
}
@end
