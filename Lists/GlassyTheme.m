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
                              withOpenBounds:(CGRect) openBounds
{
    view.layer.shouldRasterize = YES;
    view.layer.cornerRadius = 1;
    if (isOpen)
    {
        view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:openBounds
                                                           cornerRadius:view.layer.cornerRadius].CGPath;
        view.layer.shadowPath = nil;
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(-2, 1);
        view.layer.shadowOpacity =  1;
        view.layer.shadowRadius = 1.0;
        return view;
    }
    else
    {
        CGRect newRect = view.superview.layer.bounds;
        view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:newRect
                                                           cornerRadius:view.layer.cornerRadius].CGPath;
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(0, 1);
        view.layer.shadowOpacity = 1;
        view.layer.shadowRadius = 1.0;
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

-(UIColor *) colorForMainScreenRowSelected
{
    return [UIColor colorWithWhite:0.85 alpha:1];
   //[UIColor colorWithHue:0.41 saturation:0.93 brightness:0.66 alpha:1];
}

-(CGFloat) alphaForMainScreenNavigationBar
{
    return 0.7;
}
-(UIColor *) colorForMainScreenNavigationBar
{
    return [UIColor whiteColor];
}

-(CGFloat) alphaForCollectionScreenNavigationBar
{
    return [self alphaForMainScreenNavigationBar];
}

-(UIColor *) colorForCollectionScreenNavigationBar
{
    return [self colorForMainScreenRowSelected];
}

-(CGFloat) spaceBetweenRowsInMainScreen
{
    return 5;
}
-(CGFloat) spaceBetweenRowsInCollectionScreen
{
    return 0;
}

@end
