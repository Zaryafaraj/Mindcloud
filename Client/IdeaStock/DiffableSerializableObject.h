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
-(NSData *) serializeToData;
-(BOOL) deserializeFromFile:(NSString *) filename;
-(BOOL) deserializeFromData:(NSData *) data;

-(BOOL) serializeDiffToFile:(NSString *) filename;
-(NSData *) serializeDiffToData;
-(BOOL) deserializeDiffFromFile:(NSString *) filename;
-(BOOL) deserializeDiffFromData:(NSData *)data;

@end
