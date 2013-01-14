//
//  QueueProducer.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/9/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QueueProducer <NSObject>

@property id queue;

-(void) putIntoQueue: (id) item;

-(void) produceNext;


@end
