//
//  LayerStylizer.m
//  Lists
//
//  Created by Ali Fathalian on 4/6/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "LayerStylizer.h"
#import <QuartzCore/QuartzCore.h>
@interface LayerStylizer ()

@end

@implementation LayerStylizer

+(void) stylizeToolbar:(UIView *) toolbar
{
    [toolbar.layer setShadowColor:[UIColor blackColor].CGColor];
    [toolbar.layer setShadowOpacity:0.8];
    //self.toolbar.layer.opaque = YES;
    toolbar.layer.shouldRasterize = YES;
    [toolbar.layer setShadowRadius:3.0];
    [toolbar.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
}
@end
