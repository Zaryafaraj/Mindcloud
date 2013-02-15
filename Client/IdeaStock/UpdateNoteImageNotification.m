//
//  UpdateNoteImageNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "UpdateNoteImageNotification.h"

@interface UpdateNoteImageNotification()

@property (atomic, strong) NSString * noteId;
@property (atomic, strong) NSString * noteContent;
@property (atomic, strong) NSString * noteImagePath;
@end
@implementation UpdateNoteImageNotification

-(id) initWithNoteId:(NSString *)noteId
      andNoteContent:(NSString *)noteContent
    andNoteImagePath:(NSString *)noteImagePath
{
    self = [super init];
    self.noteId = noteId;
    self.noteContent = noteContent;
    self.noteImagePath = noteImagePath;
    return self;
}

-(NSString *) getNoteId
{
    return self.noteId;
}

-(NSString *) getNoteContent
{
    return self.noteContent;
}

-(NSString *) getNoteImagePath
{
    return self.noteImagePath;
}

@end
