//
//  ListRowAnimationManager.h
//  Lists
//
//  Created by Ali Fathalian on 4/19/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^add_collection_callback)(void);

@protocol ListTableAnimationManager <NSObject>

-(void) slideMainScreenRowDown:(UIView *) row
                       toFrame:(CGRect) frame;

-(void) animateAdditionForRow:(UIView *) row
                      toFrame:(CGRect) fram
                  inSuperView:(UIView *) superView
        withCompletionHandler:(add_collection_callback) callback;
@end
