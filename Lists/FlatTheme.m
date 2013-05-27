//
//  FlatTheme.m
//  Lists
//
//  Created by Ali Fathalian on 5/21/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "FlatTheme.h"
#import <QuartzCore/QuartzCore.h>

@interface FlatTheme()

@property (nonatomic, strong) UIImage * rowBackgroundImage;
@property (nonatomic, strong) UIColor * doneColor;
@property (nonatomic, strong) UIColor * timedColor;
@property (nonatomic, strong) UIColor * starredColor;

@end
@implementation FlatTheme

-(CGFloat) rowWidth
{
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    CGFloat screenWidth = screenRect.size.width;
//    return screenWidth;
    UIUserInterfaceIdiom  device = [UIDevice currentDevice].userInterfaceIdiom;
    if (device == UIUserInterfaceIdiomPad)
    {
        return 650;
    }
    else
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        return screenWidth - 5;
    }

}
-(CGFloat) rowHeight
{
    UIUserInterfaceIdiom  device = [UIDevice currentDevice].userInterfaceIdiom;
    if (device == UIUserInterfaceIdiomPad)
    {
        return 100;
    }
    else
    {
        return 80;
    }
}

-(CGFloat) subItemHeight
{
    UIUserInterfaceIdiom  device = [UIDevice currentDevice].userInterfaceIdiom;
    if (device == UIUserInterfaceIdiomPad)
    {
        return 100;
    }
    else
    {
        return 50;
    }
}
-(CGFloat) contextualMenuOffset
{
    UIUserInterfaceIdiom  device = [UIDevice currentDevice].userInterfaceIdiom;
    if (device == UIUserInterfaceIdiomPad)
    {
        return 40;
    }
    else
    {
        return 20;
    }

}

-(CGFloat) mainScreenLabelInsetHorizontal
{
    return 0;
}
-(CGFloat) mainScreenLabelInsetVertical
{
    return 0;
}

-(CGFloat) mainScreenImageInsetHorizontal
{
    return 0;
}
-(CGFloat) mainScreenImageInsetVertical
{
    return 0;
}

-(CGFloat) mainScreenImageWidth
{
    return [self rowWidth]/4;
}

-(CGFloat) verticalDistanceFromTop
{
    return 5;
}

+(id<ThemeProtocol>) theme
{
    return [[FlatTheme alloc] init];
}

-(UIImage *) imageForRowBackground
{
    if (_rowBackgroundImage == nil)
    {
        _rowBackgroundImage = [UIImage imageNamed:@"tablerowbg.png"];
    }
    return _rowBackgroundImage;
}

-(UIImage *) imageForMainScreenRowDeleteButton
{
    return [UIImage imageNamed:@"GlassyMainRowDelete.png"];
}

-(UIImage *) imageCollectionScreenRowDeleteButton
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

-(UIImage *) imageForCollectionRowDone
{
    return [UIImage imageNamed:@"GlassyCollectionRowDone.png"];
}

-(UIImage * ) imageForCollectionRowUnDone
{
    return [UIImage imageNamed:@"GlassyCollectionRowNotDone.png"];
}

-(UIView *) stylizeMainscreenRowForeground:(UIView *) view
                                    isOpen:(BOOL) isOpen
                            withOpenBounds:(CGRect) openBounds
{
    
//    view.backgroundColor = [UIColor colorWithRed:0.9254 green:0.9411 blue:0.9450 alpha:1];
    view.layer.cornerRadius = 0;
    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.layer.borderWidth = 0.5;
    return view;
}

-(UIView *) stylizeMainScreenRowButton:(UIButton *) button
{
    
    button.layer.shouldRasterize = YES;
    
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    return button;
}

-(UIView *) stylizeCollectionScreenRowForeground:(UIView *) view
                                          isOpen:(BOOL) isOpen
                                  withOpenBounds:(CGRect) openBounds
{
    view.layer.shouldRasterize = YES;
    view.layer.cornerRadius = 0;
    if (isOpen)
    {
        view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:openBounds
                                                           cornerRadius:view.layer.cornerRadius].CGPath;
        view.layer.shadowPath = nil;
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(-2, 1);
        view.layer.shadowOpacity =  1;
        view.layer.shadowRadius = 1.5;
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
        view.layer.shadowRadius = 2.0;
        return view;
    }
    
    return view;
    
}

