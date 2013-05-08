//
//  ListRowAnimationManager.h
//  Lists
//
//  Created by Ali Fathalian on 4/19/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListRow.h"

typedef void (^row_modification_callback)(void);

@protocol ListTableAnimationManager <NSObject>

-(void) slideMainScreenRow:(UIView *) row
                   toFrame:(CGRect) frame
                      fast:(BOOL) fast;

-(void) animateAdditionForRow:(UIView<ListRow> *) row
                      toFrame:(CGRect) fram
                  inSuperView:(UIView *) superView
        withCompletionHandler:(row_modification_callback) callback;

-(void) animateRemovalForRow:(UIView<ListRow> *) row
                  inSuperView:(UIView *) superView
       withCompletionHandler:(row_modification_callback) callback;

-(void) hideNavigationBar:(UINavigationBar *) navBar;

-(void) showNavigationBar:(UINavigationBar *) navBar;

-(void) slideContextualMenu:(UIView *) contextualMenu
                    toFrame:(CGRect) frame
                       fast:(BOOL) fast;

@end
