//
//  XoomlNote.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CollectionNote.h"
#import "XoomlCollectionParser.h"
#import "AttributeHelper.h"

@implementation CollectionNote

@synthesize noteText = _noteText;
@synthesize noteTextID = _noteID;
@synthesize image = _image;
@synthesize name = _name;
//Constructor for creating an empty note with the creationDate
-(CollectionNote *) initWithCreationDate: (NSString *) date{
    self = [[CollectionNote alloc] init];
    return self;
}

-(CollectionNote *) initEmptyNoteWithID: (NSString *) noteID{
    self = [[CollectionNote alloc] init];
    self.noteTextID = noteID;
    return self;
}

-(CollectionNote *) initEmptyNoteWithID:(NSString *)noteID 
                                   andDate: (NSString *)date{
    self = [[CollectionNote alloc] init];
    self.noteTextID = noteID;
    return self;
}

-(CollectionNote *) initWithText: (NSString *) text{

    self = [[CollectionNote alloc] init];
    self.noteTextID = [AttributeHelper generateUUID];
    self.noteText = text;
    return  self;
}

-(CollectionNote *) initWithText:(NSString *)text
                       andNoteId:(NSString *) noteId
{
    self = [[CollectionNote alloc] init];
    self.noteTextID = noteId;
    self.noteText = text;
    return  self;
}

- (NSString *) description{
    return self.noteText;
}
@end
