//
//  ListRowAnimationManager.h
//  Lists
//
//  Created by Ali Fathalian on 4/19/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListRowProtocol.h"

typedef void (^row_modification_callback)(void);

@protocol TableAnimatorProtocol <NSObject>

-(void) slideMainScreenRow:(UIView *) row
                   toFrame:(CGRect) frame
                      fast:(BOOL) fast;

-(void) animateAdditionForRow:(UIView<ListRowProtocol> *) row
                      toFrame:(CGRect) fram
                  inSuperView:(UIView *) superView
        withCompletionHandler:(row_modification_callback) callback;

-(void) animateAdditionForContextualMenu:(UIView *) menu
                             inSuperView:(UIView *) superView;

-(void) animateRemovalForRow:(UIView<ListRowProtocol> *) row
                  inSuperView:(UIView *) superView
       withCompletionHandler:(row_modification_callback) callback;

-(void) animateRemovalForContextualMenu:(UIView *) menu
                            inSuperView:(UIView *) superView
                  withCompletionHandler:(row_modification_callback) callback;

-(void) hideNavigationBar:(UINavigationBar *) navBar;

-(void) showNavigationBar:(UINavigationBar *) navBar;

-(void) slideContextualMenu:(UIView *) contextualMenu
                    toFrame:(CGRect) frame
                       fast:(BOOL) fast;


@optional
-(void) animateSetToDone:(UIView<ListRowProtocol> *) row;
-(void) animateSetToUndone:(UIView<ListRowProtocol> *) row;
-(void) animateSetToStar:(UIView<ListRowProtocol> *) row;
-(void) animateSetTimer:(UIView<ListRowProtocol> *) row;
-(void) animateExpandRow:(UIView<ListRowProtocol> *) row;

@end
