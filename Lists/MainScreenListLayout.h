//
//  MainScreenListLayout.h
//  Lists
//
//  Created by Ali Fathalian on 4/8/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainScreenListLayout : NSObject

+(CGRect) frameForRowforIndex:(int) index
          inSuperView:(UIView *) superView;

+ (CGPoint) originForFrameAfterFrame:(CGRect) frame;

+ (int) lowestRowIndexInFrame:(CGRect) frame;

+ (int) highestRowIndexInFrame:(CGRect) frame;

@end
