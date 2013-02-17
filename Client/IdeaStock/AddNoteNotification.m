//
//  AddNoteNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "AddNoteNotification.h"
@interface AddNoteNotification()

@property (atomic, strong) NSString * noteId;
@property (atomic, strong) NSString * noteName;
@property (atomic, strong) NSString * positionX;
@property (atomic, strong) NSString * positionY;
@property (atomic, strong) NSString * scaling;

@end

@implementation AddNoteNotification
-(id) initWithNoteId:(NSString *)noteId
             andName:(NSString *)noteName
        andPositionX:(NSString *)positionX
        andPositionY:(NSString *)positionY
          andScaling:(NSString *)scaling
{
    self = [super init];
    self.noteId = noteId;
    self.positionX = positionX;
    self.positionY = positionY;
    self.scaling = scaling;
    self.noteName = noteName;
    return self;
}

-(NSString *) getNoteId
{
    return self.noteId;
}

-(NSString *) getPositionX
{
    return self.positionX;
}

-(NSString *) getPositionY
{
    return self.positionY;
}

-(NSString *) getScale
{
    return self.scaling;
}

-(NSString *) getNoteName
{
    return self.noteName;
}
@end
