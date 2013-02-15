//
//  UpdateNoteContentNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "UpdateNoteContentNotification.h"

@interface UpdateNoteContentNotification()

@property (atomic, strong) NSString *noteId;
@property (atomic, strong) NSString *noteContent;

@end
@implementation UpdateNoteContentNotification

-(id) initWithNoteId:(NSString *) noteId
      andNoteContent:(NSString *) noteContent
{
    self = [super init];
    self.noteId = noteId;
    self.noteContent = noteContent;
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

@end
