//
//  ListRowAnimationManager.h
//  Lists
//
//  Created by Ali Fathalian on 4/19/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ListTableAnimationManager <NSObject>

-(void) slideMainScreenRowDown:(UIView *) row
                       toFrame:(CGRect) frame;

@end
