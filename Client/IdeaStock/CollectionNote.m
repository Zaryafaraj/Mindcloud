//
//  XoomlNote.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CollectionNote.h"
#import "XoomlManifestParser.h"
#import "XoomlAttributeHelper.h"

@implementation CollectionNote

@synthesize noteText = _noteText;
@synthesize noteTextID = _noteID;
@synthesize  creationDate = _creationDate;
@synthesize modificationDate = _modificationDate;
@synthesize image = _image;
//Constructor for creating an empty note with the creationDate
-(CollectionNote *) initWithCreationDate: (NSString *) date{
    self = [[CollectionNote alloc] init];
    self.creationDate = date;
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
    self.creationDate = date;
    return self;
}

-(CollectionNote *) initWithText: (NSString *) text{

    self = [[CollectionNote alloc] init];
    NSString * date = [XoomlAttributeHelper generateCurrentTimeForXooml];
    self.creationDate = date;
    self.modificationDate = date;
    self.noteTextID = [XoomlAttributeHelper generateUUID];
    self.noteText = text;
    return  self;
}

- (NSString *) description{
    return self.noteText;
}
@end
