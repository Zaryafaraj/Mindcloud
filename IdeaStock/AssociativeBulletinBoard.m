//
//  XoomlBulletinBoard.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "AssociativeBulletinBoard.h"
#import "XoomlParser.h"

#import "XoomlBulletinBoardController.h"
#import "CallBackDataModel.h"
#import "FileSystemHelper.h"


/*====================================================================*/

/*
 These are the default attributes for note
 Add new ones here. 
 */
//TODO  some of these definition may need to go to a higher level header
// or even inside a definitions file

/*--------------------------------------------------
 
                    Definations
 
 -------------------------------------------------*/

#define POSITION_X @"positionX"
#define POSITION_Y @"positionY"
#define IS_VISIBLE @"isVisible"

#define POSITION_TYPE @"position"
#define VISIBILITY_TYPE @"visibility"
#define LINKAGE_TYPE @"linkage"
#define STACKING_TYPE @"stacking"
#define GROUPING_TYPE @"grouping"
#define NOTE_NAME_TYPE @"name"

#define DEFAULT_X_POSITION @"0"
#define DEFAULT_Y_POSITION @"0"
#define DEFAULT_VISIBILITY  @"true"
#define NOTE_NAME @"name"
#define NOTE_ID @"ID"

#define LINKAGE_NAME @"name"
#define STACKING_NAME @"name"
#define REF_IDS @"refIDs"

/*====================================================================*/


@implementation AssociativeBulletinBoard

/*--------------------------------------------------
 
                        Synthesis
 
 -------------------------------------------------*/

@synthesize dataModel = _dataModel;
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize noteAttributes = _noteAttributes;
@synthesize bulletinBoardAttributes = _bulletinBoardAttributes;
@synthesize noteContents = _noteContents;
@synthesize bulletinBoardName = _bulletinBoardName;
@synthesize noteImages = _noteImages;

-(BulletinBoardAttributes *) bulletinBoardAttributes{
    if (!_bulletinBoardAttributes){
        _bulletinBoardAttributes = [self createBulletinBoardAttributeForBulletinBoard];
    }
    return _bulletinBoardAttributes;
}

-(NSMutableDictionary *)noteAttributes{
    if(!_noteAttributes){
        _noteAttributes = [NSMutableDictionary dictionary];
    }
    return _noteAttributes;
}

-(NSMutableDictionary *) noteContents{
    if (!_noteContents){
        _noteContents = [NSMutableDictionary dictionary];
    }
    return _noteContents;
}

-(NSMutableDictionary *) noteImages{
    if (!_noteImages){
        _noteImages = [NSMutableDictionary dictionary];
    }
    return _noteImages;
}



/*====================================================================*/


/*--------------------------------------------------
 
                    Initializiation
 
 -------------------------------------------------*/

/*
 Factory method for the bulletin board attributes
 */
-(BulletinBoardAttributes *) createBulletinBoardAttributeForBulletinBoard{
    return [[BulletinBoardAttributes alloc] initWithAttributes:[NSArray arrayWithObjects:STACKING_TYPE,GROUPING_TYPE, nil]];
}

/*
 Factory method for the note bulletin board attributes
 */
-(BulletinBoardAttributes *) createBulletinBoardAttributeForNotes{
    return [[BulletinBoardAttributes alloc] initWithAttributes:[NSArray arrayWithObjects:NOTE_NAME_TYPE,LINKAGE_TYPE,POSITION_TYPE, VISIBILITY_TYPE, nil]];
}

-(id)initEmptyBulletinBoardWithDataModel: (id <DataModel>) dataModel 
                                 andName:(NSString *) bulletinBoardName{
    
    self = [super init];
    
    self.bulletinBoardName = bulletinBoardName;
    
    self.dataModel = dataModel;
    //if the datamodel requires delegation set your self as the delegate 
    if ([self.dataModel conformsToProtocol:@protocol(CallBackDataModel)]){
        [(id <CallBackDataModel>) self.dataModel setDelegate:self];
        
    }
    
    //create an empty bulletinBoard controller and make it both delegate
    //and the datasource
    id bulletinBoardController = [[XoomlBulletinBoardController alloc] initAsEmpty];
    self.dataSource = bulletinBoardController;
    self.delegate = bulletinBoardController;
    
    //initialize the bulletin board attributes with stacking and grouping
    //to add new attributes first define them in the header file and the
    //initilize the bulletinBoardAttributes with an array of them
    
    
    //add an empty bulletinboard to the datamodel
    NSData * bulletinBoardData = [self.dataSource data];
    [self.dataModel addBulletinBoardWithName:bulletinBoardName andBulletinBoardInfo:bulletinBoardData] ;
    return self;
    
}

