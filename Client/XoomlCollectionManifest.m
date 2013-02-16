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
#import "XoomlStackingModel.h"


@interface XoomlCollectionManifest()

//This is the actual xooml document that this object wraps around.
@property (nonatomic,strong) DDXMLDocument * document;

@end

@implementation XoomlCollectionManifest

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

-(id) initWithDocument:(DDXMLDocument *) document
{
    self = [super init];
    self.document = document;
    return self;
}

-(id) initAsEmpty{
    
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
 Returns all the stacking info for the bulletin board.
 The return type is an NSDictionary keyed on the stackingName with values of stackingObject
 
 */
-(NSDictionary *) getAllStackingsInfo{
    //get All the stackings
    DDXMLElement * collectionAttribute = [self getCollectionAttributesElement];
    
    if (collectionAttribute == nil) return nil;
    
    NSMutableArray *attribtues = [NSMutableArray array];
    
    if ([attribtues count] == 0){
        for (DDXMLElement * node in collectionAttribute.children){
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
        NSString * scaleString = [[item attributeForName:SCALING] stringValue];
        
        NSMutableArray * refNotesArray = [NSMutableArray array];
        for (DDXMLElement *refIDElem in [item children]){
            NSString * refID = [[refIDElem attributeForName:REF_ID] stringValue];
            [refNotesArray addObject:refID];
        }
        XoomlStackingModel * model = [[XoomlStackingModel alloc] initWithName:name
                                                           andScale:scaleString
                                                                    andRefIds:[NSSet setWithArray:refNotesArray]];
        result[name] =  model;
    }
    
    return [result copy];
}

/*
 Returns NSDictionary of NoteModel
 */
-(NSDictionary *) getAllNotesBasicInfo{
    
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
        XoomlNoteModel * noteModel = [[XoomlNoteModel alloc] initWithName:noteName
                                                             andPositionX: notePositionX
                                                             andPositionY: notePositionY
                                                               andScaling:noteScaling];
        answer[noteID] = noteModel;
    }
    return [answer copy];
}

#pragma mark - Creation

-(DDXMLElement *) getCollectionAttributesElement
{
    NSString * xPath = [XoomlCollectionParser xPathForCollectionAttributeContainer];
    
    NSError * err;
    NSMutableArray *allAttributes = [[self.document nodesForXPath: xPath error: &err] mutableCopy];
    DDXMLElement * attribtues = [allAttributes lastObject];
    return attribtues;
}

-(DDXMLElement *) getStackingElementForStackingWithName:(NSString *) stackingName
{

    DDXMLElement * attributes = [self getCollectionAttributesElement];
    //KISS XML BUG; still there as of Jan 27 2013. We need to do some work manually
    DDXMLElement * stacking = nil;
    for (DDXMLElement * node in attributes.children)
    {
        if ([[[node attributeForName:ATTRIBUTE_TYPE] stringValue] isEqualToString:STACKING_TYPE] &&
            [[[node attributeForName:ATTRIBUTE_NAME] stringValue] isEqualToString:stackingName]){
            stacking = node;
            break;
        }
    }
    return stacking;
}

-(void) addStackingWithName: (NSString *) stackingName
           andStackingModel:(XoomlStackingModel *) model
{

    DDXMLElement * stacking = [self getStackingElementForStackingWithName:stackingName];
    //if the stacking doesn't exist create it
    if (stacking == nil || model == nil) {
        
        DDXMLElement * stackingElement = [XoomlCollectionParser xoomlForCollectionAttributeWithName:stackingName
                                                                                            andType:STACKING_TYPE];
        for (NSString * noteID in model.refIds){
            DDXMLNode * note = [XoomlCollectionParser xoomlForNoteRef:noteID];
            [stackingElement addChild:note];
        }
        
        DDXMLElement * attributes = [self getCollectionAttributesElement];
        //get the fragment
        [attributes addChild:stackingElement];
    }
    else{
        
        for (NSString * noteID in model.refIds){
            DDXMLNode * note = [XoomlCollectionParser xoomlForNoteRef:noteID];
            [stacking addChild:note];
        }
    }
}


-(void) addNotes:(NSArray *) noteIds
      toStacking:(NSString *) stackingName
{
    //get the xpath for the required attribute
    DDXMLElement * bulletinBoardAttribute = [self getStackingElementForStackingWithName:stackingName];
    for (NSString * noteId in noteIds)
    {
        DDXMLNode * noteRef = [XoomlCollectionParser xoomlForNoteRef:noteId];
        [bulletinBoardAttribute addChild:noteRef];
    }
}

- (void) addNoteWithID: (NSString *) noteId
              andModel: (XoomlNoteModel *)model
{
    
    //get the required attributes from the properties dictionary
    //if they are missing return
    NSString * noteName = model.noteName;
    NSString * positionX = model.positionX;
    NSString * positionY = model.positionY;
    NSString * scale = model.scaling;
    if (!noteName || !positionX || !positionY || !scale) return;
    
    //create the note node
    DDXMLElement * noteNode = [XoomlCollectionParser xoomlForCollectionNote:noteId andName:noteName];
    
    //for now we just assume everything is visible
    NSString * isVisible = @"true";
    //create the position property itself
    DDXMLNode * notePositionProperty = [XoomlCollectionParser xoomlForNotePositionX:positionX
                                                                       andPositionY:positionY withVisibility:isVisible];
    
    DDXMLElement * noteAttributeContainer = [XoomlCollectionParser xoomlForNoteAttributeContainer];
    
    DDXMLNode * noteScaleProperty = [XoomlCollectionParser xoomlForNoteScale:scale];
    //put the nodes into the hierarchy
    [noteAttributeContainer addChild:notePositionProperty];
    [noteAttributeContainer addChild:noteScaleProperty];
    
    [noteNode addChild:noteAttributeContainer];
    
    DDXMLElement * root = [self.document rootElement];
    [root addChild:noteNode];
}

-(void) addStacking:(NSString *) stackingName
          withModel:(XoomlStackingModel *)model
{
    [self addStackingWithName:stackingName andStackingModel:model];
}

#pragma mark - Deletion

-(void) deleteStacking: (NSString *) stackingName{
    
    DDXMLElement * bulletinBoardAttribute = [self getStackingElementForStackingWithName:stackingName];
    if (bulletinBoardAttribute == nil) return;
    
    DDXMLElement * attributeParent = (DDXMLElement *)[bulletinBoardAttribute parent];
    [attributeParent removeChildAtIndex:[bulletinBoardAttribute index]];
}

-(void) removeNotes: (NSArray *) noteIds
      fromStacking: (NSString *) stackingName{
    
    DDXMLElement * bulletinBoardAttribute = [self getStackingElementForStackingWithName:stackingName];
    
    if (bulletinBoardAttribute == nil) return;
    NSSet * noteSet = [NSSet setWithArray:noteIds];
    for (DDXMLElement * element in [bulletinBoardAttribute children]){
        NSString * refId = [[element attributeForName:REF_ID] stringValue];
        if ([noteSet containsObject:refId]){
            [bulletinBoardAttribute removeChildAtIndex:[element index]];
            return;
        }
    }
}

-(void) deleteNote: (NSString *) noteID{
    
    DDXMLElement * note = [self getNoteElementFor:noteID];
    
    //if the note does not exist return
    if (!note) return;
    
    //delete the note 
    DDXMLElement * noteParent = (DDXMLElement *)[note parent];
    [noteParent removeChildAtIndex:[note index]];
    
    //delete the note from stackings if available
    NSDictionary * allStackins = [self getAllStackingsInfo];
    for (NSString * stackingName in allStackins){
        [self removeNotes:@[noteID] fromStacking:stackingName];
    }
}

#pragma mark - Update

-(void) updateNote: (NSString *) noteID
     withNewModel: (XoomlNoteModel *)  noteModel
{
    //lookup the note if it doesnt exist return
    DDXMLElement * note = [self getNoteElementFor:noteID];
    if (!note) return;
    
    NSString * newName = noteModel.noteName;
    NSString * newPositionX = noteModel.positionX;
    NSString * newPositionY = noteModel.positionY;
    NSString * newIsVisible = @"true";
    NSString * scale = noteModel.scaling;
    
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


-(void) updateStacking:(NSString *) stackingName
               withNewModel:(XoomlStackingModel *) model
{
    DDXMLElement * bulletinBoardAttribute = [self getStackingElementForStackingWithName:stackingName];
    if (bulletinBoardAttribute == nil) return;
    if (model.name)
    {
        [[bulletinBoardAttribute attributeForName:ATTRIBUTE_NAME] setStringValue: model.name];
    }
    if (model.scale)
    {
        NSString * scaleString = model.scale;
        [[bulletinBoardAttribute attributeForName:SCALING] setStringValue: scaleString];
    }
    //we are not going to update the notes
}


-(NSString *) description{
    NSData * xml = self.data;
    return [[NSString alloc] initWithData:xml encoding:NSUTF8StringEncoding];
}


#pragma mark - thumbnail
-(NSString *) getCollectionThumbnailNoteId
{
    DDXMLElement * thumbnailAttribute = [self getThumbnailAttribute];
    if (thumbnailAttribute == nil)
    {
        return nil;
    }
    else
    {
        NSString * noteId = [[thumbnailAttribute attributeForName:REF_ID] stringValue];
        return noteId;
    }
}

-(DDXMLElement *) getThumbnailAttribute
{
    
    DDXMLElement * collectionAttribute = [self getCollectionAttributesElement];
    
    if (collectionAttribute == nil) return nil;
    
    for(DDXMLElement * node in collectionAttribute.children)
    {
        if([[node name] isEqualToString:MINDCLOUD_COLLECTION_THUMBNAIL])
        {
            return node;
        }
    }
    return nil;
}
-(void) updateThumbnailWithImageOfNote:(NSString *)noteId
{
    DDXMLElement * thumbnailAttribute = [self getThumbnailAttribute];
    if (thumbnailAttribute == nil)
    {
        DDXMLElement * thumbnailElement = [XoomlCollectionParser xoomlForThumbnailWithNoteRef:noteId];
        DDXMLElement * fragmentNamespaceData = [self getCollectionAttributesElement];
        [fragmentNamespaceData addChild:thumbnailElement];
    }
    else
    {
        [[thumbnailAttribute attributeForName:REF_ID] setStringValue:noteId];
    }
}

-(void) deleteThumbnailForNote:(NSString *)noteId
{
    DDXMLElement * thumbnailAttribute = [self getThumbnailAttribute];
    if (thumbnailAttribute == nil) return;
    
    DDXMLElement * thumbnailParent = (DDXMLElement *)[thumbnailAttribute parent];
    [thumbnailParent removeChildAtIndex:[thumbnailAttribute index]];
}


-(DDXMLDocument *) document
{
    return _document;
}
@end