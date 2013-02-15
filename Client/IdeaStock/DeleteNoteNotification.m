//
//  DeleteNoteNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "DeleteNoteNotification.h"
@interface DeleteNoteNotification()
@property (atomic, strong) NSString * noteId;
@end
@implementation DeleteNoteNotification

-(id) initWithNoteId:(NSString *)noteId
{
    self = [super init];
    self.noteId = noteId;
    return self;
}
-(NSString *) getNoteId
{
    return self.noteId;
}
@end
