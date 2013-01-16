//
//  XoomlNoteParser.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "XoomlManifestParser.h"
#import "DDXML.h"
#import "XoomlAttributeHelper.h"

@interface XoomlManifestParser()

@end

@implementation XoomlManifestParser

#define MINDCLOUD_NAMESPACE  @"http://www.mindcloud.net/xmlns/mindcloud"
#define MINDCLOUD_SCHEMA_LOCATION @"http://www.mindcloud.net/xmlschema/mindcloud.xsd"

#define NOTE_ID  @"ID"
#define NOTE_TEXT  @"displayText"
#define NOTE_CREATION_DATE @"createdOn"
#define NOTE_MODIFICATION_DATE @"modifiedOn"

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
#define ATTRIBUTE_TOOL @"toolName"
#define ATTRIBUTE_TOOL_VERSION @"toolVersion"

#define ASSOCIATED_ITEM @"associatedItem"
#define ASSOCIATED_ICON @"associatedIcon"
#define ASSOCIATED_XOOML_FRAGMENT @"associatedXooMLFragment"
#define LEVEL_OF_SYNCHRONIZATION @"levelOfSynchronization"
#define DISPLAY_TEXT @"displayText"
#define OPEM_WITH_DEFAULT @"openWithDefault"
#define CREATED_BY @"createdBy"
#define CREATED_ON @"createdOn"
#define MODIFIED_BY @"modifiedBy"
#define MODIFIED_ON @"modifiedOn"
#define POSITION_X @"positionX"
#define POSITION_Y @"positionY"
#define IS_VISIBLE @"isVisible"

#define APP_NAME @"IdeaStock"
#define APP_VERSION @"0.1"

#define XOOML_NOTE_TOOL_ATTRIBUTE @"xooml:associationToolAttributes"
#define XOOML_BULLETINBOARD_TOOL_ATTRIBUTE @"xooml:fragmentToolAttributes"
#define ATTRIBUTE_NAME @"name"
#define NOTE_REF_ELEMENT_NAME @"is:note"
#define NOTE_POSITION_ELEMENT_NAME @"is:position"
#define REF_ID @"refID"


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
    NSString * xPath = @"//xooml:association";
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

    //TODO handle tool specific note properties by looking up the child nodes of the noteXML here
    
    //get note properties from the attributes
    CollectionNote * note = [[CollectionNote alloc] init];
    note.noteText = [[noteXML attributeForName: NOTE_TEXT] stringValue];
    note.noteTextID = [[noteXML attributeForName: NOTE_ID] stringValue];
    note.creationDate = [[noteXML attributeForName: NOTE_CREATION_DATE] stringValue];
    note.modificationDate = [[noteXML attributeForName:NOTE_MODIFICATION_DATE] stringValue];
    
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
    [root addAttribute: [DDXMLNode attributeWithName:@"xsi:schemaLocation" stringValue: XOOML_SCHEMA_LOCATION]];
    [root addAttribute: [DDXMLNode attributeWithName:@"schemaVersion" stringValue: XOOML_SCHEMA_VERSION]];
    [root addAttribute: [DDXMLNode attributeWithName:@"defaultApplication" stringValue:@""]];
    [root addAttribute: [DDXMLNode attributeWithName:@"relatedItem" stringValue:@""]];
    
    //TODO Add tool specific child of the root here 
    
    //create the association note and its attributes
    DDXMLElement * xoomlAssociation = [[DDXMLElement alloc] initWithName: XOOML_ASSOCIATION];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:NOTE_ID stringValue:note.noteTextID]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:ASSOCIATED_ITEM stringValue:note.image]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:ASSOCIATED_ICON stringValue:@""]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:ASSOCIATED_XOOML_FRAGMENT stringValue:@""]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:LEVEL_OF_SYNCHRONIZATION stringValue:@"0"]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:DISPLAY_TEXT stringValue:note.noteText]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:OPEM_WITH_DEFAULT stringValue:@""]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:CREATED_BY stringValue:APP_NAME]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:CREATED_ON stringValue:note.creationDate]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:MODIFIED_BY stringValue:APP_NAME]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:MODIFIED_ON stringValue:note.modificationDate]];

    DDXMLElement * planzHeader = [[DDXMLElement alloc] initWithName:@"xooml:fragmentToolAttributes"];
    [planzHeader addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://kftf.ischool.washington.edu/xmlns/planz"]];
    [planzHeader addAttribute:[DDXMLNode attributeWithName:@"toolVersion" stringValue:@"1.0.7"]];
    [planzHeader addAttribute:[DDXMLNode attributeWithName:@"toolName" stringValue:@"Planz"]];
    [planzHeader addAttribute:[DDXMLNode attributeWithName:@"startDate" stringValue:@"1/1/0001 12:00 AM"]];
    [planzHeader addAttribute:[DDXMLNode attributeWithName:@"dueDate" stringValue:@"1/1/0001 12:00 AM"]];
    [planzHeader addAttribute:[DDXMLNode attributeWithName:@"showAssociationMarkedDone" stringValue:@"False"]];
    [planzHeader addAttribute:[DDXMLNode attributeWithName:@"showAssociationMarkedDefer" stringValue:@"False"]];
    
    [root addChild:planzHeader];
    DDXMLElement * planzHeader2 = [[DDXMLElement alloc] initWithName:@"xooml:associationToolAttributes"];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://kftf.ischool.washington.edu/xmlns/planz"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"Note"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"associatedItemType" stringValue:@"None"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"isVisible" stringValue:@"True"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"isCollapsed" stringValue:@"True"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"status" stringValue:@"Normal"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"powerDStatus" stringValue:@"None"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"powerDTimeStamp" stringValue:@"3/28/2012 12:44 PM"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"fontColor" stringValue:@"Black"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"flagStatus" stringValue:@"Normal"]];
                                  
    //TODO Add tool specific child of the association here
    [xoomlAssociation addChild:planzHeader2];
    //Add association as a chile of root

    [root addChild:xoomlAssociation];
    
    //create the xml string by appending standard xml headers
    NSString *xmlString = [root description];
    NSString *xmlHeader = XML_HEADER;
    xmlString = [xmlHeader stringByAppendingString:xmlString];
    
    return [xmlString dataUsingEncoding:NSUTF8StringEncoding];

    
}

