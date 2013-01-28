//
//  XoomlBulletinBoardController.m
//  IdeaStock
//
//  Created by Ali Fathalian on 4/1/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "XoomlCollectionManifest.h"
#import "DDXML.h"
#import "XoomlCollectionParser.h"


@interface XoomlCollectionManifest()

//This is the actual xooml document that this object wraps around.
@property (nonatomic,strong) DDXMLDocument * document;

@end

@implementation XoomlCollectionManifest

#pragma mark - XML Keys

#pragma mark - Initialization
-(id) initWithData:(NSData *) data{
    
    self = [super init];
    //open the document from the data
    NSError * err = nil;
    self.document = [[DDXMLDocument alloc] initWithData:data options:0 error:&err];
    
    //TODO right now im ignoring err. I should use it 
    //to determine the error
    if (self.document == nil){
        NSLog(@"Error reading the note XML File");
        return nil;
    }
    
    return self;
}

-(id) initAsEmpty{
    
    //use this helper method to create xooml
    //for an empty bulletinboard
    NSData * emptyBulletinBoardDate =[XoomlCollectionParser getEmptyCollectionXooml];
    
    //call designated initializer
    self = [self initWithData:emptyBulletinBoardDate];
    
    return self;
}

#pragma mark - Serialization
-(NSData *) data{
    return [self.document XMLData];
}

+(NSData *) getEmptyBulletinBoardData{
    return [XoomlCollectionParser getEmptyCollectionXooml];
}

#pragma mark - Query
/*
 Finds a xml node element with noteID and returns it
 */
-(DDXMLElement *) getNoteElementFor: (NSString *) noteID{
    //get the note fragment using xpath
    
    NSString * xPath = [XoomlCollectionParser xPathforNote:noteID];
    NSError * err;
    NSArray *notes = [self.document.rootElement nodesForXPath: xPath error: &err];
    
    if (notes == nil){
        NSLog(@"Error reading the content from XML");
        return nil;
    }
    
    if ([notes count] == 0 ){
        //There is apparently a bug in KissXML xPath
        //I will search for the note manuallyss if the bug occurs
        for(DDXMLElement * node in self.document.rootElement.children){
            if([[[node attributeForName:ATTRIBUTE_ID] stringValue] isEqualToString:noteID]){
                return node;
            }
        }
        NSLog(@"No Note XML Content exist for the given note");
        return nil;
    }
    
    return [notes lastObject];
}

/*
 Returns a dictionary of all the linkage info for the note with noteID. 
 The dictionary is keyed on the linkage name and contains an array of refNoteIds
 that the linkage refers to . 
 
 For example : 
 {linkageName1 = {refID1, refID2}, linkageName2 = {refID3}}
 
 if no linkage note exists the dictionary will be empty
 
 if the noteID is invalid the method returns nil
 
 The dictionary assumes that the lnkage is uniquely identified by its name
 */

-(NSDictionary *) getLinkageInfoForNote: (NSString *) noteID{
    return nil;
}

/*
 Returns all the stacking info for the bulletin board.
 The return type is an NSDictionary keyed on the stackingName and array of 
 reference noteIDs
 
 For Example: 
 {stackingName1 = {refID1} , stackingName2 = {refID3,refID4}}
 
 If no stacking infos exist the dictionary will be empty. 
 
 The method assumes that each stacking is uniquely identified with its name.
 As a result it only returns the first stacking with a given name and ignores 
 the rest. 
 */

-(NSDictionary *) getStackingInfo{
    //get All the stackings
    NSString * xPath = [XoomlCollectionParser xPathForCollectionAttribute:STACKING_TYPE];
    
    NSError * err;
    NSMutableArray *attribtues = [[self.document nodesForXPath: xPath error: &err]  mutableCopy];
    
    //if the stacking attribute does not exist return
    if (attribtues == nil) return nil; 
    
    if ([attribtues count] == 0){
        for (DDXMLElement * node in self.document.rootElement.children){
            if ([[[node attributeForName:ATTRIBUTE_TYPE] stringValue] isEqualToString:STACKING_TYPE]){
                [attribtues addObject:node];
            }
        }
    }
    //create a result dictionary
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    
    //for every child of the bulletinboard stacking attributes,
    //get its name and then put all of its refNote childs in an array
    //put the resulting array as the value for the key with the name of the 
    //stacking into the result dictionary.
    for (DDXMLElement * item in attribtues){
        NSString * name = [[item attributeForName:ATTRIBUTE_NAME] stringValue];
        
        NSMutableArray * refNotesArray = [NSMutableArray array];
        for (DDXMLElement *refIDElem in [item children]){
            NSString * refID = [[refIDElem attributeForName:REF_ID] stringValue];
            [refNotesArray addObject:refID];
        }
        result[name] = [refNotesArray copy];
    }
    
    return [result copy];
}

