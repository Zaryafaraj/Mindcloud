//
//  UpdateStackNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "UpdateStackNotification.h"

@interface UpdateStackNotification()

@property (atomic, strong) NSString * stackId;
@property (atomic, strong) NSString * scale;
@property (atomic, strong) NSArray * noteRefs;

@end
@implementation UpdateStackNotification

-(id) initWithStackId:(NSString *)stackId
             andScale:(NSString *)scale
          andNoteRefs:(NSArray *)noteRefs
{
    self = [super init];
    self.stackId = stackId;
    self.scale = scale;
    self.noteRefs = noteRefs;
    return self;
}

-(NSString *) getStackId
{
    return self.stackId;
}

-(NSString *) getScale
{
    return self.scale;
}

-(NSArray *)getNoteRefs
{
    return self.noteRefs;
}
@end
