//
//  ThemeFactory.m
//  Lists
//
//  Created by Ali Fathalian on 4/7/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ThemeFactory.h"
#import "ClearTheme.h"
#import "FlatTheme.h"

@implementation ThemeFactory

+(id<ThemeProtocol>) currentTheme
{
    static id<ThemeProtocol>  currentTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentTheme = [FlatTheme theme];
    });
    return currentTheme;
}

@end