/*
 Initilizes the bulletin board with the content of a xooml file for a previously
 created bulletinboard. 
 */

-(void) initiateNoteContent: (NSData *) noteData 
                  forNoteID: (NSString *) noteID
                    andName: (NSString *) noteName
              andProperties: (NSDictionary *) noteInfos{
    
    id <Note> noteObj = [XoomlParser xoomlNoteFromXML:noteData];
    
    if ( !noteObj) return ;
    
    if ([noteObj isKindOfClass:[BulletinBoardNote class]]){
        NSString * imgName = ((BulletinBoardNote *) noteObj).image;
        if (imgName != nil){
            NSString * imgPath = [FileSystemHelper getPathForImageWithName:imgName forNoteName:noteName inBulletinBoard:self.bulletinBoardName];
            if (imgPath != nil && ![imgPath isEqualToString:@""]){
                [self.noteImages setObject:imgPath forKey:noteID];
            }
        }
    }
    //now set the note object as a noteContent keyed on its id
    [self.noteContents setObject:noteObj forKey:noteID];
    
    //now initialize the bulletinBoard attributes to hold all the 
    //note specific attributes for that note
    BulletinBoardAttributes * noteAttribute = [self createBulletinBoardAttributeForNotes];
    //get the note specific info from the note basic info
    NSDictionary * noteInfo = [noteInfos objectForKey:noteID];
    
    NSString * positionX = [noteInfo objectForKey: POSITION_X];
    if (!positionX ) positionX = DEFAULT_X_POSITION;
    NSString * positionY = [noteInfo objectForKey: POSITION_Y];
    if (!positionY) positionY = DEFAULT_Y_POSITION;
    NSString * isVisible = [noteInfo objectForKey:IS_VISIBLE];
    if (! isVisible) isVisible = DEFAULT_VISIBILITY;
    
    //Fill out the note specific attributes for that note in the bulletin
    //board
    [noteAttribute createAttributeWithName:POSITION_X forAttributeType: POSITION_TYPE andValues:[NSArray arrayWithObject: positionX ]];
    [noteAttribute createAttributeWithName:POSITION_Y forAttributeType:POSITION_TYPE andValues:[NSArray arrayWithObject:positionY]];
    [noteAttribute createAttributeWithName:IS_VISIBLE forAttributeType:VISIBILITY_TYPE andValues:[NSArray arrayWithObject:isVisible]];
    [noteAttribute createAttributeWithName:NOTE_NAME forAttributeType: NOTE_NAME_TYPE andValues:[NSArray arrayWithObject: noteName ]];
    
    [self.noteAttributes setObject:noteAttribute forKey:noteID];
    
}


-(void) initiateLinkages{
    //For every note in the note content get all the linked notes and 
    //add them to the note attributes only if that referenced notes
    //in that linkage are exisiting in the note contents. 
    for (NSString * noteID in self.noteContents){
        NSDictionary *linkageInfo = [self.delegate getNoteAttributeInfo:LINKAGE_TYPE forNote:noteID];
        for(NSString *linkageName in linkageInfo){
            NSArray * refIDs = [linkageInfo objectForKey:linkageName];
            for (NSString * refID in refIDs){
                if ([self.noteContents objectForKey:refID]){
                    [[self.noteAttributes objectForKey:noteID] addValues:[NSArray arrayWithObject:refID] ToAttribute:linkageName forAttributeType:LINKAGE_TYPE];
                }
            }
            
            
        }
    }
    
    
}

-(void) initiateStacking{
    
    //get the stacking information and fill out the stacking attributes
    NSDictionary *stackingInfo = [self.delegate getBulletinBoardAttributeInfo:STACKING_TYPE];
    for (NSString * stackingName in stackingInfo){
        NSArray * refIDs = [stackingInfo objectForKey:stackingName];
        for (NSString * refID in refIDs){
            if(![self.noteContents objectForKey:refIDs]){
                [self.bulletinBoardAttributes addValues:[NSArray arrayWithObject:refID] ToAttribute:stackingName forAttributeType:STACKING_TYPE];
            }
        }
    }
    
}

