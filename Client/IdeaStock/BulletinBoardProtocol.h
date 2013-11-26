//
//  BulletinBoard.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteProtocol.h"
#import "CollectionNoteAttribute.h"
#import "CollectionStackingAttribute.h"
#import "ScreenDrawing.h"

@protocol BulletinBoardProtocol <NSObject>


@property (nonatomic,strong) NSString * bulletinBoardName;

-(void) addNoteWithContent: (id <NoteProtocol>) note
              andCollectionAttributes: (CollectionNoteAttribute *) noteModel;

-(void) addImageNoteContent:(id <NoteProtocol> )noteItem
              andModel:(CollectionNoteAttribute *) noteModel
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
                   withModel: (CollectionNoteAttribute *) noteModel;

-(void) updateStacking:(NSString *) stackingName
          withNewModel:(CollectionStackingAttribute *) stackingModel;


-(NSDictionary *) getAllNotesContents;

-(BOOL) doesNoteHaveImage:(NSString *) noteId;

-(NSData *) getImageForNote:(NSString *) noteID;

-(NSDictionary *) getAllNoteImages;

-(CollectionNoteAttribute *) getNoteModelFor: (NSString *) noteID;

-(NSArray *) getAllNoteNames;

-(CollectionStackingAttribute *) getStackModelFor:(NSString *) stackID;

-(NSDictionary *) getAllStackings;

-(NSString *) stackingForNote:(NSString *) noteId;
-(id <NoteProtocol>) getNoteContent: (NSString *) noteID;

@optional
/*
 Any bookkeeping and cleanning up needed for the bulletin board should be done here
 */
-(void) cleanUp;

-(void) saveThumbnail:(NSData *) thumbnailData;


/*! dictionary is keyed on the drawing index on the screen and the 
    serialized data of the drawing */
-(void) saveScreenDrawings:(NSDictionary *) drawingDictionary;

-(NSDictionary *) getAllScreenDrawings;


-(void) saveAllDrawings:(ScreenDrawing *) allDrawings;
/*! Sending a diff won't save the drawing anywhere, just communicates it
 with all the listeners. Use saveAllDrawings to persistently save it*/
-(void) sendDiffDrawings:(ScreenDrawing *) diffDrawings;
//downloads and gets the collection assets.
//there will be anotification sent out when each file is available
//the notification will contain the type of the asset too
-(void) getAllCollectionAssetsAsync;
+(void) saveBulletinBoard: (id) bulletinBoard;


@end
