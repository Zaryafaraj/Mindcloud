//
//  BulletinBoard.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"

@protocol BulletinBoard <NSObject>


@property (nonatomic,strong) NSString * bulletinBoardName;

/*
 Adds a note content to the bulletin board with a unique noteID. This noteID
 is external and differs from the ID inside the Note protocol. 
 
 The properties is a list of the properties for the note. 
 
 The required keys in this dictionary is "name" and "ID" with the value
 of a string.
 
 The optional keys in this dictionary are "positionX" and "positionY" each with the value of String 
 
 that is an integer and "isVisible" with the value of a string that is true or
 false.
 
 For example: 
 {name="Note4", ID="NoteID4", positionX= "100", positionY = "150", isVisible="true"}

 The method raises an exception if any of these info is miising. 
 */
-(void) addNoteContent: (id <Note>) note
         andProperties: (NSDictionary *) properties;

-(void) addImageNoteContent:(id <Note> )noteItem
              andProperties:noteProperties
                   andImage: (NSData *) img;

/*
 Adds an attribute with AttributeName and AttributeType for a particular note specified by note ID. The values specified in the values array will be avalues of this attribute.
 
 A note attribute defines a particular relationship that a note has with a number of other notes.
 
 If the noteID is not a valid noteID whose its noteContent has been stored; this method simply returns without doing anything. 

 It is up to the implementation to only allow a fixed set of attribute type or allow variable dynamic attribute types.
 */

-(void) addNoteAttribute: (NSString *) attributeName
         forAttributeType: (NSString *) attributeType
                  forNote: (NSString *) noteID 
                andValues:(NSArray *)values;
/*
 Adds note with targetNoteID to an attribute of note with sourceNoteID. The attribute has attributeName and is of type attributeType. 
 
 If the note attribute type does not exist or the any of the noteIDs are not a valid noteID whose noteContents have been stored; this method simply returns without doing anything.
 
 If the note Attribute with the given attributeName does not exist then the method
 creates the attributeName for the noteID and adds sourceNoteID to it
 */

-(void) addNote: (NSString *) targetNoteID
 toAttributeName: (NSString *) attributeName
forAttributeType: (NSString *) attributeType
          ofNote: (NSString *) sourceNoteId;

/*
 Adds an attribute of Type attributeType and the name attributeName to the bulletin board. 
 
 A bulletin board attribute involves a number of notes that relate to each other. 
 
 It is up to the implementation to only allow a fixed set of attribute type or allow variable dynamic attribute types.
 */
-(void) addBulletinBoardAttribute: (NSString *) attributeName
                  forAttributeType: (NSString *) attributeType;

/*
 Adds a note with noteID to the bulletin board attribute with attributeName and of type attributeType. 
 
 //the following may be wrong
 If the attribute with the given type does not exist or the noteID is not a valid noteID whose noteContent has been stored; this method simply returns without doing anything.
 
 If the attributeName does not exist. The method creates it and addes the noteID to it. 
 */
-(void) addNoteWithID: (NSString *) noteID
toBulletinBoardAttribute: (NSString *) attributeName
      forAttributeType: (NSString *) attributeType;


/*
 This method removed the note including its content and also updated all the bulletinboard and note specific attributes that the note participated in to reflect that deletion. 
 
 If a noteContent with the ID noteID does not exists, methods reutnrs without doing 
 anything. 
 */
-(void) removeNoteWithID: (NSString *) noteID;

/*
 Removes the note with targetNoteID from an attribute of a note with sourceNoteID. The attribute is specified by its name and type in attributeName and attributeType. 
 
 This method only removes the note if the attributeName, attributeType, targetNoteID, and sourceNoteID are valid and targetNoteID has been previously added to sourceNoteID attributes. Otherwise the methods returns without doing anything.
 
 */
-(void) removeNote: (NSString *) targetNoteID
      fromAttribute: (NSString *) attributeName
             ofType: (NSString *) attributeType
   fromAttributesOf: (NSString *) sourceNoteID;

/*
 Removes a note attribute with name attributeName and tpe attribtueType from note with NoteID's attribute lists. 
 
 As a result any note that was involved in that attribute will no longer be part of the attribute. 
 
 This method acts only if attributeName, attributeType, and noteID are valid. Otherwise, the method returns without doing anything.
 */

-(void) removeNoteAttribute: (NSString *) attributeName
                      ofType: (NSString *) attributeType
                    FromNote: (NSString *) noteID;