+(NSString *) getImageFileName: (CollectionNote *) note{
    return [note.noteTextID stringByAppendingString:@".jpg"];

}

+(NSData *) convertImageNoteToXooml:(CollectionNote *)note{
    //create the root element (xooml:fragment) and fill out its attributes
    DDXMLElement * root = [[DDXMLElement alloc] initWithName: XOOML_FRAGMENT];
    
    [root addNamespace: [DDXMLNode namespaceWithName:@"xsi" stringValue: XSI_NAMESPACE]];
    [root addNamespace: [DDXMLNode namespaceWithName:@"xooml" stringValue: XOOML_NAMESPACE]];
    [root addAttribute: [DDXMLNode attributeWithName:@"xsi:schemaLocation" stringValue: XOOML_SCHEMA_LOCATION]];
    [root addAttribute: [DDXMLNode attributeWithName:@"schemaVersion" stringValue: XOOML_SCHEMA_VERSION]];
    [root addAttribute: [DDXMLNode attributeWithName:@"defaultApplication" stringValue:@""]];
    [root addAttribute: [DDXMLNode attributeWithName:@"relatedItem" stringValue:@""]];
    
    //TODO Add tool specific child of the root here 
    
    NSString *imageName = [XoomlManifestParser getImageFileName:note];    //create the association note and its attributes
    
    DDXMLElement * xoomlAssociation = [[DDXMLElement alloc] initWithName: XOOML_ASSOCIATION];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:NOTE_ID stringValue:note.noteTextID]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:ASSOCIATED_ITEM stringValue:imageName]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:ASSOCIATED_ICON stringValue:@""]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:ASSOCIATED_XOOML_FRAGMENT stringValue:@""]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:LEVEL_OF_SYNCHRONIZATION stringValue:@"0"]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:DISPLAY_TEXT stringValue:note.noteText]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:OPEM_WITH_DEFAULT stringValue:@""]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:CREATED_BY stringValue:APP_NAME]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:CREATED_ON stringValue:note.creationDate]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:MODIFIED_BY stringValue:APP_NAME]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:MODIFIED_ON stringValue:note.modificationDate]];
    
    
    DDXMLElement * planzHeader = [[DDXMLElement alloc] initWithName:@"xooml:fragmentToolAttributes"];
    [planzHeader addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://kftf.ischool.washington.edu/xmlns/planz"]];
    [planzHeader addAttribute:[DDXMLNode attributeWithName:@"toolVersion" stringValue:@"1.0.7"]];
    [planzHeader addAttribute:[DDXMLNode attributeWithName:@"toolName" stringValue:@"Planz"]];
    [planzHeader addAttribute:[DDXMLNode attributeWithName:@"startDate" stringValue:@"1/1/0001 12:00 AM"]];
    [planzHeader addAttribute:[DDXMLNode attributeWithName:@"dueDate" stringValue:@"1/1/0001 12:00 AM"]];
    [planzHeader addAttribute:[DDXMLNode attributeWithName:@"showAssociationMarkedDone" stringValue:@"False"]];
    [planzHeader addAttribute:[DDXMLNode attributeWithName:@"showAssociationMarkedDefer" stringValue:@"False"]];
    
    [root addChild:planzHeader];
    DDXMLElement * planzHeader2 = [[DDXMLElement alloc] initWithName:@"xooml:associationToolAttributes"];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://kftf.ischool.washington.edu/xmlns/planz"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"Note"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"associatedItemType" stringValue:@"None"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"isVisible" stringValue:@"True"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"isCollapsed" stringValue:@"True"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"status" stringValue:@"Normal"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"powerDStatus" stringValue:@"None"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"powerDTimeStamp" stringValue:@"3/28/2012 12:44 PM"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"fontColor" stringValue:@"Black"]];
    [planzHeader2 addAttribute:[DDXMLNode attributeWithName:@"flagStatus" stringValue:@"Normal"]];
    
    //TODO Add tool specific child of the association here
    [xoomlAssociation addChild:planzHeader2];
    //Add association as a chile of root
    //TODO Add tool specific child of the association here
    
    //Add association as a chile of root
    [root addChild:xoomlAssociation];
    
    //create the xml string by appending standard xml headers
    NSString *xmlString = [root description];
    NSString *xmlHeader = XML_HEADER;
    xmlString = [xmlHeader stringByAppendingString:xmlString];
    
    return [xmlString dataUsingEncoding:NSUTF8StringEncoding];

}

