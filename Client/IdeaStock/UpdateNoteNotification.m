//
//  UpdateNoteNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "UpdateNoteNotification.h"
@interface UpdateNoteNotification()
@property (atomic, strong) NSString * noteId;
@property (atomic, strong) NSString * positionX;
@property (atomic, strong) NSString * positionY;
@property (atomic, strong) NSString * scale;
@end
@implementation UpdateNoteNotification

-(id) initWithNoteId:(NSString *)noteId
        andPositionX:(NSString *)positionX
        andPositionY:(NSString *)positionY
            andScale:(NSString *)scale
{
    self = [super init];
    self.noteId = noteId;
    self.positionX = positionX;
    self.positionY = positionY;
    self.scale = scale;
    return self;
}

-(NSString *) getNoteId
{
    return self.noteId;
}

-(NSString *) getNotePositionX
{
    return self.positionX;
}

-(NSString *) getNotePositionY
{
    return self.positionY;
}

-(NSString *) getNoteScale
{
    return self.scale;
}

@end