-(void) initiateGrouping{
    
    //get the grouping information and fill out the grouping info
    NSDictionary *groupingInfo = [self.delegate getBulletinBoardAttributeInfo:GROUPING_TYPE];
    for (NSString * groupingName in groupingInfo){
        NSArray * refIDs = [groupingInfo objectForKey:groupingName];
        for (NSString * refID in refIDs){
            if(![self.noteContents objectForKey:refIDs]){
                [self.bulletinBoardAttributes addValues:[NSArray arrayWithObject:refID] ToAttribute:groupingName forAttributeType:GROUPING_TYPE];
            }
        }
    }
    
}

-(id) initBulletinBoardFromXoomlWithDatamodel:(id<DataModel>)datamodel
                                      andName:(NSString *)bulletinBoardName{
    
    self = [super init];
    
    //initialize the data structures
    self.bulletinBoardName = bulletinBoardName;
    
    
    //if the datamodel requires delegation set your self as the delegate 
    //and return. The initialization cannot be done with synchronous calls
    if ([datamodel conformsToProtocol:@protocol(CallBackDataModel)]){
        return self;
        
    }
    
    self.dataModel = datamodel;
    
    
    //if the datamodel does not require delegation and is synchronous
    //we will initialize the innards of the class one by one
    
    //First get the xooml file for the bulletinboard as NSData from
    //the datamodel
    NSData * bulletinBoardData = [self.dataModel getBulletinBoard:bulletinBoardName];  
    
    //Initialize the bulletinBoard controller to parse and hold the 
    //tree for the bulletin board
    id bulletinBoardController= [[XoomlBulletinBoardController alloc]  initWithData:bulletinBoardData];
    
    //Make the bulletinboard controller the datasource and delegate
    //for the bulletin board so the bulletin board can structural and
    //data centric questions from it.
    self.dataSource = bulletinBoardController;
    self.delegate = bulletinBoardController;
    
    //Now start to initialize the bulletin board attributes one by one
    //from the delegate.
    
    
    //Get all the note info for all the notes in the bulletinBoard
    NSDictionary * noteInfo = [self.delegate getAllNoteBasicInfo];
    
    for (NSString * noteID in noteInfo){
        //for each note create a note Object by reading its separate xooml files
        //from the data model
        NSString * noteName = [[noteInfo objectForKey:noteID] objectForKey:NOTE_NAME];
        NSData * noteData = [self.dataModel getNoteForTheBulletinBoard:bulletinBoardName WithName:noteName];
        
        if (!noteData) return self;
        
        
        [self initiateNoteContent:noteData
                        forNoteID:noteID 
                          andName:noteName
                    andProperties:noteInfo];
        
    }
    
    //initiate Linkages
    [self initiateLinkages];
    
    //initiate stacking
    [self initiateStacking];
    
    //initiate grouping
    
    [self initiateGrouping];
    
    return self;    
}

/*--------------------------------------------------
 
                        Addition
 
 -------------------------------------------------*/

-(void) addNoteContent: (id <Note>) note 
          andProperties: (NSDictionary *) properties{
    
    //get note Name and note ID if they are not present throw an exception
    NSString * noteID = [properties objectForKey:NOTE_ID];
    NSString * noteName = [properties  objectForKey:NOTE_NAME];
    if (!noteID || !noteName) [NSException raise:NSInvalidArgumentException
                                          format:@"A Values is missing from the required properties dictionary"];
    
    //set the note content for the noteID
    [self.noteContents setObject:note forKey:noteID];
    
    //get other optional properties for the note. 
    //If they are not present use default values
    NSString * positionX = [properties objectForKey:POSITION_X];
    if (!positionX) positionX = DEFAULT_X_POSITION;
    NSString * positionY = [properties objectForKey:POSITION_Y];
    if (!positionY) positionY = DEFAULT_Y_POSITION;
    NSString * isVisible = [properties objectForKey:IS_VISIBLE];
    if(!isVisible) isVisible = DEFAULT_VISIBILITY;
    
    //create a dictionary of note properties
    NSDictionary *noteProperties = [NSDictionary dictionaryWithObjectsAndKeys:noteName,NOTE_NAME,
                                    noteID,NOTE_ID,
                                    positionX,POSITION_X,
                                    positionY, POSITION_Y,
                                    isVisible,IS_VISIBLE,
                                    nil];
    
    //have the delegate hold the structural information about the note
    [self.delegate addNoteWithID:noteID andProperties:noteProperties];
    
    //have the notes bulletin board attribute list for the note hold the note
    //properties
    BulletinBoardAttributes * noteAttribute = [self createBulletinBoardAttributeForNotes];
    [noteAttribute createAttributeWithName:NOTE_NAME forAttributeType: NOTE_NAME_TYPE andValues:[NSArray arrayWithObject: noteName ]];
    [noteAttribute createAttributeWithName:POSITION_X forAttributeType: POSITION_TYPE andValues:[NSArray arrayWithObject: positionX ]];
    [noteAttribute createAttributeWithName:POSITION_Y forAttributeType:POSITION_TYPE andValues:[NSArray arrayWithObject:positionY]];
    [noteAttribute createAttributeWithName:IS_VISIBLE forAttributeType:VISIBILITY_TYPE andValues:[NSArray arrayWithObject:isVisible]];
    
    [self.noteAttributes setObject:noteAttribute forKey:noteID];
    
    //update the datamodel
    NSData * noteData = [XoomlParser convertNoteToXooml:note];
    [self.dataModel addNote:noteName withContent:noteData  ToBulletinBoard:self.bulletinBoardName];
    
}

