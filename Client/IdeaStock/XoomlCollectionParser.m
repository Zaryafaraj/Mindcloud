//
//  XoomlNoteParser.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "XoomlCollectionParser.h"
#import "DDXML.h"
#import "XoomlAttributeHelper.h"

@interface XoomlCollectionParser()

@end

@implementation XoomlCollectionParser

#define MINDCLOUD_NAMESPACE  @"http://www.mindcloud.net/xmlns/mindcloud"
#define MINDCLOUD_SCHEMA_LOCATION @"http://www.mindcloud.net/xmlschema/mindcloud.xsd"
#define MINDCLOUD_COLLECTION_ATTRIBUTE @"mindcloud:collectionAttribute"
#define MINDCLOUD_NOTE_ATTRIBUTE @"mindcloud:noteAttribute"
#define MINDCLOUD_REFERENCE @"mindcloud:reference"
#define MINDCLOUD_NOTE_POSITION_ATTRIBUTE_TYPE @"position"
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

#define ASSOCIATED_ITEM @"aassociatedXooMLFragment"
#define ASSOCIATED_XOOML_FRAGMENT @"associatedXoomlFragment"
#define POSITION_X @"positionX"
#define POSITION_Y @"positionY"

#define FRAGMENT_NAMESPACE_DATA @"xooml:fragmentNamespaceData"
#define ASSOCIATION_NAMESPACE_DATA @"xooml:associationNamespaceData"
#define REF_ID @"refID"

#pragma mark - Note.xml
+ (CollectionNote *) xoomlNoteFromXML:(NSData *)data{
    
    //open the XML document
    NSError *err = nil;
    DDXMLDocument * document = [[DDXMLDocument alloc] initWithData:data options:0 error:&err];
    
    //TODO right now im ignoring err. I should use it 
    //to determine the error
    if (document == nil){
        NSLog(@"Error reading the note XML File");
        return nil;
    }
    
    //get the note fragment using xpath
    NSString * xPath = @"/xooml:fragment/xooml:association";
    NSArray *notes = [document nodesForXPath: xPath error: &err];
    if (notes == nil){
        NSLog(@"Error reading the content from XML");
        return nil;
    }
    if ([notes count] == 0 ){
        NSLog(@"No Note Content exist for the given note");
        return nil;
    }

    DDXMLElement * noteXML = (DDXMLElement *)notes[0];

    CollectionNote * note = [[CollectionNote alloc] init];
    note.noteText = [[noteXML attributeForName: NOTE_TEXT] stringValue];
    note.noteTextID = [[noteXML attributeForName: NOTE_ID] stringValue];
    
    NSString * imagePath = [[noteXML attributeForName:ASSOCIATED_ITEM] stringValue];
    if (imagePath != nil && ![imagePath isEqualToString:@""]){
        note.image = imagePath;
    }
    return note;
}

+ (NSData *) convertNoteToXooml: (CollectionNote *) note{
    
    //create the root element (xooml:fragment) and fill out its attributes
    DDXMLElement * root = [[DDXMLElement alloc] initWithName: XOOML_FRAGMENT];
    
    [root addNamespace: [DDXMLNode namespaceWithName:@"xsi" stringValue: XSI_NAMESPACE]];
    [root addNamespace: [DDXMLNode namespaceWithName:@"xooml" stringValue: XOOML_NAMESPACE]];
    [root addNamespace: [DDXMLNode namespaceWithName:@"mindcloud" stringValue: MINDCLOUD_NAMESPACE]];
    [root addAttribute: [DDXMLNode attributeWithName:@"xooml:schemaLocation" stringValue: XOOML_SCHEMA_LOCATION]];
    [root addAttribute: [DDXMLNode attributeWithName:@"mindcloud:schemaLocation" stringValue: MINDCLOUD_SCHEMA_LOCATION]];
    
    //create the association note and its attributes
    DDXMLElement * xoomlAssociation = [[DDXMLElement alloc] initWithName: XOOML_ASSOCIATION];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:NOTE_ID stringValue:note.noteTextID]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:NOTE_TEXT stringValue:note.noteText]];

    [root addChild:xoomlAssociation];
    
    //create the xml string by appending standard xml headers
    NSString *xmlString = [root description];
    NSString *xmlHeader = XML_HEADER;
    xmlString = [xmlHeader stringByAppendingString:xmlString];
    
    return [xmlString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *) getXoomlImageReference: (CollectionNote *) note
{
    return [note.noteTextID stringByAppendingString:@".jpg"];
}

