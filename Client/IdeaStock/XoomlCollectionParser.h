//
//  XoomlNoteParser.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionNote.h"
#import "MindcloudCollection.h"
#import "CachedCollectionAttributes.h"
#import "DDXML.h"

/*
 This is helper that handles parsing and working 
 with Xooml syntax
 */

@interface XoomlCollectionParser : NSObject

/*
 Create a note object from the contents of Xooml file
 specified in data
 */
//TODO maybe I should just return NSData * here too.
+ (CollectionNote *) xoomlNoteFromXML: (NSData *)data;

/*
 Converst the contents of a note object to Xooml xml data
 */
//These two probably deserve their own files
+ (NSData *) convertNoteToXooml: (CollectionNote *) note;

/*
 Gets the reference to an image as it appears in the note
 */
+ (NSString *) getXoomlImageReference: (CollectionNote *) note;

+ (NSData *) convertImageNoteToXooml:(CollectionNote *) note;

/*
 Creates the boilerplate Xooml bulletin baord document
 and returns it as NSData
 */
+ (NSData *) getEmptyCollectionXooml;

/*
 Xooml for a note attribute as it appears in the manifest
 */
+ (DDXMLElement *) xoomlForCollectionNoteAttributeWithName: (NSString *) attributeName 
                                                    andType: (NSString *) attributeType;
+ (DDXMLElement *) xoomlForCollectionNoteAttributeWithType: (NSString *) attributeType;

/*
 Convinient method for creating collection note attribute of position
 */
+ (DDXMLNode *) xoomlForNotePositionX: (NSString *) positionX
                         andPositionY: (NSString *) positionY
                       withVisibility: (NSString *) isVisible;
/*
 Xooml for an attribtue related to a collection as it appears in the manifest
 */
+ (DDXMLElement *) xoomlForCollectionAttributeWithName: (NSString *) attributeName 
                                                 andType: (NSString *) attributeType;

/*
 Xooml for a note reference as it appears in the manifest
 */
+ (DDXMLElement *) xoomlForCollectionNote: (NSString *) noteID 
                                     andName: (NSString *) name;
/*
 Creates an note reference element to be used in the manifest
 */
+ (DDXMLNode *) xoomlForNoteRef: (NSString *) refID;


/*
 Returns the xPath for accessing a note with noteID
 */
+ (NSString *) xPathforNote: (NSString *) noteID;

/*
 Returns the xpath for accessing a bulletin board attribute of specified type
 */
+ (NSString *) xPathForCollectionAttribute: (NSString *) attributeType;
/*
 for accessing a collection attribute element
 */
+ (NSString *) xPathForCollectionAttributeWithName: (NSString *) attributeName
                                         andType: (NSString *) attributeType;

+ (NSString *) xPathForAllNotes;

@end