- (void) addImageNoteContent:(id <Note> )note 
               andProperties:properties
                    andImage: (NSData *) img{
    //get note Name and note ID if they are not present throw an exception
    NSString * noteID = [properties objectForKey:NOTE_ID];
    NSString * noteName = [properties  objectForKey:NOTE_NAME];
    if (!noteID || !noteName) [NSException raise:NSInvalidArgumentException
                                          format:@"A Values is missing from the required properties dictionary"];
    
    //set the note content for the noteID
    [self.noteContents setObject:note forKey:noteID];
    
    //get other optional properties for the note. 
    //If they are not present use default values
    NSString * positionX = [properties objectForKey:POSITION_X];
    if (!positionX) positionX = DEFAULT_X_POSITION;
    NSString * positionY = [properties objectForKey:POSITION_Y];
    if (!positionY) positionY = DEFAULT_Y_POSITION;
    NSString * isVisible = [properties objectForKey:IS_VISIBLE];
    if(!isVisible) isVisible = DEFAULT_VISIBILITY;
    
    //create a dictionary of note properties
    NSDictionary *noteProperties = [NSDictionary dictionaryWithObjectsAndKeys:noteName,NOTE_NAME,
                                    noteID,NOTE_ID,
                                    positionX,POSITION_X,
                                    positionY, POSITION_Y,
                                    isVisible,IS_VISIBLE,
                                    nil];
    
    //have the delegate hold the structural information about the note
    [self.delegate addNoteWithID:noteID andProperties:noteProperties];
    
    //have the notes bulletin board attribute list for the note hold the note
    //properties
    BulletinBoardAttributes * noteAttribute = [self createBulletinBoardAttributeForNotes];
    [noteAttribute createAttributeWithName:NOTE_NAME forAttributeType: NOTE_NAME_TYPE andValues:[NSArray arrayWithObject: noteName ]];
    [noteAttribute createAttributeWithName:POSITION_X forAttributeType: POSITION_TYPE andValues:[NSArray arrayWithObject: positionX ]];
    [noteAttribute createAttributeWithName:POSITION_Y forAttributeType:POSITION_TYPE andValues:[NSArray arrayWithObject:positionY]];
    [noteAttribute createAttributeWithName:IS_VISIBLE forAttributeType:VISIBILITY_TYPE andValues:[NSArray arrayWithObject:isVisible]];
    
    [self.noteAttributes setObject:noteAttribute forKey:noteID];
    
    //just save the noteID that has images not the image itself. This is
    //for performance reasons, anytime that an image is needed we will load
    //it from the disk. The dictionary holds noteID and imageFile Path
    
    NSData * noteData = [XoomlParser convertImageNoteToXooml:note];

    NSString * imgName = [XoomlParser getImageFileName: note];
    
    NSString * imgPath = [FileSystemHelper getPathForImageWithName:imgName forNoteName:noteName inBulletinBoard:self.bulletinBoardName];
    
    [self.noteImages setObject:imgPath forKey:noteID];
    //just save the noteID that has images not the image itself. This is
    //for performance reasons, anytime that an image is needed we will load
    //it from the disk. The dictionary holds noteID and imageFileName
    
    
    [self.dataModel addImageNote: noteName 
                 withNoteContent: noteData 
                        andImage: img 
               withImageFileName: imgName
                 toBulletinBoard:self.bulletinBoardName];

    
    
}

