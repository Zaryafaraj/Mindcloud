//
//  ColorCell.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/29/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "ColorCell.h"
#import "ThemeFactory.h"

@implementation ColorCell
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        //self.layer.cornerRadius = frame.size.width / 2;
        UIView *bgView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
        bgView.backgroundColor = [UIColor clearColor];
        bgView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        bgView.layer.borderWidth = 2;
        //bgView.layer.cornerRadius = 25;
        self.selectedBackgroundView = bgView;
    }
    return self;
}
-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        
        // self.layer.cornerRadius = 25;
        UIView *bgView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
        bgView.backgroundColor = [UIColor clearColor];
        bgView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        bgView.layer.borderWidth = 1;
        bgView.layer.cornerRadius = 25;
        self.selectedBackgroundView = bgView;
    }
    return self;
}

-(void) adjustSelectedBorderColorBaseOnBackgroundColor:(UIColor *) backgroundColor
                                       withLightColors:(NSSet *) lightColors
{
    for (UIColor * color in lightColors)
    {
        if ([backgroundColor isEqual:color])
        {
            self.selectedBackgroundView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        }
        else
        {
            self.selectedBackgroundView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        }
    }
}
@end

