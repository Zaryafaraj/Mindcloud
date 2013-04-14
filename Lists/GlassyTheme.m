//
//  GlassyTheme.m
//  Lists
//
//  Created by Ali Fathalian on 4/7/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "GlassyTheme.h"
#import <QuartzCore/QuartzCore.h>

@implementation GlassyTheme

-(UIImage *) imageForMainScreenRowDeleteButton
{
    return [UIImage imageNamed:@"GlassyMainRowDelete.png"];
}
-(UIImage *) imageForMainScreenRowShareButton;
{
    return [UIImage imageNamed:@"GlassyMainRowShare.png"];
}
-(UIImage *) imageForMainscreenRowRenameButton
{
    return [UIImage imageNamed:@"GlassyMainRowEdit.png"];
}

-(UIView *) stylizeMainscreenRowForeground:(UIView *) view
                                    isOpen:(BOOL) isOpen
{
    if (isOpen)
    {
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(-2, 2);
        view.layer.shadowOpacity =  1;
        view.layer.shadowRadius = 2.0;
        return view;
    }
    else
    {
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(0, 1);
        view.layer.shadowOpacity = 1;
        view.layer.shadowRadius = 1.0;
        view.clipsToBounds = NO;
        return view;
    }
}

-(UIView *) stylizeMainScreenRowButton:(UIButton *) button
{
        button.layer.shadowColor = [UIColor blackColor].CGColor;
        button.layer.shadowOffset = CGSizeMake(0, 1);
        button.layer.shadowOpacity = 1;
        button.layer.shadowRadius = 1.0;
        button.clipsToBounds = NO;
//        button.layer.borderColor = [UIColor blackColor].CGColor;
//    button.layer.borderWidth = 0.5;
    return button;
}

@end