/*
 Returns all the grouping info for the bulletin board.
 The return type is an NSDictionary keyed on the groupingName and array of 
 reference noteIDs
 
 For Example: 
 {groupingName1 = {refID1} , groupingName2 = {refID3,refID4}}
 
 If no grouping infos exist the dictionary will be empty. 
 
 The method assumes that each grouping is uniquely identified with its name.
 As a result it only returns the first grouping with a given name and ignores 
 the rest. 
 */

-(NSDictionary *) getGroupingInfo{
    //not implemented
    return nil;
}


-(NSDictionary *) getAllNoteBasicInfo{
    
    NSMutableDictionary * answer = [NSMutableDictionary dictionary];
    
    //get all the notes
    NSString * xPath = [XoomlCollectionParser xPathForAllNotes];
    NSError * err;
    NSArray *notes = [self.document nodesForXPath: xPath error: &err];
    
    //if no note exists return the empty dictionary
    if (notes == nil || [notes count] == 0) return [answer copy];
    
    //for every note
    for(DDXMLElement * note in notes){
        //get the note attributes if they don't exist set them to nil
        NSString * noteID = [[note attributeForName:NOTE_ID] stringValue];
        NSString * noteName = [[note attributeForName:ASSOCIATED_XOOML_FRAGMENT] stringValue];
        NSString * notePositionX = nil;
        NSString * notePositionY = nil;
        NSString * noteScaling = nil;
        for(DDXMLElement * noteChild in [note children]){
            if ([noteChild.name isEqualToString:ASSOCIATION_NAMESPACE_DATA])
            {
                for (DDXMLElement * noteDescendant in [noteChild children])
                {
                    NSString * attributeName = [[noteDescendant attributeForName:ATTRIBUTE_TYPE] stringValue];
                    if ([attributeName isEqualToString:POSITION_TYPE]){
                        
                        notePositionX = [[noteDescendant attributeForName:POSITION_X] stringValue];
                        notePositionY = [[noteDescendant attributeForName:POSITION_Y] stringValue];
                    }
                    if ([attributeName isEqualToString:SCALING_TYPE])
                    {
                        noteScaling = [[noteDescendant attributeForName:SCALING] stringValue];
                    }
                }
            }
        }
        //for every note create a sub answer with all that notes properties
        NSMutableDictionary * subAnswer = [NSMutableDictionary dictionary];
        subAnswer[NOTE_NAME_KEY] = noteName;
        if (notePositionX) subAnswer[POSITION_X] = notePositionX;
        if (notePositionY) subAnswer[POSITION_Y] = notePositionY;
        if (noteScaling) subAnswer[SCALING] = noteScaling;
        //set the answer object for the note with noteID as that subAnswer dictionary
        //which now contains all key value pairs of properties. 
        answer[noteID] = subAnswer;
    }
    return [answer copy];
}

-(NSDictionary *) getNoteAttributeInfo: (NSString *) attributeType
                               forNote: (NSString *)noteID{
    
    if ([attributeType isEqualToString:LINKAGE_TYPE]){
        return [self getLinkageInfoForNote:noteID];
    }
    
    else return nil;
}
-(NSDictionary *) getCollectionAttributeInfo: (NSString *) attributeType{
    if ([attributeType isEqualToString:STACKING_TYPE]){
        return [self getStackingInfo];
    }
    if ([attributeType isEqualToString:GROUPING_TYPE]){
        return [self getGroupingInfo];
    }
    else return nil; 
    
    
}

#pragma mark - Creation
/*
 The reason why there are static method names for linkage and stacking and etc
 instead of a dynamic attribute Type is that at some point in future the processes
 and elements for each type may be different for other. 
 */

/*
 Adds a linkage to note with noteID to note with note refID
 
 If the noteID is not valid this method returns without doing anything. 
 
 This method assumes that refNoteID is a valid refID. 
 */
-(void) addLinkage: (NSString *) linkageName
            ToNote: (NSString *) noteID