+(NSData *) convertImageNoteToXooml:(CollectionNote *)note{
    
    DDXMLElement * root = [[DDXMLElement alloc] initWithName: XOOML_FRAGMENT];
    
    [root addNamespace: [DDXMLNode namespaceWithName:@"xsi" stringValue: XSI_NAMESPACE]];
    [root addNamespace: [DDXMLNode namespaceWithName:@"xooml" stringValue: XOOML_NAMESPACE]];
    [root addNamespace: [DDXMLNode namespaceWithName:@"mindcloud" stringValue: MINDCLOUD_NAMESPACE]];
    [root addAttribute: [DDXMLNode attributeWithName:@"xooml:schemaLocation" stringValue: XOOML_SCHEMA_LOCATION]];
    [root addAttribute: [DDXMLNode attributeWithName:@"mindcloud:schemaLocation" stringValue: MINDCLOUD_SCHEMA_LOCATION]];
    
    NSString *imageName = [XoomlCollectionParser getXoomlImageReference:note];    //create the association note and its attributes
    
    
    DDXMLElement * xoomlAssociation = [[DDXMLElement alloc] initWithName: XOOML_ASSOCIATION];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:NOTE_ID stringValue:note.noteTextID]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:NOTE_TEXT stringValue:note.noteText]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:ASSOCIATED_ITEM stringValue:imageName]];
    
    [root addChild:xoomlAssociation];
    
    //create the xml string by appending standard xml headers
    NSString *xmlString = [root description];
    NSString *xmlHeader = XML_HEADER;
    xmlString = [xmlHeader stringByAppendingString:xmlString];
    
    return [xmlString dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Collection.xml

+ (NSData *) getEmptyCollectionXooml{
    //create the root element (xooml:fragment) and fill out its attributes
    
    DDXMLElement * root = [[DDXMLElement alloc] initWithName: XOOML_FRAGMENT];
    
    [root addNamespace: [DDXMLNode namespaceWithName:@"xsi" stringValue: XSI_NAMESPACE]];
    [root addNamespace: [DDXMLNode namespaceWithName:@"xooml" stringValue: XOOML_NAMESPACE]];
    [root addNamespace: [DDXMLNode namespaceWithName:@"mindcloud" stringValue: MINDCLOUD_NAMESPACE]];
    [root addAttribute: [DDXMLNode attributeWithName:@"xooml:schemaLocation" stringValue: XOOML_SCHEMA_LOCATION]];
    [root addAttribute: [DDXMLNode attributeWithName:@"mindcloud:schemaLocation" stringValue: MINDCLOUD_SCHEMA_LOCATION]];
    DDXMLElement * collectionAttributeContainer = [[DDXMLElement alloc] initWithName: FRAGMENT_NAMESPACE_DATA];
    [root addChild:collectionAttributeContainer];
    
    NSString *xmlString = [root description];
    NSString *xmlHeader = XML_HEADER;
    xmlString = [xmlHeader stringByAppendingString:xmlString];
    
    return [xmlString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (DDXMLElement *) xoomlForCollectionNoteAttributeWithName: (NSString *) attributeName
                                                    andType: (NSString *) attributeType
{
    DDXMLElement * attributeRoot = [DDXMLNode elementWithName:MINDCLOUD_NOTE_ATTRIBUTE];
    
    [attributeRoot addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_ID stringValue: [XoomlAttributeHelper generateUUID]]];
    [attributeRoot addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_TYPE stringValue:attributeType]];
    [attributeRoot addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_NAME stringValue:attributeName]];
    return  attributeRoot;
}