-(UIView *) stylizeCollectionScreenRowButton:(UIButton *) button
{
    button.layer.cornerRadius = 3;
    button.layer.shouldRasterize = YES;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 1);
    button.layer.shadowOpacity = 1;
    button.layer.shadowRadius = 1.0;
    button.clipsToBounds = NO;
    return button;
}

-(UIColor *) colorForMainScreenRowSelected
{
    return [UIColor colorWithWhite:0.85 alpha:1];
    //[UIColor colorWithHue:0.41 saturation:0.93 brightness:0.66 alpha:1];
}

-(CGFloat) alphaForMainScreenNavigationBar
{
    return 0.8;
}
-(UIColor *) colorForMainScreenNavigationBar
{
    return [UIColor whiteColor];
}

-(CGFloat) alphaForCollectionScreenNavigationBar
{
    return 0.90;
}

-(UIColor *) colorForCollectionScreenNavigationBar
{
    return [self colorForMainScreenRowSelected];
}

-(CGFloat) spaceBetweenRowsInMainScreen
{
    UIUserInterfaceIdiom  device = [UIDevice currentDevice].userInterfaceIdiom;
    if (device == UIUserInterfaceIdiomPad)
    {
        return 2;
    }
    else
    {
        return 0;
    }

}
-(CGFloat) spaceBetweenRowsInCollectionScreen
{
    return 5;
}

-(UIImage *) getContextualMenuItemBackground
{
    return [UIImage imageNamed:@"bg-menuitem.png"];
}

-(UIImage *) getContextualMenuItemBackgroundHighlighted
{
    return [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
}

-(UIImage *) getContextualMenuContentTop
{
    return [UIImage imageNamed:@"icon-clock.png"];
}

-(UIImage *) getContextualMenuContentLeft
{
    return [UIImage imageNamed:@"icon-delete.png"];
}

-(UIImage *) getContextualMenuContentRight
{
    return [UIImage imageNamed:@"icon-expand.png"];
}

-(UIImage *) getContextualMenuContentBottom
{
    
    return [UIImage imageNamed:@"icon-star.png"];
}

-(UIImage *) getContextualMenuButton
{
    return [UIImage imageNamed:@"bg-contextbutton.png"];
}

-(UIImage *) getContextualMenuButtonHighlighted
{
    
    return [UIImage imageNamed:@"bg-contextbutton-highlighted.png"];
}

-(UIImage *) getContextualMenuButtonContent
{
    return nil;
    //return [UIImage imageNamed:@"icon-contextbutton.png"];
}

-(UIImage *) getContextualMenuButtonContentHighlighted
{
    return [UIImage imageNamed:@"icon-contextbutton-highlighted.png"];
}


-(UIColor *) colorForTaskStateDone
{
    if (self.doneColor == nil)
    {
        self.doneColor = [UIColor colorWithHue:0.31 saturation:0.85 brightness:0.85 alpha:1];
    }
    return self.doneColor;
}

-(UIColor *) colorForTaskStateUndone
{
    return [UIColor whiteColor];
}

-(UIColor *) colorForTaskStateStarred
{
    if (self.starredColor == nil)
    {
        self.starredColor = [UIColor colorWithHue:0.14 saturation:0.81 brightness:1.0 alpha:1];
    }
    return self.starredColor;
}

-(UIColor *) colorForTaskStateTimed
{
    if (self.timedColor == nil)
    {
        self.timedColor = [UIColor colorWithHue:0.64 saturation:0.45 brightness:1.0 alpha:1];
    }
    return self.timedColor;
}

-(UIColor *) colorForMainScreenText
{
    return [UIColor blackColor];
}

-(UIFont *) fontForMainScreenText
{
    return [UIFont fontWithName:@"Helvetica" size:20];
}

@end