WithReferenceToNote: (NSString *) refNoteID
{
    return;
}

/*
 Adds a stacking property with stackingName and the notes that are specified
 in the array note. 
 
 The array notes contains a list of noteIDs. 
 
 The method assumes that the stackingName is unique and if there exists
 another stacking with the same name adds it anyways. 
 
 Th method assumes the noteIDs passed in the NSArray notes are valid existing
 refNoteIDs. 
 */
-(void) addStackingWithName: (NSString *) stackingName
                  withNotes: (NSArray *) notes{
    
    NSString * xPath = [XoomlCollectionParser xPathForCollectionAttributeContainer];
    
    NSError * err;
    NSMutableArray *allAttributes = [[self.document nodesForXPath: xPath error: &err] mutableCopy];
    DDXMLElement * attribtues = [allAttributes lastObject];
    
//    //KISS XML BUG; still there as of Jan 27 2013. We need to do some work manually
    DDXMLElement * stacking = nil;
    for (DDXMLElement * node in attribtues.children)
    {
        if ([[[node attributeForName:ATTRIBUTE_TYPE] stringValue] isEqualToString:STACKING_TYPE] &&
            [[[node attributeForName:ATTRIBUTE_NAME] stringValue] isEqualToString:stackingName]){
            stacking = node;
            break;
        }
    }
    //if the stacking doesn't exist create it
    if (stacking == nil) {
        
        DDXMLElement * stackingElement = [XoomlCollectionParser xoomlForCollectionAttributeWithName:stackingName
                                                                                            andType:STACKING_TYPE];
        for (NSString * noteID in notes){
            DDXMLNode * note = [XoomlCollectionParser xoomlForNoteRef:noteID];
            [stackingElement addChild:note];
        }
        
        //get the fragment
        [attribtues addChild:stackingElement];
    }
    else{
        
        for (NSString * noteID in notes){
            DDXMLNode * note = [XoomlCollectionParser xoomlForNoteRef:noteID];
            [stacking addChild:note];
        }
    }
}

/*
 Adds a grouping property with groupingName and the notes that are specified
 in the array note. 
 
 The array notes contains a list of noteIDs. 
 
 The method assumes that the groupingName is unique and if there exists
 another grouping with the same name adds it anyways. 
 
 Th method assumes the noteIDs passed in the NSArray notes are valid existing
 refNoteIDs. 
 */
-(void) addGroupingWithName: (NSString *) groupingName
                  withNotes: (NSArray *) notes{
    return;
}

/*
 Adds a note with noteID to the stacking with stackingName. 
 
 If a stacking with stackingName does not exist, this method returns without
 doing anything. 
 
 This method assumes that the noteID is a valid noteID. 
 
 This method assumes that stackingName is unique. If there are more than
 one stacking with the stackingName it adds the note to the first stacking.
 */
-(void) addNote: (NSString *) noteID
     toStacking: (NSString *) stackingName{
    
    //get the xpath for the required attribute
    NSString * xPath = [XoomlCollectionParser xPathForCollectionAttributeWithName:stackingName andType:STACKING_TYPE];
    
    NSError * err;
    NSArray *attribtues = [self.document nodesForXPath: xPath error: &err];
    if (attribtues == nil){
        NSLog(@"Error reading the content from XML");
        return;
    }
    if ([attribtues count] == 0 ){
        NSLog(@"Fragment attribute is no avail :D");
        return;
    }
    
    DDXMLElement * bulletinBoardAttribute = [attribtues lastObject];
    DDXMLNode * noteRef = [XoomlCollectionParser xoomlForNoteRef:noteID];
    [bulletinBoardAttribute addChild:noteRef];
}

/*
 Adds a note with noteID to the grouping with groupingName. 
 
 If a grouping with groupingName does not exist, this method returns without
 doing anything. 
 
 This method assumes that the noteID is a valid noteID. 
 
 This method assumes that groupingName is unique. If there are more than
 one grouping with the groupingName it adds the note to the first stacking.
 */
-(void) addNote: (NSString *) noteID
     toGrouping: (NSString *) groupingName{
    return;
}

