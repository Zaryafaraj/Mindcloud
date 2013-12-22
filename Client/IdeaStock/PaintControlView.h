//
//  PaintControlView.h
//  Mindcloud
//
//  Created by Ali Fathalian on 12/18/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PaintControlViewDelegate <NSObject>

-(void) controlReleasedWithVelocity:(CGPoint)velocity
                  withPushDirection:(CGVector) directionVector;

-(void) controlDragged;

-(void) controlSelected;

@end

@interface PaintControlView : UIView

@property (nonatomic, weak) id<PaintControlViewDelegate> delegate;

@property (nonatomic) CGFloat topOffset;

@property (nonatomic) BOOL eraseMode;

-(void) adjustViewToBeInBoundsForRotation;

-(void) adjustToClosestEdge;

@end
