//
//  ListRowAnimationManager.h
//  Lists
//
//  Created by Ali Fathalian on 4/20/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^row_animation_completion_callback)(void);

@protocol ListRowAnimationManager <NSObject>

-(void) slideOpenMainScreenRow:(UIView *) row
                   withButtons: (NSArray *) buttons
                        toRect:(CGRect) openRect;

-(void) slideCloseMainScreenRow:(UIView *) row
                    withButtons: (NSArray *) buttons
                 withCompletion:(row_animation_completion_callback) callback;

@end
