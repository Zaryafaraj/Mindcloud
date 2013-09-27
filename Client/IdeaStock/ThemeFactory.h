//
//  ThemeFactory.h
//  Mindcloud
//
//  Created by Ali Fathalian on 9/27/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThemeProtocol.h"

@interface ThemeFactory : NSObject

+(id<ThemeProtocol>) currentTheme;

@end