-(void) addNoteAttribute: (NSString *) attributeName
         forAttributeType: (NSString *) attributeType
                  forNote: (NSString *) noteID 
                andValues: (NSArray *) values{
    
    //if the noteID is invalid return
    if(![self.noteContents objectForKey:noteID]) return;
    
    //get the noteattributes for the specified note. If there are no attributes for that
    //note create a new bulletinboard attribute list.
    BulletinBoardAttributes * noteAttributes = [self.noteAttributes objectForKey:noteID];
    if(!noteAttributes) noteAttributes = [self createBulletinBoardAttributeForNotes];
    
    //add the note attribute to the attribute list of the notes
    [noteAttributes createAttributeWithName:attributeName forAttributeType:attributeType andValues:values];
    
    //have the delegate reflect the changes in its struture
    [self.delegate addNoteAttribute:attributeName forType:attributeType forNote:noteID withValues:values];
    
}


-(void) addNote: (NSString *) targetNoteID
 toAttributeName: (NSString *) attributeName
forAttributeType: (NSString *) attributeType
          ofNote: (NSString *) sourceNoteId{
    
    //if the targetNoteID and sourceNoteID are invalid return
    if (![self.noteContents objectForKey:targetNoteID] || ![self.noteContents objectForKey:sourceNoteId]) return;
    
    // add the target noteValue to the source notes attribute list
    [[self.noteAttributes objectForKey:sourceNoteId] addValues:[NSArray arrayWithObject:targetNoteID] ToAttribute:attributeName forAttributeType:attributeType];
    
    //have the delegate reflect the changes in its struture
    [self.delegate addNoteAttribute:attributeName forType:attributeType forNote:sourceNoteId withValues:[NSArray arrayWithObject:targetNoteID]];
}

-(void) addBulletinBoardAttribute: (NSString *) attributeName
                  forAttributeType: (NSString *) attributeType{
    //add the attribtue to the bulletinBoard attribute list
    [self.bulletinBoardAttributes createAttributeWithName:attributeName forAttributeType:attributeType];
    
    //have the delegate reflect the change in its structure
    [self.delegate addBulletinBoardAttribute:attributeName forType:attributeType withValues:[NSArray array]];
}

-(void) addNoteWithID:(NSString *)noteID 
toBulletinBoardAttribute:(NSString *)attributeName 
      forAttributeType:(NSString *)attributeType{
    
    //if the noteID is invalid return
    if (![self.noteContents objectForKey:noteID]) return;
    
    //add the noteID to the bulletinboard attribute
    [self.bulletinBoardAttributes addValues:[NSArray arrayWithObject:noteID] ToAttribute:attributeName forAttributeType:attributeType];
    
    //have the delegate reflect the change in its structure
    [self.delegate addBulletinBoardAttribute:attributeName forType:attributeType withValues:[NSArray arrayWithObject:noteID]];
}

/*--------------------------------------------------
 
                        Deletion
 
 -------------------------------------------------*/

-(void) removeNoteWithID:(NSString *)delNoteID{
    
    id <Note> note = [self.noteContents objectForKey:delNoteID];
    //if the note does not exist return
    if (!note) return;
    
    //get Note Name
    //TODO this smells
    NSString *noteName = [[[self.noteAttributes objectForKey:delNoteID] getAttributeWithName:NOTE_NAME forAttributeType:NOTE_NAME_TYPE] lastObject];
    //remove the note content
    [self.noteContents removeObjectForKey:delNoteID];
    
    //remove All the references in the note attributes
    for (NSString * noteID in self.noteAttributes){
        [[self.noteAttributes objectForKey:noteID] removeAllOccurancesOfValue:delNoteID];
    }
    
    //remove all the references in the bulletinboard attributes
    [self.bulletinBoardAttributes removeAllOccurancesOfValue:delNoteID];
    
    //remove all the occurances in the xooml file
    [self.delegate deleteNote:delNoteID];
    [self.dataModel removeNote:noteName FromBulletinBoard:self.bulletinBoardName];
    
    
}

