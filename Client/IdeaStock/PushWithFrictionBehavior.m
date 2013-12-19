//
//  PushWithFrictionBehavior.m
//  Mindcloud
//
//  Created by Ali Fathalian on 12/18/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "PushWithFrictionBehavior.h"

@interface PushWithFrictionBehavior()

@property (nonatomic, strong) UIPushBehavior * push;
@property (nonatomic, strong) UIDynamicItemBehavior * physics;
@property (nonatomic, strong) NSArray * items;
@end

@implementation PushWithFrictionBehavior

-(instancetype) initWithItmes:(NSArray *) items
{
    if (self=[super init])
    {
        self.items = items;
        UICollisionBehavior * collision = [[UICollisionBehavior alloc] initWithItems:items];
        collision.translatesReferenceBoundsIntoBoundary = TRUE;
        collision.collisionDelegate = self;
        [self addChildBehavior:collision];
        
        UIPushBehavior * push = [[UIPushBehavior alloc] initWithItems:items
                                                                 mode:UIPushBehaviorModeInstantaneous];
        self.push = push;
        [self addChildBehavior:push];
        
        UIDynamicItemBehavior * basicPhysics = [[UIDynamicItemBehavior alloc] initWithItems:items];
        
        basicPhysics.friction = 550.0;
        basicPhysics.density *= 2;
        basicPhysics.resistance = 0.8;
        [self addChildBehavior:basicPhysics];
    }
    return self;
}

-(void) setPushVector:(CGVector) pushVector;
{
    self.push.pushDirection = pushVector;
}

-(void) setInitialVelocity:(CGPoint)veloc
{
    for(UIView * view in self.items)
    {
        [self.physics addLinearVelocity:veloc forItem:view];
    }
}

-(void) setForce:(CGFloat)forcesize
{
    self.push.magnitude = forcesize;
}

-(void) collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier
{
    id<PushWithFrictionBehaviorDelegate> temp = self.delegate;
    if (temp)
    {
        [temp collisionHappened];
    }
}
@end