+ (NSData *) getEmptyBulletinBoardXooml{
    //create the root element (xooml:fragment) and fill out its attributes
    
    DDXMLElement * root = [[DDXMLElement alloc] initWithName: XOOML_FRAGMENT];
    
    [root addNamespace: [DDXMLNode namespaceWithName:@"xsi" stringValue: XSI_NAMESPACE]];
    [root addNamespace: [DDXMLNode namespaceWithName:@"xooml" stringValue: XOOML_NAMESPACE]];
    [root addNamespace: [DDXMLNode namespaceWithName:@"mindcloud" stringValue: MINDCLOUD_NAMESPACE]];
    [root addAttribute: [DDXMLNode attributeWithName:@"xooml:schemaLocation" stringValue: XOOML_SCHEMA_LOCATION]];
    [root addAttribute: [DDXMLNode attributeWithName:@"mindcloud:schemaLocation" stringValue: MINDCLOUD_SCHEMA_LOCATION]];
    
    //because I can't use the method [[DDXMLDocument alloc] initWithRootElement:]
    //since its not available in KissXML , I have to provide this hack
    //Make a string from the root element add XML headers to it, convert it to
    //data and initialize the document with that NSData
    NSString *xmlString = [root description];
    NSString *xmlHeader = XML_HEADER;
    xmlString = [xmlHeader stringByAppendingString:xmlString];
    
    return [xmlString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (DDXMLElement *) xoomlForAssociationToolAttributeWithName: (NSString *) attributeName 
                                         andType: (NSString *) attributeType{
    
    DDXMLElement *element = [DDXMLNode elementWithName:XOOML_NOTE_TOOL_ATTRIBUTE];
    
    [element addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:IDEA_STOCK_NAMESPACE]];
    [element addAttribute:[DDXMLNode attributeWithName:ATTRIBUTE_ID stringValue: [XoomlAttributeHelper generateUUID]]];
    [element addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_TYPE stringValue:attributeType]];
    [element addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_NAME stringValue:attributeName]];
    [element addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_TOOL stringValue:APP_NAME]];
    [element addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_TOOL_VERSION stringValue:APP_VERSION]];
    
    return  element;
}

+ (DDXMLElement *) xoomlForAssociationToolAttributeWithType: (NSString *) attributeType{
    DDXMLElement *element = [DDXMLNode elementWithName:XOOML_NOTE_TOOL_ATTRIBUTE];
    
    [element addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:IDEA_STOCK_NAMESPACE]];
    [element addAttribute:[DDXMLNode attributeWithName:ATTRIBUTE_ID stringValue: [XoomlAttributeHelper generateUUID]]];
    [element addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_TYPE stringValue:attributeType]];
    [element addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_TOOL stringValue:APP_NAME]];
    [element addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_TOOL_VERSION stringValue:APP_VERSION]];
    
    return  element;
}