-(void) addNoteWithID: (NSString *) noteId 
        andProperties: (NSDictionary *)properties{
    
    //get the required attributes from the properties dictionary
    //if they are missing return
    NSString * noteName = properties[NOTE_NAME_KEY];
    NSString * positionX = properties[POSITION_X];
    NSString * positionY = properties[POSITION_Y];
    NSString * isVisible = properties[NOTE_IS_VISIBLE];
    NSString * scale = properties[SCALING];
    if (!noteName || !positionX || !positionY || !isVisible || !scale) return;
    
    //create the note node
    DDXMLElement * noteNode = [XoomlCollectionParser xoomlForCollectionNote:noteId andName:noteName];
    
    //create the position property itself
    DDXMLNode * notePositionProperty = [XoomlCollectionParser xoomlForNotePositionX:positionX andPositionY:positionY withVisibility:isVisible];
    DDXMLElement * noteAttributeContainer = [XoomlCollectionParser xoomlForNoteAttributeContainer];
    
    DDXMLNode * noteScaleProperty = [XoomlCollectionParser xoomlForNoteScale:scale];
    //put the nodes into the hierarchy
    [noteAttributeContainer addChild:notePositionProperty];
    [noteAttributeContainer addChild:noteScaleProperty];
    
    [noteNode addChild:noteAttributeContainer];
    
    DDXMLElement * root = [self.document rootElement];
    [root addChild:noteNode];
}

-(void) addNoteAttribute: (NSString *) attributeName
                 forType: (NSString *) attributeType 
                 forNote: (NSString *)noteID 
              withValues:(NSArray *) values{
    
    if ([attributeType isEqualToString:POSITION_TYPE]){
        
        //not all the required information for position 
        //are available so return
        if ( [values count] < 3) return;
        
        //get the position attributes
        NSString * positionX = values[0];
        NSString * positionY = values[1];
        NSString * isVisible = values[2];
        
        //get the note to add the position to
        DDXMLElement * note = [self getNoteElementFor:noteID];
        
        //create the position attribute
        DDXMLNode * noteProperty = [XoomlCollectionParser xoomlForNotePositionX:positionX
                                                                   andPositionY:positionY withVisibility:isVisible];
        DDXMLElement * noteAttributeContainer = [XoomlCollectionParser xoomlForNoteAttributeContainer];
        //put the nodes into the hierarchy
        [noteAttributeContainer addChild:noteProperty];
        [note addChild:noteAttributeContainer];
        return;
    }
}

-(void) addCollectionAttribute: (NSString *) attributeName 
                          forType: (NSString *) attributeType 
                       withValues: (NSArray *) values{
    if ([attributeType isEqualToString:STACKING_TYPE]){
        [self addStackingWithName:attributeName withNotes:values];
        return;
        
    }
}

#pragma mark - Deletion
/*
 Deletes the linkage with linkageName for the note with NoteID. 
 
 Deleting the linkage removes all the notes whose refIDs appear in the linakge.
 
 If the noteID or the linkageName are invalid. This method returns without
 doing anything. 
 */
-(void) deleteLinkage: (NSString *) linkageName 
              forNote: (NSString *)noteID{
    return;
}

/*
 Delete the note with noteRefID from the linkage with linkageName belonging
 to the note with noteID.
 
 If the noteID, noteRefID, or linkageName are invalid this method returns
 without doing anything. 
 */
-(void) deleteNote: (NSString *) noteRefID
       fromLinkage: (NSString *)linkageName
           forNote: (NSString *) noteID{
    return;
}

/*
 Deletes the stacking with stackingName from the bulletin board. 
 
 This deletion removes any notes that the stacking with stackingName 
 refered to from the list of its attributes. 
 
 If the stackingName is invalid this method returns without doing anything.
 */
-(void) deleteStacking: (NSString *) stackingName{
    
    NSString * xPath = [XoomlCollectionParser xPathForCollectionAttributeWithName:stackingName andType:STACKING_TYPE];
    
    NSError * err;
    NSMutableArray *stacking = [[self.document nodesForXPath: xPath error: &err] mutableCopy];
    
    //KISS XML BUG
    if ([stacking count] == 0){
        for (DDXMLElement * node in self.document.rootElement.children){
            if ([[[node attributeForName:ATTRIBUTE_TYPE] stringValue] isEqualToString:STACKING_TYPE] &&
                [[[node attributeForName:ATTRIBUTE_NAME] stringValue] isEqualToString:stackingName]){
                [stacking addObject:node];
                break;
            }
        }
    }
    //if the stacking attribute does not exist return
    if (stacking == nil || [stacking count] == 0) return;
    
    DDXMLElement * bulletinBoardAttribute = [stacking lastObject];
    DDXMLElement * attributeParent = (DDXMLElement *)[bulletinBoardAttribute parent];
    [attributeParent removeChildAtIndex:[bulletinBoardAttribute index]];
}

