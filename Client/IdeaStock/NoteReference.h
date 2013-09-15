//
//  NoteReference.h
//  Mindcloud
//
//  Created by Ali Fathalian on 9/15/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteReference : NSObject

@property (nonatomic, strong) NSString * refId;
@property (nonatomic, strong) NSString * ID;

-(id) initWithId:(NSString *) itemId
        andRefId:(NSString *) refId;

-(id) initWithRefId:(NSString *) refId;

@end
