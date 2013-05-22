//
//  FlatTheme.h
//  Lists
//
//  Created by Ali Fathalian on 5/21/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThemeProtocol.h"

@interface FlatTheme : NSObject <ThemeProtocol>

+(id<ThemeProtocol>) theme;

@end