/*
 Deletes the note with noteID from the stacking with stackingName. 
 
 If the stackingName or noteID are invalid this method returns without
 doing anything.
 */
-(void) deleteNote: (NSString *) noteID
      fromStacking: (NSString *) stackingName{
    
    
    NSString * xPath = [XoomlCollectionParser xPathForCollectionAttributeWithName:stackingName andType:STACKING_TYPE];
    
    
    NSError * err;
    NSMutableArray *attribtues = [[self.document nodesForXPath: xPath error: &err] mutableCopy];
    if ([attribtues count] == 0){
        for (DDXMLElement * node in self.document.rootElement.children){
            if ([[[node attributeForName:ATTRIBUTE_TYPE] stringValue] isEqualToString:STACKING_TYPE] &&
                [[[node attributeForName:ATTRIBUTE_NAME] stringValue] isEqualToString:stackingName]){
                [attribtues addObject:node];
                break;
            }
        }
    }
    //if the stacking attribute does not exist return
    if (attribtues == nil || [attribtues count] == 0) return;
    
    DDXMLElement * bulletinBoardAttribute = [attribtues lastObject];
    
    for (DDXMLElement * element in [bulletinBoardAttribute children]){
        if ( [[[element attributeForName:REF_ID] stringValue] isEqualToString:noteID]){
            [bulletinBoardAttribute removeChildAtIndex:[element index]];
            return;
        }
    }
}

/*
 Deletes the grouping with groupingName from the bulletin board. 
 
 This deletion removes any notes that the grouping with grouping 
 refered to from the list of its attributes. 
 
 If the groupingName is invalid this method returns without doing anything.
 */
-(void) deleteGrouping: (NSString *) groupingName{
    return;
}

/*
 Deletes the note with noteID from the grouping with groupingName. 
 
 If the groupingName or noteID are invalid this method returns without
 doing anything.
 */

-(void) deleteNote: (NSString *) noteID
      fromGrouping: (NSString *) groupingName{
    return;
}

-(void) deleteNote: (NSString *) noteID{
    
    DDXMLElement * note = [self getNoteElementFor:noteID];
    
    //if the note does not exist return
    if (!note) return;
    
    //delete the note 
    DDXMLElement * noteParent = (DDXMLElement *)[note parent];
    [noteParent removeChildAtIndex:[note index]];
    
    //delete the note from stackings if available
    NSDictionary * allStackins = [self getStackingInfo];
    for (NSString * stackingName in allStackins){
        [self deleteNote:noteID fromStacking:stackingName];
    }
}

-(void) deleteNote:(NSString *) targetNoteID 
 fromNoteAttribute: (NSString *) attributeName 
            ofType: (NSString *) attributeType 
           forNote: (NSString *) sourceNoteID{
    
    return;
}

-(void) deleteNote: (NSString *) noteID 
fromCollectionAttribute: (NSString *) 
attributeName ofType:(NSString *) attributeType{
    
    if ([attributeType isEqualToString:STACKING_TYPE]){
        
        NSDictionary * allStacking = [self getStackingInfo];
        for (NSString * stackinName in allStacking){
            if ([stackinName isEqualToString:attributeName]){
                [self deleteNote:noteID fromStacking:stackinName];
            }
        }
        return;
    }
}

-(void) deleteNoteAttribute: (NSString *) attributeName
                     ofType: (NSString *) attributeType 
                   fromNote: (NSString *) noteID{
    return;
}

-(void) deleteCollectionAttribute:(NSString *) attributeName 
                              ofType: (NSString *) attributeType{
    if ([attributeType isEqualToString:STACKING_TYPE]){
        [self deleteStacking:attributeName];
        return;
    }
}

#pragma mark - Update

/*
 updates the name of linkage for note with noteID from linkageName
 to newLinkageName. 
 
 If the noteID or linkageName are invalid the method returns without 
 doing anything. 
 */
-(void) updateLinkageName: (NSString *) linkageName
                  forNote: (NSString *) noteID
              withNewName: (NSString *) newLinkageName{
    return;
}

/*
 Updates the name of a bulletin board stacking from stacking to 
 newStackingName. 
 
 If the stackingName is invalid the method returns without doing anything.
 */
