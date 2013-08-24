//
//  NoteResolutionNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/17/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "NoteResolutionNotification.h"

@implementation NoteResolutionNotification

-(id) initWithNoteModel:(CollectionNoteAttribute *) noteModel
         andNoteContent:(id<NoteProtocol>) noteContent
      forCollectionName:(NSString *) collectionName
              andNoteId:(NSString *) noteId
{
    self = [super init];
    _noteId = noteId;
    _collectionName = collectionName;
    _noteContent = noteContent;
    _collectionNoteAttribute = noteModel;
    _hasImage = NO;
    return self;
}

-(id) initWithNoteModel:(CollectionNoteAttribute *) noteModel
         andNoteContent:(id<NoteProtocol>) noteContent
           andImagePath:(NSString *) imagePath
      forCollectionName:(NSString *) collectionName
              andNoteId:(NSString *) noteId
{
    self = [self initWithNoteModel:noteModel
                    andNoteContent:noteContent
                 forCollectionName:collectionName
                         andNoteId:noteId];
    _hasImage = YES;
    _noteImagePath = imagePath;
    return self;
}

@end
