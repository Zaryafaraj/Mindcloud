//
//  AnimationHelper.h
//  Lists
//
//  Created by Ali Fathalian on 4/9/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimationHelper : NSObject

+(void) slideMainScreenRowDown:(UIView *) row
                       toFrame:(CGRect) frame;

+(void) slideOpenMainScreenRow:(UIView *) row;

+(void) slideCloseMainScreenRow:(UIView *) row;
@end
