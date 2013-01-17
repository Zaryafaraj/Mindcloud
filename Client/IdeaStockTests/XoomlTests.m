//
//  XoomlTests.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/29/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "XoomlTests.h"
#import "XoomlAttributeHelper.h"
#import "XoomlCollectionParser.h"

@implementation XoomlTests

NSData * xml;

- (void)setUp
{

    [super setUp];
    //TODO read these from a file 
    NSString * xmlString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?> <xooml:fragment xsi:schemaLocation=\"http://kftf.ischool.washington.edu/xmlns/xooml http://kftf.ischool.washington.edu/XMLschema/0.41/XooML.xsd\" schemaVersion=\"0.41\" defaultApplication=\"\" relatedItem=\"C:\\Users\\Zoso\\Projects\\0c8966ef-0571-4935-b931-5bca1818bed6\\\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xooml=\"http://kftf.ischool.washington.edu/xmlns/xooml\"> <xooml:fragmentToolAttributes xmlns=\"http://kftf.ischool.washington.edu/xmlns/planz\" toolVersion=\"1.0.7\" toolName=\"Planz\" startDate=\"1/1/0001 12:00 AM\" dueDate=\"1/1/0001 12:00 AM\" showAssociationMarkedDone=\"False\" showAssociationMarkedDefer=\"False\" /> <xooml:association ID=\"074fddec-fb84-46bf-839c-9e859675b1d3\" associatedItem=\"\" associatedIcon=\"\" associatedXooMLFragment=\"\" levelOfSynchronization=\"0\" displayText=\"Note1Text1\" openWithDefault=\"\" createdBy=\"planz\" createdOn=\"3/28/2012 12:43 PM\" modifiedBy=\"\" modifiedOn=\"3/28/2012 12:44 PM\"> <xooml:associationToolAttributes xmlns=\"http://kftf.ischool.washington.edu/xmlns/planz\" type=\"Note\" associatedItemType=\"None\" isVisible=\"True\" isCollapsed=\"True\" status=\"Normal\" powerDStatus=\"None\" powerDTimeStamp=\"3/28/2012 12:43 PM\" fontColor=\"Black\" flagStatus=\"Normal\" /> </xooml:association> </xooml:fragment>";
    xml = [ xmlString dataUsingEncoding:NSUTF8StringEncoding];
    
}



- (void)testNoteCreate
{
    CollectionNote * note =  [XoomlCollectionParser xoomlNoteFromXML:xml];
    NSString * noteText = note.noteText;
    NSString * noteID = note.noteTextID;
    NSString * noteCreationDate = note.creationDate;
    NSString * noteModificationDate = note.modificationDate;
    STAssertEqualObjects(@"Note1Text1", noteText, @"Note Text Value does not match the note text in the XML file");
    STAssertEqualObjects(@"074fddec-fb84-46bf-839c-9e859675b1d3", noteID, @"Note ID does not match the note ID in the XML file");
    STAssertEqualObjects(@"3/28/2012 12:43 PM", noteCreationDate, @"Note creation date does not match the note creation date in the XML file");
    STAssertEqualObjects(@"3/28/2012 12:44 PM", noteModificationDate, @"Note modification date does not match the note modification date in the XML file");
    
}

-(void) testNoteCreateEmptyXMLParam
{
    //The only difference is that the displaytext is empty
    NSString * xmlString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?> <xooml:fragment xsi:schemaLocation=\"http://kftf.ischool.washington.edu/xmlns/xooml http://kftf.ischool.washington.edu/XMLschema/0.41/XooML.xsd\" schemaVersion=\"0.41\" defaultApplication=\"\" relatedItem=\"C:\\Users\\Zoso\\Projects\\0c8966ef-0571-4935-b931-5bca1818bed6\\\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xooml=\"http://kftf.ischool.washington.edu/xmlns/xooml\"> <xooml:fragmentToolAttributes xmlns=\"http://kftf.ischool.washington.edu/xmlns/planz\" toolVersion=\"1.0.7\" toolName=\"Planz\" startDate=\"1/1/0001 12:00 AM\" dueDate=\"1/1/0001 12:00 AM\" showAssociationMarkedDone=\"False\" showAssociationMarkedDefer=\"False\" /> <xooml:association ID=\"074fddec-fb84-46bf-839c-9e859675b1d3\" associatedItem=\"\" associatedIcon=\"\" associatedXooMLFragment=\"\" levelOfSynchronization=\"0\" displayText=\"\" openWithDefault=\"\" createdBy=\"planz\" createdOn=\"3/28/2012 12:43 PM\" modifiedBy=\"\" modifiedOn=\"3/28/2012 12:44 PM\"> <xooml:associationToolAttributes xmlns=\"http://kftf.ischool.washington.edu/xmlns/planz\" type=\"Note\" associatedItemType=\"None\" isVisible=\"True\" isCollapsed=\"True\" status=\"Normal\" powerDStatus=\"None\" powerDTimeStamp=\"3/28/2012 12:43 PM\" fontColor=\"Black\" flagStatus=\"Normal\" /> </xooml:association> </xooml:fragment>";
    xml = [ xmlString dataUsingEncoding:NSUTF8StringEncoding];
    CollectionNote * note =  [XoomlCollectionParser xoomlNoteFromXML:xml];
    NSString * noteText = note.noteText;
    STAssertEqualObjects(@"", noteText, @"Note Text Value does not match the note text in the XML file");
    
}

- (void) testXoomlCreationFromNote
{
    CollectionNote * actualNote = [[CollectionNote alloc] initWithCreationDate:[XoomlAttributeHelper generateCurrentTimeForXooml]];
    actualNote.noteText = @"Note1Text1";
    actualNote.noteTextID = [XoomlAttributeHelper generateUUID];
    actualNote.modificationDate = [XoomlAttributeHelper generateCurrentTimeForXooml];
    NSData * createdXooml = [XoomlCollectionParser convertNoteToXooml: actualNote];
    CollectionNote * expectedNote = [XoomlCollectionParser xoomlNoteFromXML:createdXooml];
    
    STAssertEqualObjects(actualNote.noteText, expectedNote.noteText, @"Note Text Value did not get converted to xooml properly");
    STAssertEqualObjects(actualNote.noteTextID, expectedNote.noteTextID, @"Note ID Value did not get converted to xooml properly");
    STAssertEqualObjects(actualNote.creationDate, expectedNote.creationDate, @"Note creation date Value did not get converted to xooml properly");
    STAssertEqualObjects(actualNote.modificationDate, expectedNote.modificationDate, @"Note modification date Value did not get converted to xooml properly");
    
    
    
    
}

@end
