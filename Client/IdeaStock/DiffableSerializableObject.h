//
//  DiffableSerializableObject.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/1/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DiffableSerializableObject <NSObject>

-(BOOL) serializeToFile:(NSString *) filename;
-(BOOL) deserializeFromFile:(NSString *) filename;

-(BOOL) serializeDiffToFile:(NSString *) filename;
-(BOOL) deserializeDiffFromFile:(NSString *) filename;

@end