/*
 Removes a note with noteID from bulletin board attribute with name attributeName and the type attribute Type. 
 
 This method only acts when noteID, attributeName, and attributeType are valid and noteID actually belongs to the bulletinboard with attributeName and the type attributeType. Otherwise, this method returns without doing anything .
 */
-(void) removeNote: (NSString *) noteID
fromBulletinBoardAttribute: (NSString *) attributeName 
             ofType: (NSString *) attributeType;

/*
 removes the bulletin board attribute with the name attributeName and the type attributeType. 
 Any noteIDs that belong to that attributeName will no longer belong to the attribute. 
 
 This method only functions if attributeName and attributeType are valid existing attribtueNames. Otherwise it returns without doing anything. 
 */
-(void) removeBulletinBoardAttribute: (NSString *) attributeName
                               ofType: (NSString *) attributeType;

/*
 Updates the contenst of a note with noteID with the contents of newNote.
 
 Any values that are null in the newNote won't be updated. In other words, newNote only contains the values that need updating. 
 
 This method only functions if noteID is valid ID of a note content. Otherwise it returns without doing anything. 
 */

-(void) updateNoteContentOf: (NSString *) noteID
              withContentsOf: (id <Note>) newNote;

/*
 Changes the name of a note attribute with type attributeType for the note with NoteID from oldAttributeName to newAttributeName. 
 
 If oldAttributeName, attributeType, noteID are not valid the method returns without doing anything. 
 */

-(void) renameNoteAttribute: (NSString *) oldAttributeName
                      ofType: (NSString *) attributeType
                     forNote: (NSString *) noteID 
                    withName: (NSString *) newAttributeName;

/*
 Updates the value of the of a note attribute with name and type attributeName and attributeType
 for the note with noteID with an array of newValues. 
 
 This is just a convinience method and acts as a replacement that is done by removing the attribute
 with name and type and adding it again with new values. 
 */
-(void) updateNoteAttribute: (NSString *) attributeName
                     ofType:(NSString *) attributeType 
                    forNote: (NSString *) noteID 
              withNewValues: (NSArray *) newValues;

/*
 Changes the name of a bulletin board attribute with type attributeType from oldAttributeName to newAttributeName. 
 
 If oldAttributeName and attributeType are not valid, the method returns without doing anything.
 */
-(void) renameBulletinBoardAttribute: (NSString *) oldAttributeNAme
                               ofType: (NSString *) attributeType 
                             withName: (NSString *) newAttributeName;


-(void) updateNoteAttributes: (NSString *) noteID
              withAttributes: (NSDictionary *) newProperties;

/*
 Returns a copy of all the note contents in the bulletin board. 
 The returned dictionary is a dictionary of objects that is keyed on
 noteIds. The values for these keys are objects that follow the note
 protocol.
 */
-(NSDictionary *) getAllNotes;

-(NSDictionary *) getAllNoteImages;

/*
 Returns an array of strings containing the name of all the attributes of type attributeType in the bulletin board. 
 */
-(NSDictionary *) getAllNoteAttributesForNote: (NSString *) noteID;

-(NSDictionary *) getAllBulletinBoardAttributeNamesOfType: (NSString *) attributeType;

/*
 Returns an array of strings containing the name of all the attributes of type attributeType in the attribute list of note with noteID. 
 */
-(NSDictionary *) getAllNoteAttributeNamesOfType: (NSString *) attributeType
                            forNote: (NSString *) noteID;

/*
 Returns the note contents of a note with noteID. 
 */
-(id <Note>) getNoteContent: (NSString *) noteID;

/*
 Returns an array of noteIDs belonging to the attribute with attributeName and the type attributeType for the bulletin board. 
 */
-(NSArray *) getAllNotesBelongingToBulletinBoardAttribute: (NSString *) attributeName
                                          forAttributeType: (NSString *) attributeType;

/*
 Returns an array of NoteIDs belonging to the attribute with attribueName and the type attributeType for the note with noteID. 
 */
-(NSArray *) getAllNotesBelongtingToNoteAttribute: (NSString *) attributeName
                                   ofAttributeType: (NSString *) attributeType
                                           forNote: (NSString *) noteID;

@optional
/*
 Any bookkeeping and cleanning up needed for the bulletin board should be done here
 */
-(void) cleanUp;

+ (void) saveBulletinBoard: (id) bulletinBoard;

@end
