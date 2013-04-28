//
//  ScrollViewRecyclerAnimationManager.h
//  Lists
//
//  Created by Ali Fathalian on 4/27/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^view_move_out_callback)(void);
@protocol ScrollViewRecyclerAnimationManager <NSObject>

-(void) animateViewDidMoveOutOfTop:(UIView *) view
                      withCallback:(view_move_out_callback) callback;
-(void) animateViewDidMoveOutOfBottom:(UIView *) view
                      withCallback:(view_move_out_callback) callback;
@end
