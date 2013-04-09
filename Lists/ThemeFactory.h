//
//  ThemeFactory.h
//  Lists
//
//  Created by Ali Fathalian on 4/7/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITheme.h"

@interface ThemeFactory : NSObject

+(id<ITheme>) currentTheme;

@end
