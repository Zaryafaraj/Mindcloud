//
//  XoomlNote.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "BulletinBoardNote.h"
#import "XoomlManifestParser.h"
#import "XoomlAttributeHelper.h"

@implementation BulletinBoardNote

@synthesize noteText = _noteText;
@synthesize noteTextID = _noteID;
@synthesize  creationDate = _creationDate;
@synthesize modificationDate = _modificationDate;
@synthesize image = _image;
//Constructor for creating an empty note with the creationDate
-(BulletinBoardNote *) initWithCreationDate: (NSString *) date{
    self = [[BulletinBoardNote alloc] init];
    self.creationDate = date;
    return self;
}

-(BulletinBoardNote *) initEmptyNoteWithID: (NSString *) noteID{
    self = [[BulletinBoardNote alloc] init];
    self.noteTextID = noteID;
    return self;
}

-(BulletinBoardNote *) initEmptyNoteWithID:(NSString *)noteID 
                                   andDate: (NSString *)date{
    self = [[BulletinBoardNote alloc] init];
    self.noteTextID = noteID;
    self.creationDate = date;
    return self;
}

-(BulletinBoardNote *) initWithText: (NSString *) text{

    self = [[BulletinBoardNote alloc] init];
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
