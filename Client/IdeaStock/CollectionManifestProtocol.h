//  BulletinBoardDelegate.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/1/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionNoteAttribute.h"
#import "StackingModel.h"
#import "DDXMLDocument.h"

/*
 A higher level representation of the manifest of a collection.
 manifest of a collection describes the collections and its notes
 */

@protocol CollectionManifestProtocol <NSObject>

-(void) addNoteWithID: (NSString *) ID
              andModel: (CollectionNoteAttribute *)properties;

//doesn't update the notes
-(void) addStacking:(NSString *) stackingName
          withModel:(StackingModel *)model;

-(void) addNotes:(NSArray *) noteIds
      toStacking:(NSString *) stackingName;

-(void) removeNotes:(NSArray *) noteIds
       fromStacking:(NSString *) stackingName;

-(void) deleteNote: (NSString *) noteID;

-(void) deleteStacking:(NSString *) stackingName;

-(void) deleteThumbnailForNote:(NSString *) noteId;
-(void) updateNote: (NSString *) noteID
     withNewModel: (CollectionNoteAttribute *)  noteModel;

-(void) updateStacking:(NSString *) stackingName
          withNewModel:(StackingModel *) stackingModel;

-(void) updateThumbnailWithImageOfNote:(NSString *) noteId;

- (NSDictionary *) getAllNotesBasicInfo;

- (NSDictionary *) getAllStackingsInfo;

- (NSString *) getCollectionThumbnailNoteId;

-(id) initWithData: (NSData *) data;

-(id) initAsEmpty;


- (NSData *) data;

-(DDXMLDocument *) document;

-(id) copy;
@end

