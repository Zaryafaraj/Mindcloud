//
//  ListRowAnimationManager.h
//  Lists
//
//  Created by Ali Fathalian on 4/20/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^row_animation_completion_callback)(void);

@protocol RowAnimator <NSObject>

-(void) slideOpenMainScreenRow:(UIView *) row
                   withButtons: (NSArray *) buttons
                      andLabel:(UIView *) label
              toForegroundRect:(CGRect) openRect
                  andLabelRect:(CGRect) labelRect;

-(void) slideCloseMainScreenRow:(UIView *) row
                    withButtons: (NSArray *) buttons
                       andLabel:(UIView *) label
               toForegroundRect: (CGRect) foregroundRect
                   andLabelRect:(CGRect) labelRect
                 withCompletion:(row_animation_completion_callback) callback;

@end
