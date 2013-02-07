//  BulletinBoardDelegate.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/1/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlNoteModel.h"
#import "XoomlStackingModel.h"

/*
 A higher level representation of the manifest of a collection.
 manifest of a collection describes the collections and its notes
 */

@protocol CollectionManifestProtocol <NSObject>

-(void) addNoteWithID: (NSString *) ID
              andModel: (XoomlNoteModel *)properties;

//doesn't update the notes
-(void) addStacking:(NSString *) stackingName
          withModel:(XoomlStackingModel *)model;

-(void) addNotes:(NSArray *) noteIds
      toStacking:(NSString *) stackingName;

-(void) removeNotes:(NSArray *) noteIds
       fromStacking:(NSString *) stackingName;

-(void) deleteNote: (NSString *) noteID;

-(void) deleteStacking:(NSString *) stackingName;

-(void) updateNote: (NSString *) noteID
     withNewModel: (XoomlNoteModel *)  noteModel;

-(void) updateStacking:(NSString *) stackingName
          withNewModel:(XoomlStackingModel *) stackingModel;

- (NSDictionary *) getAllNotesBasicInfo;

- (NSDictionary *) getAllStackingsInfo;

-(id) initWithData: (NSData *) data;

-(id) initAsEmpty;

- (NSData *) data;

@end