-(void) removeNote: (NSString *) targetNoteID
      fromAttribute: (NSString *) attributeName
             ofType: (NSString *) attributeType
   fromAttributesOf: (NSString *) sourceNoteID{
    
    //if the targetNoteID and sourceNoteID do not exist return
    if (![self.noteContents objectForKey:targetNoteID] || ![self.noteContents objectForKey:sourceNoteID]) return;
    
    //remove the note from note attributes
    [[self.noteAttributes objectForKey:sourceNoteID] removeNote:targetNoteID fromAttribute:attributeName ofType:attributeType fromAttributesOf:sourceNoteID];
    
    //reflect the changes in the xooml structure
    [self.delegate deleteNote:targetNoteID fromNoteAttribute:attributeName ofType:attributeType forNote:sourceNoteID];
}

-(void) removeNoteAttribute: (NSString *) attributeName
                      ofType: (NSString *) attributeType
                    FromNote: (NSString *) noteID{
    //if the noteID is not valid return
    if (![self.noteContents objectForKey:noteID]) return;
    
    //remove the note attribute from the note attribute list
    [[self.noteAttributes objectForKey:noteID] removeAttribute:attributeName forAttributeType:attributeType];
    
    //reflect the change in the xooml structure
    [self.delegate deleteNoteAttribute:attributeName ofType:attributeType fromNote:noteID];
}

-(void) removeNote: (NSString *) noteID
fromBulletinBoardAttribute: (NSString *) attributeName 
             ofType: (NSString *) attributeType{
    
    //if the noteId is not valid return
    if (![self.noteContents objectForKey:noteID]) return;
    
    //remove the note reference from the bulletin board attribute
    [self.bulletinBoardAttributes removeValues: [NSArray arrayWithObject:noteID]
                                 fromAttribute: attributeName
                              forAttributeType: attributeType];
    
    //reflect the change in the xooml structure
    [self.delegate deleteNote:noteID fromBulletinBoardAttribute:attributeName ofType:attributeType];
}

-(void) removeBulletinBoardAttribute:(NSString *)attributeName 
                               ofType:(NSString *)attributeType{
    
    //remove the attribtue from bulletin board attributes
    [self.bulletinBoardAttributes removeAttribute:attributeName forAttributeType:attributeType];
    
    
    //reflect the change in the xooml structure
    [self.delegate deleteBulletinBoardAttribute:attributeName ofType:attributeType];
    
}

/*--------------------------------------------------
 
                        Update
 
 -------------------------------------------------*/

- (void) updateNoteContentOf:(NSString *)noteID 
              withContentsOf:(id<Note>)newNote{
    
    //if noteID is inavlid return
    id <Note> oldNote = [self.noteContents objectForKey:noteID];
    if (!oldNote) return;
    
    //for attributes in newNote that a value is specified
    //update to old note to those values
    if (newNote.noteText) oldNote.noteText = newNote.noteText;
    if (newNote.noteTextID) oldNote.noteTextID = newNote.noteTextID;
    if (newNote.creationDate) oldNote.creationDate = newNote.creationDate;
    if (newNote.modificationDate) oldNote.modificationDate = newNote.modificationDate;
    
    NSData * noteData = [XoomlParser convertNoteToXooml:[self.noteContents objectForKey:noteID]];
    BulletinBoardAttributes * noteAttributes = [self.noteAttributes objectForKey:noteID];
    NSString * noteName = [[noteAttributes getAttributeWithName:NOTE_NAME forAttributeType:NOTE_NAME_TYPE] lastObject];
    
    [self.dataModel updateNote:noteName 
                   withContent:noteData 
               inBulletinBoard:self.bulletinBoardName];
}

//TODO There may be performance penalities for this way of doing an update
- (void) renameNoteAttribute: (NSString *) oldAttributeName 
                      ofType: (NSString *) attributeType
                     forNote: (NSString *) noteID 
                    withName: (NSString *) newAttributeName{
    //if the note does not exist return
    if (![self.noteContents objectForKey:noteID]) return;
    
    //update the note bulletin board
    [[self.noteAttributes objectForKey:noteID] updateAttributeName:oldAttributeName ofType:attributeType withNewName:newAttributeName];
    
    //reflect the changes in the xooml data model
    [self.delegate updateNoteAttribute:oldAttributeName ofType:attributeType forNote:noteID withNewName:newAttributeName];
    
}


