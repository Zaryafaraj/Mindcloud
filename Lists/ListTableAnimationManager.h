//
//  ListRowAnimationManager.h
//  Lists
//
//  Created by Ali Fathalian on 4/19/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^row_modification_callback)(void);

@protocol ListTableAnimationManager <NSObject>

-(void) slideMainScreenRow:(UIView *) row
                   toFrame:(CGRect) frame;

-(void) animateAdditionForRow:(UIView *) row
                      toFrame:(CGRect) fram
                  inSuperView:(UIView *) superView
        withCompletionHandler:(row_modification_callback) callback;

-(void) animateRemovalForRow:(UIView *) row
                  inSuperView:(UIView *) superView
       withCompletionHandler:(row_modification_callback) callback;
@end
