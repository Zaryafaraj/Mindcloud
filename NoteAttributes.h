//
//  NoteAttributes.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This class holds all the attributes of a note that does not belong to the note
 * itself but are meaningful when the note is positioned in the bulletin board.
 */
@interface NoteAttributes : NSObject

@property int positionX;
@property int positionY;

//Add a noteID to be associated with an attributeName
-(void) addNoteID:(NSString *) noteID 
 forAttributeName: (NSString *) attributeName;

//gets all the noteIDs associated for an Attribute
-(NSArray *) getAllNotesForAttributeName: (NSString *) attributeName;

- (void) removeNoteID: (NSString *) noteID 
     forAttributeName: (NSString *) attributeName;

- (void) removeAttribute: (NSString *) attributeName;


@end
