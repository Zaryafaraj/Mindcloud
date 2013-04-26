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

+(id<ITheme>) theme
{
    return [[GlassyTheme alloc] init];
}

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
    view.layer.shouldRasterize = YES;
    view.layer.cornerRadius = 5;
    if (isOpen)
    {
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(-2, 1);
        view.layer.shadowOpacity =  1;
        view.layer.shadowRadius = 1.0;
        view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:view.layer.bounds
                                                           cornerRadius:view.layer.cornerRadius].CGPath;
        return view;
    }
    else
    {
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(0, 1);
        view.layer.shadowOpacity = 1;
        view.layer.shadowRadius = 1.0;
        view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:view.layer.bounds
                                                           cornerRadius:view.layer.cornerRadius].CGPath;
        view.clipsToBounds = NO;
        return view;
    }
}

-(UIView *) stylizeMainScreenRowButton:(UIButton *) button
{
    
        //button.layer.shadowPath = [UIBezierPath bezierPathWithRect:button.bounds].CGPath;
        button.layer.cornerRadius = 3;
        button.layer.shouldRasterize = YES;
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
