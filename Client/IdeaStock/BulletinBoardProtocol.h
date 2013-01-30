//
//  BulletinBoard.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteProtocol.h"
#import "XoomlNoteModel.h"
#import "XoomlStackingModel.h"

@protocol BulletinBoardProtocol <NSObject>


@property (nonatomic,strong) NSString * bulletinBoardName;

-(void) addNoteContent: (id <NoteProtocol>) note
              andModel: (XoomlNoteModel *) noteModel forNoteWithID:(NSString *) noteId;

-(void) addImageNoteContent:(id <NoteProtocol> )noteItem
              andModel:(XoomlNoteModel *) noteModel
                   andImage: (NSData *) img
                    forNote:(NSString *) noteId;

-(void) addNotesWithIDs: (NSArray *) noteIDs
             toStacking:(NSString *) stackingName;

-(void) removeNoteWithID: (NSString *) noteID;

-(void) removeNote:(NSString *) noteId
      fromStacking:(NSString *) stackingName;

-(void) removeStacking:(NSString *) stackingName;

-(void) updateNoteContentOf: (NSString *) noteID
              withContentsOf: (id <NoteProtocol>) newNote;

-(void) updateNoteAttributes: (NSString *) noteID
                   withModel: (XoomlNoteModel *) noteModel;

-(void) updateStacking:(NSString *) stackingName
          withNewModel:(XoomlStackingModel *) stackingModel;


-(NSDictionary *) getAllNotesContents;

-(NSDictionary *) getAllNoteImages;

-(XoomlNoteModel *) getNoteModelFor: (NSString *) noteID;

-(NSDictionary *) getAllStackings;

-(id <NoteProtocol>) getNoteContent: (NSString *) noteID;

@optional
/*
 Any bookkeeping and cleanning up needed for the bulletin board should be done here
 */
-(void) cleanUp;

-(void) saveThumbnail:(NSData *) thumbnailData;

+ (void) saveBulletinBoard: (id) bulletinBoard;


@end