-(void) updateStackingName: (NSString *) stackingName
               withNewName: (NSString *) newStackingName{
    NSString * xPath = [XoomlCollectionParser xPathForCollectionAttributeWithName:stackingName andType:STACKING_TYPE];
    
    NSError * err;
    NSArray *attribtues = [self.document nodesForXPath: xPath error: &err];
    
    //if the stacking attribute does not exist return
    if (attribtues == nil || [attribtues count] == 0) return;
    
    DDXMLElement * bulletinBoardAttribute = [attribtues lastObject];
    [[bulletinBoardAttribute attributeForName:ATTRIBUTE_NAME] setStringValue:newStackingName];
}

/*
 Updates the name of a bulletin board grouping from groupingName to 
 newGroupingName. 
 
 If the groupingName is invalid the method returns without doing anything.
 */
-(void) updateGroupingName: (NSString *) groupingName
               withNewName: (NSString *) newGroupingName{
    return;
}

-(void) updateNote: (NSString *) noteID 
    withProperties: (NSDictionary *)  newProperties{
    //lookup the note if it doesnt exist return
    DDXMLElement * note = [self getNoteElementFor:noteID];
    if (!note) return;
    
    NSString * newName = [newProperties[NOTE_NAME_KEY] lastObject];
    NSString * newPositionX = [newProperties[POSITION_X] lastObject];
    NSString * newPositionY = [newProperties[POSITION_Y]lastObject];
    NSString * newIsVisible = [newProperties[NOTE_IS_VISIBLE] lastObject];
    NSString * scale = newProperties[SCALING];
    //if its the name of the note that we want to change change it on the 
    //note itself
    if (newName){
        [note removeAttributeForName:XOOML_NOTE_NAME];
        [note addAttribute:[DDXMLNode attributeWithName:XOOML_NOTE_NAME stringValue:newName]];
    }
    //for every child of the node check if it is a position property
    for (DDXMLElement * noteElement in [note children]){
        if ([noteElement.name isEqualToString:ASSOCIATION_NAMESPACE_DATA])
        {
            for(DDXMLElement * element in [noteElement children])
            {
                if ([[[element attributeForName:ATTRIBUTE_TYPE] stringValue] isEqualToString:POSITION_TYPE]){
                    //for the position proerty get the propery and if a new value is specified
                    //update it.
                    //if there is no position element this note is invalid and can't be
                    //updated
                    if (newPositionX){
                        [element removeAttributeForName:POSITION_X];
                        [element addAttribute:[DDXMLNode attributeWithName:POSITION_X stringValue:newPositionX]];
                    }
                    if(newPositionY){
                        [element removeAttributeForName:POSITION_Y];
                        [element addAttribute:[DDXMLNode attributeWithName:POSITION_Y stringValue:newPositionY]];
                    }
                    if(newIsVisible){
                        [element removeAttributeForName:XOOML_IS_VISIBLE];
                        [element addAttribute:[DDXMLNode attributeWithName:XOOML_IS_VISIBLE stringValue:newIsVisible]];
                    }
                }
                else if ([[[element attributeForName:ATTRIBUTE_TYPE] stringValue] isEqualToString:SCALING_TYPE])
                {
                    if(scale){
                        [element removeAttributeForName:SCALING];
                        [element addAttribute:[DDXMLNode attributeWithName:SCALING stringValue:scale]];
                    }
                }
            }
        }
    }
}

-(void) updateNoteAttribute: (NSString *) oldAttributeName
                     ofType:(NSString *) attributeType 
                    forNote: (NSString *) noteID 
                withNewName: (NSString *) newAttributeName{
    return;
}

-(void) updateCollectionAttributeName: (NSString *) oldAttributeName
                                  ofType: (NSString *) attributeType 
                             withNewName: (NSString *) newAttributeName{
    if ([attributeType isEqualToString:STACKING_TYPE]){
        [self updateStackingName:oldAttributeName withNewName:newAttributeName];
    }
}

-(void) updateNoteAttribute: (NSString *) attributeName
                     ofType: (NSString *) attributeType 
                    forNote: (NSString *) noteID
                 withValues: (NSArray *) values{
    return;
}

-(NSString *) description{
    NSData * xml = self.data;
    return [[NSString alloc] initWithData:xml encoding:NSUTF8StringEncoding];
}

@end