//
//  NoteReference.m
//  Mindcloud
//
//  Created by Ali Fathalian on 9/15/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "NoteReference.h"
#import "AttributeHelper.h"

@implementation NoteReference

-(id) initWithId:(NSString *) itemId
        andRefId:(NSString *) refId
{
    self = [super init];
    if (self)
    {
        self.ID = itemId;
        self.refId = refId;
    }
    
    return self;
}

-(id) initWithRefId:(NSString *) refId
{
    self = [super init];
    if (self)
    {
        self.refId = refId;
        self.ID = [AttributeHelper generateUUID];
    }
    return self;
}

@end
