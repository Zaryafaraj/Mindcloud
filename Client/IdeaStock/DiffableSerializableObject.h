//
//  DiffableSerializableObject.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/1/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DiffableSerializableObject <NSObject>

-(void) serializeToFile:(NSString *) filename;
-(void) deserializeFromFile:(NSString *) filename;

-(void) serializeDiffToFile:(NSString *) filename;
-(void) deserializeDiffFromFile:(NSString *) filename;

@end
