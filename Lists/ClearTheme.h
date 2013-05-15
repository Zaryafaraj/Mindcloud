//
//  GlassyTheme.h
//  Lists
//
//  Created by Ali Fathalian on 4/7/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThemeProtocol.h"

@interface ClearTheme : NSObject <ThemeProtocol>

+(id<ThemeProtocol>) theme;

@end