-(void) updateNoteProperties:(NSString *)noteID 
              withProperties:(NSDictionary *)newProperties{
    
    if (![self.noteContents objectForKey:noteID]) return;
    
    BulletinBoardAttributes * noteAttribute = [self.noteAttributes objectForKey:noteID];
    
    if([newProperties objectForKey:POSITION_TYPE]){
        NSDictionary * positionProp = [newProperties objectForKey:POSITION_TYPE];
        [noteAttribute updateAttribute:POSITION_X ofType:POSITION_TYPE withNewValue:[positionProp objectForKey:POSITION_X]];
        [noteAttribute updateAttribute:POSITION_Y ofType:POSITION_TYPE withNewValue:[positionProp objectForKey:POSITION_Y]];
        [self.delegate updateNote:noteID withProperties:positionProp];
    }
    


}
-(void) updateNoteAttribute: (NSString *) attributeName
                     ofType:(NSString *) attributeType 
                    forNote: (NSString *) noteID 
              withNewValues: (NSArray *) newValues{
    
    //iif the noteID is not valid return
    if (![self.noteContents objectForKey:noteID]) return;
    
    //update the note attribute values
    [[self.noteAttributes objectForKey:noteID] updateAttribute:attributeName ofType:attributeType withNewValue:newValues];
    
    //reflect the changes in the xooml data model
    [self.delegate updateNoteAttribute:attributeName ofType:attributeType forNote: noteID withValues:newValues];
}

- (void) renameBulletinBoardAttribute: (NSString *) oldAttributeNAme 
                               ofType: (NSString *) attributeType 
                             withName: (NSString *) newAttributeName{
    
    //update the bulletin board attributes
    [self.bulletinBoardAttributes updateAttributeName: oldAttributeNAme ofType:attributeType withNewName:newAttributeName];
    
    //reflect the changes in the xooml data model
    [self.delegate updateBulletinBoardAttributeName:oldAttributeNAme ofType:attributeType withNewName:newAttributeName];
}

/*--------------------------------------------------
 
                        Query
 
 -------------------------------------------------*/

- (NSDictionary *) getAllNotes{
    return [self.noteContents copy];
}
- (NSDictionary *) getAllNoteAttributesForNote: (NSString *) noteID{
    
    BulletinBoardAttributes * noteAttributes = [self.noteAttributes objectForKey:noteID];
    return [noteAttributes getAllAttributes];
}

- (NSDictionary *) getAllBulletinBoardAttributeNamesOfType: (NSString *) attributeType{
    return [self.bulletinBoardAttributes getAllAttributeNamesForAttributeType:attributeType];
}

- (NSDictionary *) getAllNoteAttributeNamesOfType: (NSString *) attributeType
                                     forNote: (NSString *) noteID{
    
    //if the noteID is invalid return
    if (![self.noteContents objectForKey:noteID]) return nil;
    
    return [[self.noteAttributes objectForKey:noteID] getAllAttributeNamesForAttributeType:attributeType];
}

- (id <Note>) getNoteContent: (NSString *) noteID{
    return [self.noteContents objectForKey:noteID];
}

- (NSArray *) getAllNotesBelongingToBulletinBoardAttribute: (NSString *) attributeName 
                                          forAttributeType: (NSString *) attributeType{
    return [self.bulletinBoardAttributes getAttributeWithName:attributeName forAttributeType:attributeType];
}

- (NSArray *) getAllNotesBelongtingToNoteAttribute: (NSString *) attributeName
                                   ofAttributeType: (NSString *) attributeType
                                           forNote: (NSString *) noteID{
    
    //if the noteID is invalid return 
    if (![self.noteContents objectForKey:noteID]) return nil;
    
    return [[self.noteAttributes objectForKey:noteID] getAttributeWithName:attributeName forAttributeType:attributeType];
    
}


/*--------------------------------------------------
 
                    Synchronization
 
 -------------------------------------------------*/

+(void) saveBulletinBoard:(id) bulletinBoard{
    
    if ([bulletinBoard isKindOfClass:[AssociativeBulletinBoard class]]){
        
        AssociativeBulletinBoard * board = (AssociativeBulletinBoard *) bulletinBoard;
            [board.dataModel updateBulletinBoardWithName:board.bulletinBoardName andBulletinBoardInfo:[board.dataSource data]];

    }

}


//TODO Update note name is not provided yet

@end