+ (DDXMLElement *) xoomlForCollectionNoteAttributeWithType: (NSString *) attributeType
{
    
    DDXMLElement * attributeRoot = [DDXMLNode elementWithName:MINDCLOUD_NOTE_ATTRIBUTE];
    
    [attributeRoot addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_ID stringValue: [XoomlAttributeHelper generateUUID]]];
    [attributeRoot addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_TYPE stringValue:attributeType]];
    return  attributeRoot;
}

+ (DDXMLElement *) xoomlForCollectionAttributeWithName: (NSString *) attributeName 
                                                 andType: (NSString *) attributeType
{
    
    DDXMLElement * attributeRoot = [DDXMLNode elementWithName:MINDCLOUD_COLLECTION_ATTRIBUTE];
    
    [attributeRoot addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_ID stringValue: [XoomlAttributeHelper generateUUID]]];
    [attributeRoot addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_TYPE stringValue:attributeType]];
    [attributeRoot addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_NAME stringValue:attributeName]];
    return  attributeRoot;
}

+ (DDXMLElement *) xoomlForCollectionNote: (NSString *) noteID 
                                 andName: (NSString *) name
{
    
    //create the association note and its attributes
    DDXMLElement * xoomlAssociation = [[DDXMLElement alloc] initWithName: XOOML_ASSOCIATION];
    
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:NOTE_ID stringValue:noteID]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:ASSOCIATED_ITEM stringValue:name]];
    
    return xoomlAssociation;
}

+ (DDXMLNode *) xoomlForNoteRef: (NSString *) refID
{
    //make the note reference element
    DDXMLElement * noteRef = [DDXMLElement elementWithName:MINDCLOUD_REFERENCE];
    DDXMLNode * attribute = [DDXMLElement attributeWithName:REF_ID stringValue:refID];
    [noteRef addAttribute: attribute];  
    return noteRef;
}

+ (DDXMLElement * ) xoomlForNoteAttributeContainer
{
    DDXMLElement * xoomlAssociationNamespace = [[DDXMLElement alloc] initWithName: ASSOCIATION_NAMESPACE_DATA];
    return xoomlAssociationNamespace;
}

+ (DDXMLNode *) xoomlForNotePositionX: (NSString *) positionX
                         andPositionY: (NSString *) positionY
                       withVisibility: (NSString *) isVisible{
    //ignore visibility for now
    DDXMLElement * standardAttribute = [self xoomlForCollectionNoteAttributeWithType:MINDCLOUD_NOTE_POSITION_ATTRIBUTE_TYPE];
    [standardAttribute addAttribute:[DDXMLNode attributeWithName:POSITION_X stringValue:positionX]];
    [standardAttribute addAttribute:[DDXMLNode attributeWithName:POSITION_Y stringValue:positionY]];
    return standardAttribute;
}

#pragma mark - XPaths
+ (NSString *) xPathforNote: (NSString *) noteID{
    return [NSString stringWithFormat:@"/xooml:fragment/xooml:association[@ID = \"%@\"]",noteID];
}

//xooml:fragmentToolAttributes[@type = "stacking" and @name="Stacking1"]
+ (NSString *) xPathForCollectionAttributeWithName: (NSString *) attributeName
                                         andType: (NSString *) attributeType;
{
    return [NSString stringWithFormat:@"/xooml:fragment/xooml:fragmentNamespaceData/mindcloud:collectionAttribute[@type = \"%@\" and @name=\"%@\"]", attributeType, attributeName];
}
////xooml:fragmentToolAttributes[@type = "stacking"]
+ (NSString *) xPathForCollectionAttribute: (NSString *) attributeType{
    return [NSString stringWithFormat:@"/xooml:fragment/xooml:fragmentNamespaceData/mindcloud:collectionAttribute[@type = \"%@\"]", attributeType];
}

+ (NSString *) xPathForAllNotes{
    return @"/xooml:fragment/xooml:association";
}

+ (NSString *) xPathForBulletinBoard{
    return @"/xooml:fragment";
}

+ (NSString *) xPathForCollectionAttributeContainer
{
    return @"/xooml:fragment/xooml:fragmentNamespaceData";
}

@end

