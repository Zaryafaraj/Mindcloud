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
{
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 1;
    view.layer.shadowRadius = 1.0;
    view.clipsToBounds = NO;
    return view;
}

@end
