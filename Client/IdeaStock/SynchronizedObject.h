//
//  SynchronizedObject.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/8/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SynchronizedObject <NSObject>

-(void) startTimer;

-(void) stopTimer;

-(void) synchronize;

-(void) refresh;

-(void) stopSynchronization;

@end
