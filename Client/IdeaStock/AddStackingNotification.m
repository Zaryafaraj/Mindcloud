//
//  AddStackingNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "AddStackingNotification.h"

@interface AddStackingNotification()
@property (atomic, strong) NSString * stackingId;
@property (atomic, strong) NSString * scale;
@property (atomic, strong) NSArray * noteRefs;
@end
@implementation AddStackingNotification


-(id) initWithStackingId:(NSString *) stackingId
                andScale:(NSString *) scale
                andNoteRefs:(NSArray *) notes
{
    self = [super init];
    self.scale = scale;
    self.stackingId = stackingId;
    self.noteRefs = notes;
    return self;
}

-(NSString *) getStackId
{
    return self.stackingId;
}

-(NSString *) getScale
{
    return self.scale;
}

-(NSArray *) getNoteRefs
{
    return self.noteRefs;
}

@end
