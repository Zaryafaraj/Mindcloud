//
//  RotatingRecylerAcimationManager.m
//  Lists
//
//  Created by Ali Fathalian on 4/27/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "RotatingRecylerAcimationManager.h"

@implementation RotatingRecylerAcimationManager

-(void) animateViewDidMoveOutOfTop:(UIView *) view
                      withCallback:(view_move_out_callback) callback
{
    callback();
}
-(void) animateViewDidMoveOutOfBottom:(UIView *) view
                      withCallback:(view_move_out_callback) callback
{
    callback();
}
@end
