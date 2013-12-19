//
//  PushWithFrictionBehavior.h
//  Mindcloud
//
//  Created by Ali Fathalian on 12/18/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PushWithFrictionBehaviorDelegate <NSObject>

-(void) collisionHappened;

@end

@interface PushWithFrictionBehavior : UIDynamicBehavior<UICollisionBehaviorDelegate>

@property (nonatomic, weak) id<PushWithFrictionBehaviorDelegate> delegate;

-(instancetype) initWithItmes:(NSArray *) itmes;

-(void) setPushVector:(CGVector) pushVector;
-(void) setInitialVelocity:(CGPoint) veloc;
-(void) setForce:(CGFloat) forcesize;
@end
