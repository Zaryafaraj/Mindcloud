//
//  ThemeFactory.m
//  Mindcloud
//
//  Created by Ali Fathalian on 9/27/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "ThemeFactory.h"
#import "BlueTheme.h"

@implementation ThemeFactory

+(id<ThemeProtocol>) currentTheme
{
    static id<ThemeProtocol>  currentTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentTheme = [[BlueTheme alloc] init];
    });
    return currentTheme;
}

@end
