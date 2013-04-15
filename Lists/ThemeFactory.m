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

static id<ITheme> currentTheme;

+(id<ITheme>) currentTheme
{
    static id<ITheme>  currentTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentTheme = [GlassyTheme theme];
    });
    return currentTheme;
}

@end