+ (DDXMLElement *) xoomlForFragmentToolAttributeWithName: (NSString *) attributeName 
                                                 andType: (NSString *) attributeType{
    
    DDXMLElement *element = [DDXMLNode elementWithName:XOOML_BULLETINBOARD_TOOL_ATTRIBUTE];
    
    [element addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:IDEA_STOCK_NAMESPACE]];
    [element addAttribute:[DDXMLNode attributeWithName:ATTRIBUTE_ID stringValue: [XoomlAttributeHelper generateUUID]]];
    [element addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_TYPE stringValue:attributeType]];
    [element addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_NAME stringValue:attributeName]];
    [element addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_TOOL stringValue:APP_NAME]];
    [element addAttribute: [DDXMLNode attributeWithName:ATTRIBUTE_TOOL_VERSION stringValue:APP_VERSION]];
    
    return  element;

    
}

+ (DDXMLElement *) xoomlForBulletinBoardNote: (NSString *) noteID 
                                 andName: (NSString *) name{
    
    //create the association note and its attributes
    DDXMLElement * xoomlAssociation = [[DDXMLElement alloc] initWithName: XOOML_ASSOCIATION];
    
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:NOTE_ID stringValue:noteID]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:ASSOCIATED_ITEM stringValue:name]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:ASSOCIATED_ICON stringValue:@""]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:ASSOCIATED_XOOML_FRAGMENT stringValue:@""]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:LEVEL_OF_SYNCHRONIZATION stringValue:@""]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:DISPLAY_TEXT stringValue:name]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:OPEM_WITH_DEFAULT stringValue:@""]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:CREATED_BY stringValue:APP_NAME]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:CREATED_ON stringValue:[XoomlAttributeHelper generateCurrentTimeForXooml]]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:MODIFIED_BY stringValue:APP_NAME]];
    [xoomlAssociation addAttribute:[DDXMLNode attributeWithName:MODIFIED_ON stringValue:[XoomlAttributeHelper generateCurrentTimeForXooml]]];
    
    return xoomlAssociation;
    
}

+ (DDXMLNode *) xoomlForNoteRef: (NSString *) refID{
    //make the note reference element
    DDXMLElement * noteRef = [DDXMLElement elementWithName:NOTE_REF_ELEMENT_NAME];
    DDXMLNode * attribute = [DDXMLElement attributeWithName:REF_ID stringValue:refID];
    [noteRef addAttribute: attribute];  
    return noteRef;
}

+ (DDXMLNode *) xoomlForNotePositionX: (NSString *) positionX
                         andPositionY: (NSString *) positionY
                       withVisibility: (NSString *) isVisible{
    //make the note property element
    //TODO maybe I need to add an ID to the is:position
    DDXMLElement * noteProperty = [DDXMLElement elementWithName:NOTE_POSITION_ELEMENT_NAME];
    [noteProperty addAttribute:[DDXMLElement attributeWithName:POSITION_X stringValue:positionX]];
    [noteProperty addAttribute:[DDXMLElement attributeWithName:POSITION_Y stringValue:positionY]];
    [noteProperty addAttribute:[DDXMLElement attributeWithName:IS_VISIBLE stringValue:isVisible]];

    return noteProperty;
    
}


/*--------------------------------------------------
 
 XooML xPath Methods 
 
 -------------------------------------------------*/

+ (NSString *) xPathforNote: (NSString *) noteID{
    return [NSString stringWithFormat:@"//xooml:association[@ID = \"%@\"]",noteID];
}

//xooml:fragmentToolAttributes[@type = "stacking" and @name="Stacking1"]
+ (NSString *) xPathForFragmentAttributeWithName: (NSString *) attributeName
                                         andType: (NSString *) attributeType{
    return [NSString stringWithFormat:@"//xooml:fragmentToolAttributes[@type = \"%@\" and @name=\"%@\"]", attributeType, attributeName];
}
////xooml:fragmentToolAttributes[@type = "stacking"]
+ (NSString *) xPathForBulletinBoardAttribute: (NSString *) attributeType{
    return [NSString stringWithFormat:@"//xooml:fragmentToolAttributes[@type = \"%@\"]", attributeType];
}

+ (NSString *) xPathForAllNotes{
    return @"//xooml:association";
}

+ (NSString *) xPathForBulletinBoard{
    return @"//xooml:fragment";
}

@end
