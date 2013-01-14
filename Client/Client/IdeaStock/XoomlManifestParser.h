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

@interface XoomlManifestParser : NSObject

/*--------------------------------------------------
 
                        XooML Writing
 
 -------------------------------------------------*/

/*
 Create a note object from the contents of Xooml file
 specified in data
 */
//TODO maybe I should just return NSData * here too.
+ (CollectionNote *) xoomlNoteFromXML: (NSData *)data;


+ (DDXMLElement *) xoomlForAssociationToolAttributeWithName: (NSString *) attributeName 

                                                    andType: (NSString *) attributeType; 
/*
 Creates an empty xoomlAssociationToolAttribute without a name and 
 only a type for holding a note attribute
 */
+ (DDXMLElement *) xoomlForAssociationToolAttributeWithType: (NSString *) attributeType; 
/*
 Creates an empty xooml:fragmentToolAttributes for holding
 an attribute
 */
+ (DDXMLElement *) xoomlForFragmentToolAttributeWithName: (NSString *) attributeName 
                                                 andType: (NSString *) attributeType;

/*
 Creates a xooml association snippet for the note with noteID
 */
+ (DDXMLElement *) xoomlForBulletinBoardNote: (NSString *) noteID 
                                     andName: (NSString *) name;
/*
 Creates an note reference element. 
 */
+ (DDXMLNode *) xoomlForNoteRef: (NSString *) refID;

+ (DDXMLNode *) xoomlForNotePositionX: (NSString *) positionX
                         andPositionY: (NSString *) positionY
                       withVisibility: (NSString *) isVisible;

/*
 Converst the contents of a note object to Xooml xml data
 */
+ (NSData *) convertNoteToXooml: (CollectionNote *) note;

+ (NSString *) getImageFileName: (CollectionNote *) note;

+ (NSData *) convertImageNoteToXooml:(CollectionNote *) note;
/*
 Creates the boilerplate Xooml bulletin baord document
 and returns it as NSData
 */
+ (NSData *) getEmptyBulletinBoardXooml;

/*--------------------------------------------------
 
                    XooML xPath Methods 
 
 -------------------------------------------------*/
/*
 Returns the xPath for accessing a note with noteID
 */
+ (NSString *) xPathforNote: (NSString *) noteID;

/*
 Returns the xpath for accessing a bulletin board attribute of specified type
 */
+ (NSString *) xPathForBulletinBoardAttribute: (NSString *) attributeType;
/*
 Returns the xPath for accessing a framgment attribute with name and type
 specified. 
 */
+ (NSString *) xPathForFragmentAttributeWithName: (NSString *) attributeName
                                         andType: (NSString *) attributeType;

+ (NSString *) xPathForAllNotes;

@end
