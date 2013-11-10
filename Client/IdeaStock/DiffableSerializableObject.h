//
//  DiffableSerializableObject.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/1/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DiffableSerializableObject <NSObject, NSCoding>

-(BOOL) serializeToFile:(NSString *) filename;
-(NSData *) serializeToData;
+(instancetype) deserializeFromData:(NSData *) data;

@end
