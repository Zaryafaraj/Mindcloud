//
//  DataModel.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulletinBoardProtocol.h"
#import "NoteProtocol.h"

/**
 * The protocol for the datamodel. Includes essential behaviors for working 
 with bulletin boards and notes. 
 */
@protocol MindcloudDataSource <NSObject>


/*
 Adds one note with name noteName and content note to the bulletinBoard
 with bulletinBoardName
 
 If the bulletinBoard specified by bulletinBoard does not exist, the method
 returns without doing anything. 
 
 This method assumes that the content passed to it as NSData is verified 
 and is valid.
 */

- (void) addNote: (NSString *)noteName 
     withContent: (NSData *) note 
 ToCollection: (NSString *) collectionName;

-(void) addImageNote: (NSString *) noteName
     withNoteContent: (NSData *) note 
            andImage: (NSData *) img 
   withImageFileName: (NSString *)imgName
     toCollection: (NSString *) collectionName;
/*
 Updates the bulletinboard with name with the given content
 
 The method assumes that the bulletinboard with the name exists. 
 If the bulletinboard does not exist an error should be occured. 
 
 The method replaces the bulletinboard info with the new one. 
 */
-(void) updateCollectionWithName: (NSString *) collectionName
               andContent: (NSData *) content;

/*
 Updates a given note with noteName with the content. 
 
 The note assumes that the noteName and bulletinBoardName already exist.
 If they don't exist an error will occure. 
 
 The method replaces the old note content with the new one. 
 */
-(void) updateNote: (NSString *) noteName 
       withContent: (NSData *) conetent
   inCollection:(NSString *) collectionName;
/*
 Removes a note with noteName from the bulletin board with bulletinBoardName.
 
If the boardName or noteName are invalid the method returns without doing anything.
 
 This method is not responsible for deletion of the individual note data structures
 in the application. 
 */
- (void) removeNote: (NSString *) noteName
  FromCollection: (NSString *) collectionName;

/*
 Return a NSData object with the contents of the stored bulletinBoard for
 the bulletinBoardName. 
 
 In case of any error in storage or retrieval the method returns nil.
 
 The method does not gurantee the NSData returned is a valid bulletin board data. 
 */
- (NSData *) getCollection: (NSString *) collectionName;
/*
 Gets the note contents for the passed bulletin board name and noteName.
 Returns an NSData containing the data for the note. 
 
 If the bulletin board and the noteName are not valid the method returns
 nil without doing anything. 
 
 The method does not gurantee the NSData returned is a valid note data. 
 */
- (NSData *) getNoteForTheCollection: (NSString *) collectionName
                                   WithName: (NSString *) noteName;


- (NSData *) getImageForNote: (NSString *)noteID 
            andCollection: (NSString *) bulletinBoardName;


-(NSArray *) getAllCollections;

-(void) addCollectionWithName:(NSString *) collectionName;

-(void) renameCollectionWithName:(NSString *) collectionName
                              to:(NSString *) newCollectionName;

-(void) deleteCollectionFor:(NSString *) collectionName;

-(NSDictionary *) getCategories;

-(void) saveCategories:(NSData *) categoriesData;

-(NSData *) getThumbnailForCollection:(NSString *) collectionName;

-(void) setThumbnail:(NSData *)thumbnailData
          forCollection:(NSString *)collectionName;

@end