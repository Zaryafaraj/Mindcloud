//
//  ThemeFactory.m
//  Lists
//
//  Created by Ali Fathalian on 4/7/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ThemeFactory.h"
#import "GlassyTheme.h"

@implementation ThemeFactory

+(id<ITheme>) currentTheme
{
    return [[GlassyTheme alloc] init];
}

@end
