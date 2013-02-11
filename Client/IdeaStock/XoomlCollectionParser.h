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
#import "DDXML.h"

#define MINDCLOUD_NAMESPACE  @"http://www.mindcloud.net/xmlns/mindcloud"
#define MINDCLOUD_SCHEMA_LOCATION @"http://www.mindcloud.net/xmlschema/mindcloud.xsd"
#define MINDCLOUD_COLLECTION_ATTRIBUTE @"mindcloud:collectionAttribute"
#define MINDCLOUD_NOTE_ATTRIBUTE @"mindcloud:noteAttribute"
#define MINDCLOUD_REFERENCE @"mindcloud:reference"
#define MINDCLOUD_NOTE_POSITION_ATTRIBUTE_TYPE @"position"
#define MINDCLOUD_NOTE_SCALE_ATTRIBUTE_TYPE @"scale"
#define MINDCLOUD_COLLECTION_THUMBNAIL @"mindcloud:thumbnail"
#define NOTE_ID  @"ID"
#define NOTE_TEXT  @"displayName"

#define XML_HEADER @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
#define XSI_NAMESPACE @"http://www.w3.org/2001/XMLSchema-instance"
#define XOOML_NAMESPACE @"http://kftf.ischool.washington.edu/xmlns/xooml"
#define IDEA_STOCK_NAMESPACE @"http://ischool.uw.edu/xmlns/ideastock"
#define XOOML_SCHEMA_LOCATION @"http://kftf.ischool.washington.edu/xmlns/xooml http://kftf.ischool.washington.edu/XMLschema/0.41/XooML.xsd"
#define XOOML_SCHEMA_VERSION @"0.41"

#define XOOML_FRAGMENT @"xooml:fragment"
#define XOOML_ASSOCIATION @"xooml:association"

#define ATTRIBUTE_ID @"ID"
#define ATTRIBUTE_TYPE @"type"
#define ATTRIBUTE_NAME @"name"

#define ASSOCIATED_ITEM @"associatedXoomlFragment"
#define ASSOCIATED_XOOML_FRAGMENT @"associatedXoomlFragment"
#define POSITION_X @"positionX"
#define POSITION_Y @"positionY"
#define SCALING @"scale"

#define FRAGMENT_NAMESPACE_DATA @"xooml:fragmentNamespaceData"
#define ASSOCIATION_NAMESPACE_DATA @"xooml:associationNamespaceData"
#define REF_ID @"refID"

#define LINKAGE_TYPE @"linkage"
#define STACKING_TYPE @"stacking"
#define GROUPING_TYPE @"grouping"
#define NOTE_NAME_KEY @"name"
#define NOTE_IS_VISIBLE @"isVisible"
#define NOTE_LINKAGE_KEY @"linkage"
#define POSITION_TYPE @"position"
#define SCALING_TYPE @"scale"
#define XOOML_IS_VISIBLE @"isVisible"
#define XOOML_NOTE_NAME @"associatedXoomlFragment"

#pragma mark - Note.xml
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

+ (DDXMLNode *) xoomlForNoteScale:(NSString *) scale;
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
 Creates the container that holds mindcloud specific properties for xooml
 */
+ (DDXMLElement * ) xoomlForNoteAttributeContainer;

+ (DDXMLElement *) xoomlForThumbnailWithNoteRef:(NSString *) noteId;
/*
 Returns the xPath for accessing a note with noteID
 */
+ (NSString *) xPathforNote: (NSString *) noteID;

/*
 for accessing a collection attribute element
 */

+ (NSString *) xPathForAllNotes;

+ (NSString *) xPathForCollectionAttributeContainer;

+ (NSString *) xPathForThumbnail;

@end
