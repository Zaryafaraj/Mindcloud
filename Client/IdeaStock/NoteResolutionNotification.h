//
//  NoteResolutionNotification.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/17/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlNoteModel.h"
#import "NoteProtocol.h"

@interface NoteResolutionNotification : NSObject

@property (atomic, readonly) BOOL hasImage;
@property (strong, atomic, readonly) XoomlNoteModel * noteModel;
@property (strong, atomic, readonly) id<NoteProtocol> noteContent;
@property (strong, atomic, readonly) NSString * noteImagePath;
@property (strong, atomic, readonly) NSString * collectionName;
@property (strong, atomic, readonly) NSString * noteId;

-(id) initWithNoteModel:(XoomlNoteModel *) noteModel
         andNoteContent:(id<NoteProtocol>) noteContent
      forCollectionName:(NSString *) collectionName
              andNoteId:(NSString *) noteId;

-(id) initWithNoteModel:(XoomlNoteModel *) noteModel
         andNoteContent:(id<NoteProtocol>) noteContent
           andImagePath:(NSString *) imagePath
      forCollectionName:(NSString *) collectionName
              andNoteId:(NSString *) noteId;
@end
