//
//  XoomlBulletinBoard.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MindcloudCollection.h"
#import "XoomlManifestParser.h"

#import "XoomlCollectionManifest.h"
#import "CallBackDataModel.h"
#import "FileSystemHelper.h"
#import "DropboxDataModel.h"


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

#define ADD_BULLETIN_BOARD_ACTION @"addBulletinBoard"
#define UPDATE_BULLETIN_BOARD_ACTION @"updateBulletinBoard"
#define ADD_NOTE_ACTION @"addNote"
#define UPDATE_NOTE_ACTION @"updateNote"
#define ADD_IMAGE_NOTE_ACTION @"addImage"
#define ACTION_TYPE_CREATE_FOLDER @"createFolder"
#define ACTION_TYPE_UPLOAD_FILE @"uploadFile"


#define SYNCHRONIZATION_PERIOD 2
/*====================================================================*/

@interface MindcloudCollection()

/*
 Holds the actual individual note contents. This dictonary is keyed on the noteID.
 The noteIDs in this dictionary determine whether a note belongs to this bulletin board or not.
 */
@property (nonatomic,strong) NSMutableDictionary * noteContents;
/*
 holds all the attributes that belong to the bulletin board level: for example stack groups. 
 */
@property (nonatomic,strong) CachedCollectionAttributes * bulletinBoardAttributes;
/*
 This is an NSDictionary of BulletinBoardAttributes. Its keyed on the noteIDs.
 For each noteID,  this contains all of the note level attributes that are
 associated with that particular note.
 */
@property (nonatomic,strong) NSMutableDictionary * noteAttributes;
/*
 Keyed on noteID and values are UIImages; 
 */
@property (nonatomic,strong) NSMutableDictionary * noteImages;
/*
 This is the datamodel that the bulletin board uses for retrieval and storage of itself. 
 */
@property (nonatomic,strong) id<CollectionDataSource> dataModel;
/*
 This delegate object provides information for all of the data specific 
 questions that the bulletin baord may ask. 
 
 Properties of the bulletin board are among these data specific questions. 
 */
@property (nonatomic,strong) id <CollectionManifestProtocol> delegate;

@property (nonatomic,strong) id <CollectionManifestProtocol> dataSource;

@property BOOL actionInProgress;
/*--------------------------------------------------
 
 Synchronization Properties
 
 -------------------------------------------------*/

@property int fileCounter;
//this indicates that we need to synchronize
//any action that changes the bulletinBoard data model calls
//this and then nothing else is needed
@property BOOL needSynchronization;

@property NSTimer * timer;

@end

@implementation MindcloudCollection

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
@synthesize fileCounter = _fileCounter;
@synthesize  needSynchronization =
_needSynchronization;
@synthesize  timer = _timer;

-(CachedCollectionAttributes *) bulletinBoardAttributes{
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
-(CachedCollectionAttributes *) createBulletinBoardAttributeForBulletinBoard{
    return [[CachedCollectionAttributes alloc] initWithAttributes:@[STACKING_TYPE,GROUPING_TYPE]];
}

/*
 Factory method for the note bulletin board attributes
 */
-(CachedCollectionAttributes *) createBulletinBoardAttributeForNotes{
    return [[CachedCollectionAttributes alloc] initWithAttributes:@[NOTE_NAME_TYPE,LINKAGE_TYPE,POSITION_TYPE, VISIBILITY_TYPE]];
}

-(id)initEmptyBulletinBoardWithDataModel: (id <CollectionDataSource>) dataModel 
                                 andName:(NSString *) bulletinBoardName{
    
    /*
    if ( [dataModel isKindOfClass:[DropboxDataModel class]]){
        ((DropboxDataModel *) dataModel).actionController = self;
    }
     */
    self = [super init];
    
    self.bulletinBoardName = bulletinBoardName;
    
    self.dataModel = dataModel;
    //if the datamodel requires delegation set your self as the delegate 
    if ([self.dataModel conformsToProtocol:@protocol(CallBackDataModel)]){
        [(id <CallBackDataModel>) self.dataModel setDelegate:self];
        
    }
    
    //create an empty bulletinBoard controller and make it both delegate
    //and the datasource
    id bulletinBoardController = [[XoomlCollectionManifest alloc] initAsEmpty];
    self.dataSource = bulletinBoardController;
    self.delegate = bulletinBoardController;
    
    //initialize the bulletin board attributes with stacking and grouping
    //to add new attributes first define them in the header file and the
    //initilize the bulletinBoardAttributes with an array of them
    
    
    //add an empty bulletinboard to the datamodel
    NSData * bulletinBoardData = [self.dataSource data];
    
    //[self.dataModel addCollectionWithName:bulletinBoardName andContent:bulletinBoardData] ;
    
    
    [self startTimer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bulletinboardDownloaded:)
                                                 name:@"bulletinboardsDownloaded" 
                                               object:nil];
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
    
    id <NoteProtocol> noteObj = [XoomlManifestParser xoomlNoteFromXML:noteData];
    
    if ( !noteObj) return ;
    
    if ([noteObj isKindOfClass:[CollectionNote class]]){
        NSString * imgName = ((CollectionNote *) noteObj).image;
        if (imgName != nil){
            NSString * imgPath = [FileSystemHelper getPathForImageWithName:imgName forNoteName:noteName inBulletinBoard:self.bulletinBoardName];
            if (imgPath != nil && ![imgPath isEqualToString:@""]){
                (self.noteImages)[noteID] = imgPath;
            }
        }
    }
    //now set the note object as a noteContent keyed on its id
    (self.noteContents)[noteID] = noteObj;
    
    //now initialize the bulletinBoard attributes to hold all the 
    //note specific attributes for that note
    CachedCollectionAttributes * noteAttribute = [self createBulletinBoardAttributeForNotes];
    //get the note specific info from the note basic info
    NSDictionary * noteInfo = noteInfos[noteID];
    
    NSString * positionX = noteInfo[POSITION_X];
    if (!positionX ) positionX = DEFAULT_X_POSITION;
    NSString * positionY = noteInfo[POSITION_Y];
    if (!positionY) positionY = DEFAULT_Y_POSITION;
    NSString * isVisible = noteInfo[IS_VISIBLE];
    if (! isVisible) isVisible = DEFAULT_VISIBILITY;
    
    //Fill out the note specific attributes for that note in the bulletin
    //board
    [noteAttribute createAttributeWithName:POSITION_X forAttributeType: POSITION_TYPE andValues:@[positionX]];
    [noteAttribute createAttributeWithName:POSITION_Y forAttributeType:POSITION_TYPE andValues:@[positionY]];
    [noteAttribute createAttributeWithName:IS_VISIBLE forAttributeType:VISIBILITY_TYPE andValues:@[isVisible]];
    [noteAttribute createAttributeWithName:NOTE_NAME forAttributeType: NOTE_NAME_TYPE andValues:@[noteName]];
    
    (self.noteAttributes)[noteID] = noteAttribute;
    
}


-(void) initiateLinkages{
    //For every note in the note content get all the linked notes and 
    //add them to the note attributes only if that referenced notes
    //in that linkage are exisiting in the note contents. 
    for (NSString * noteID in self.noteContents){
        NSDictionary *linkageInfo = [self.delegate getNoteAttributeInfo:LINKAGE_TYPE forNote:noteID];
        for(NSString *linkageName in linkageInfo){
            NSArray * refIDs = linkageInfo[linkageName];
            for (NSString * refID in refIDs){
                if ((self.noteContents)[refID]){
                    [(self.noteAttributes)[noteID] addValues:@[refID] ToAttribute:linkageName forAttributeType:LINKAGE_TYPE];
                }
            }
            
            
        }
    }
    
    
}

-(void) initiateStacking{
    
    //get the stacking information and fill out the stacking attributes
    NSDictionary *stackingInfo = [self.delegate getCollectionAttributeInfo:STACKING_TYPE];
    for (NSString * stackingName in stackingInfo){
        NSArray * refIDs = stackingInfo[stackingName];
        for (NSString * refID in refIDs){
            if(!(self.noteContents)[refIDs]){
                [self.bulletinBoardAttributes addValues:@[refID] ToAttribute:stackingName forAttributeType:STACKING_TYPE];
            }
        }
    }
    
}

-(void) initiateGrouping{
    
    //get the grouping information and fill out the grouping info
    NSDictionary *groupingInfo = [self.delegate getCollectionAttributeInfo:GROUPING_TYPE];
    for (NSString * groupingName in groupingInfo){
        NSArray * refIDs = groupingInfo[groupingName];
        for (NSString * refID in refIDs){
            if(!(self.noteContents)[refIDs]){
                [self.bulletinBoardAttributes addValues:@[refID] ToAttribute:groupingName forAttributeType:GROUPING_TYPE];
            }
        }
    }
    
}

-(id) initBulletinBoardFromXoomlWithDatamodel:(id<CollectionDataSource>)datamodel
                                      andName:(NSString *)bulletinBoardName{
    
    self = [super init];
    
    
    self.dataModel = datamodel;
    /*
    if ( [datamodel isKindOfClass:[DropboxDataModel class]]){
        ((DropboxDataModel *) datamodel).actionController = self;
    }*/
    
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
    NSData * bulletinBoardData = [self.dataModel getCollection:bulletinBoardName];  
    
    //Initialize the bulletinBoard controller to parse and hold the 
    //tree for the bulletin board
    id bulletinBoardController= [[XoomlCollectionManifest alloc]  initWithData:bulletinBoardData];
    
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
        NSString * noteName = noteInfo[noteID][NOTE_NAME];
        NSData * noteData = [self.dataModel getNoteForTheCollection:bulletinBoardName WithName:noteName];
        
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

-(id) initBulletinBoardFromXoomlWithName:(NSString *)bulletinBoardName{
    
    

    
    self = [self initBulletinBoardFromXoomlWithDatamodel:self.dataModel andName:bulletinBoardName];
    
    /*
    if ( [self.dataModel isKindOfClass:[DropboxDataModel class]]){
        ((DropboxDataModel *) self.dataModel).actionController = self;
    }
     */
    //count the number of file to know when the download is finished
    self.fileCounter = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bulletinboardDownloaded:)
                                                 name:@"bulletinboardsDownloaded" 
                                               object:nil];
    [(DropboxDataModel <CallBackDataModel> *) self.dataModel getBulletinBoardAsynch:bulletinBoardName];
    
    //start synchronization timer
    [self startTimer];
    
    return self;
}

/*--------------------------------------------------
 
                        Addition
 
 -------------------------------------------------*/

-(void) addNoteContent: (id <NoteProtocol>) note 
          andProperties: (NSDictionary *) properties{
    
    //get note Name and note ID if they are not present throw an exception
    NSString * noteID = properties[NOTE_ID];
    NSString * noteName = properties[NOTE_NAME];
    if (!noteID || !noteName) [NSException raise:NSInvalidArgumentException
                                          format:@"A Values is missing from the required properties dictionary"];
    
    //set the note content for the noteID
    (self.noteContents)[noteID] = note;
    
    //get other optional properties for the note. 
    //If they are not present use default values
    NSString * positionX = properties[POSITION_X];
    if (!positionX) positionX = DEFAULT_X_POSITION;
    NSString * positionY = properties[POSITION_Y];
    if (!positionY) positionY = DEFAULT_Y_POSITION;
    NSString * isVisible = properties[IS_VISIBLE];
    if(!isVisible) isVisible = DEFAULT_VISIBILITY;
    
    //create a dictionary of note properties
    NSDictionary *noteProperties = @{NOTE_NAME: noteName,
                                    NOTE_ID: noteID,
                                    POSITION_X: positionX,
                                    POSITION_Y: positionY,
                                    IS_VISIBLE: isVisible};
    
    //have the delegate hold the structural information about the note
    [self.delegate addNoteWithID:noteID andProperties:noteProperties];
    
    //have the notes bulletin board attribute list for the note hold the note
    //properties
    CachedCollectionAttributes * noteAttribute = [self createBulletinBoardAttributeForNotes];
    [noteAttribute createAttributeWithName:NOTE_NAME forAttributeType: NOTE_NAME_TYPE andValues:@[noteName]];
    [noteAttribute createAttributeWithName:POSITION_X forAttributeType: POSITION_TYPE andValues:@[positionX]];
    [noteAttribute createAttributeWithName:POSITION_Y forAttributeType:POSITION_TYPE andValues:@[positionY]];
    [noteAttribute createAttributeWithName:IS_VISIBLE forAttributeType:VISIBILITY_TYPE andValues:@[isVisible]];
    
    (self.noteAttributes)[noteID] = noteAttribute;
    
    //update the datamodel
    NSData * noteData = [XoomlManifestParser convertNoteToXooml:note];
    [self.dataModel addNote:noteName withContent:noteData  ToCollection:self.bulletinBoardName];
    
    self.actionInProgress = YES;
    self.needSynchronization = YES;
}

- (void) addImageNoteContent:(id <NoteProtocol> )note 
               andProperties:properties
                    andImage: (NSData *) img{
    //get note Name and note ID if they are not present throw an exception
    NSString * noteID = properties[NOTE_ID];
    NSString * noteName = properties[NOTE_NAME];
    if (!noteID || !noteName) [NSException raise:NSInvalidArgumentException
                                          format:@"A Values is missing from the required properties dictionary"];
    
    //set the note content for the noteID
    (self.noteContents)[noteID] = note;
    
    //get other optional properties for the note. 
    //If they are not present use default values
    NSString * positionX = properties[POSITION_X];
    if (!positionX) positionX = DEFAULT_X_POSITION;
    NSString * positionY = properties[POSITION_Y];
    if (!positionY) positionY = DEFAULT_Y_POSITION;
    NSString * isVisible = properties[IS_VISIBLE];
    if(!isVisible) isVisible = DEFAULT_VISIBILITY;
    
    //create a dictionary of note properties
    NSDictionary *noteProperties = @{NOTE_NAME: noteName,
                                    NOTE_ID: noteID,
                                    POSITION_X: positionX,
                                    POSITION_Y: positionY,
                                    IS_VISIBLE: isVisible};
    
    //have the delegate hold the structural information about the note
    [self.delegate addNoteWithID:noteID andProperties:noteProperties];
    
    //have the notes bulletin board attribute list for the note hold the note
    //properties
    CachedCollectionAttributes * noteAttribute = [self createBulletinBoardAttributeForNotes];
    [noteAttribute createAttributeWithName:NOTE_NAME forAttributeType: NOTE_NAME_TYPE andValues:@[noteName]];
    [noteAttribute createAttributeWithName:POSITION_X forAttributeType: POSITION_TYPE andValues:@[positionX]];
    [noteAttribute createAttributeWithName:POSITION_Y forAttributeType:POSITION_TYPE andValues:@[positionY]];
    [noteAttribute createAttributeWithName:IS_VISIBLE forAttributeType:VISIBILITY_TYPE andValues:@[isVisible]];
    
    (self.noteAttributes)[noteID] = noteAttribute;
    
    //just save the noteID that has images not the image itself. This is
    //for performance reasons, anytime that an image is needed we will load
    //it from the disk. The dictionary holds noteID and imageFile Path
    
    NSData * noteData = [XoomlManifestParser convertImageNoteToXooml:note];

    NSString * imgName = [XoomlManifestParser getImageFileName: note];
    
    NSString * imgPath = [FileSystemHelper getPathForImageWithName:imgName forNoteName:noteName inBulletinBoard:self.bulletinBoardName];
    
    (self.noteImages)[noteID] = imgPath;
    //just save the noteID that has images not the image itself. This is
    //for performance reasons, anytime that an image is needed we will load
    //it from the disk. The dictionary holds noteID and imageFileName
    
    
    [self.dataModel addImageNote: noteName 
                 withNoteContent: noteData 
                        andImage: img 
               withImageFileName: imgName
                 toCollection:self.bulletinBoardName];

    
    self.actionInProgress = YES;
    self.needSynchronization = YES;
    
}

-(void) addNoteAttribute: (NSString *) attributeName
         forAttributeType: (NSString *) attributeType
                  forNote: (NSString *) noteID 
                andValues: (NSArray *) values{
    
    //if the noteID is invalid return
    if(!(self.noteContents)[noteID]) return;
    
    //get the noteattributes for the specified note. If there are no attributes for that
    //note create a new bulletinboard attribute list.
    CachedCollectionAttributes * noteAttributes = (self.noteAttributes)[noteID];
    if(!noteAttributes) noteAttributes = [self createBulletinBoardAttributeForNotes];
    
    //add the note attribute to the attribute list of the notes
    [noteAttributes createAttributeWithName:attributeName forAttributeType:attributeType andValues:values];
    
    //have the delegate reflect the changes in its struture
    [self.delegate addNoteAttribute:attributeName forType:attributeType forNote:noteID withValues:values];
    
    self.needSynchronization = YES;
}


-(void) addNote: (NSString *) targetNoteID
 toAttributeName: (NSString *) attributeName
forAttributeType: (NSString *) attributeType
          ofNote: (NSString *) sourceNoteId{
    
    //if the targetNoteID and sourceNoteID are invalid return
    if (!(self.noteContents)[targetNoteID] || !(self.noteContents)[sourceNoteId]) return;
    
    // add the target noteValue to the source notes attribute list
    [(self.noteAttributes)[sourceNoteId] addValues:@[targetNoteID] ToAttribute:attributeName forAttributeType:attributeType];
    
    //have the delegate reflect the changes in its struture
    [self.delegate addNoteAttribute:attributeName forType:attributeType forNote:sourceNoteId withValues:@[targetNoteID]];
    
    self.needSynchronization = YES;
}

-(void) addBulletinBoardAttribute: (NSString *) attributeName
                  forAttributeType: (NSString *) attributeType{
    //add the attribtue to the bulletinBoard attribute list
    [self.bulletinBoardAttributes createAttributeWithName:attributeName forAttributeType:attributeType];
    
    //have the delegate reflect the change in its structure
    [self.delegate addCollectionAttribute:attributeName forType:attributeType withValues:@[]];
}

-(void) addNoteWithID:(NSString *)noteID 
toBulletinBoardAttribute:(NSString *)attributeName 
      forAttributeType:(NSString *)attributeType{
    
    //if the noteID is invalid return
    if (!(self.noteContents)[noteID]) return;
    
    //add the noteID to the bulletinboard attribute
    [self.bulletinBoardAttributes addValues:@[noteID] ToAttribute:attributeName forAttributeType:attributeType];
    
    //have the delegate reflect the change in its structure
    [self.delegate addCollectionAttribute:attributeName forType:attributeType withValues:@[noteID]];
    
    self.needSynchronization = YES;
}

/*--------------------------------------------------
 
                        Deletion
 
 -------------------------------------------------*/

-(void) removeNoteWithID:(NSString *)delNoteID{
    
    id <NoteProtocol> note = (self.noteContents)[delNoteID];
    //if the note does not exist return
    if (!note) return;
    
    //get Note Name
    //TODO this smells
    NSString *noteName = [[(self.noteAttributes)[delNoteID] getAttributeWithName:NOTE_NAME forAttributeType:NOTE_NAME_TYPE] lastObject];
    //remove the note content
    [self.noteContents removeObjectForKey:delNoteID];
    
    //remove All the references in the note attributes
    for (NSString * noteID in self.noteAttributes){
        [(self.noteAttributes)[noteID] removeAllOccurancesOfValue:delNoteID];
    }
    
    //remove all the references in the bulletinboard attributes
    [self.bulletinBoardAttributes removeAllOccurancesOfValue:delNoteID];
    
    //remove all the occurances in the xooml file
    [self.delegate deleteNote:delNoteID];
    [self.dataModel removeNote:noteName FromCollection:self.bulletinBoardName];
    
    self.actionInProgress = YES;
    self.needSynchronization = true;
    
}

-(void) removeNote: (NSString *) targetNoteID
      fromAttribute: (NSString *) attributeName
             ofType: (NSString *) attributeType
   fromAttributesOf: (NSString *) sourceNoteID{
    
    //if the targetNoteID and sourceNoteID do not exist return
    if (!(self.noteContents)[targetNoteID] || !(self.noteContents)[sourceNoteID]) return;
    
    //remove the note from note attributes
    [(self.noteAttributes)[sourceNoteID] removeNote:targetNoteID fromAttribute:attributeName ofType:attributeType fromAttributesOf:sourceNoteID];
    
    //reflect the changes in the xooml structure
    [self.delegate deleteNote:targetNoteID fromNoteAttribute:attributeName ofType:attributeType forNote:sourceNoteID];
    
    self.needSynchronization = YES;
}

-(void) removeNoteAttribute: (NSString *) attributeName
                      ofType: (NSString *) attributeType
                    FromNote: (NSString *) noteID{
    //if the noteID is not valid return
    if (!(self.noteContents)[noteID]) return;
    
    //remove the note attribute from the note attribute list
    [(self.noteAttributes)[noteID] removeAttribute:attributeName forAttributeType:attributeType];
    
    //reflect the change in the xooml structure
    [self.delegate deleteNoteAttribute:attributeName ofType:attributeType fromNote:noteID];
    
    self.needSynchronization = YES;
}

-(void) removeNote: (NSString *) noteID
fromBulletinBoardAttribute: (NSString *) attributeName 
             ofType: (NSString *) attributeType{
    
    //if the noteId is not valid return
    if (!(self.noteContents)[noteID]) return;
    
    //remove the note reference from the bulletin board attribute
    [self.bulletinBoardAttributes removeValues: @[noteID]
                                 fromAttribute: attributeName
                              forAttributeType: attributeType];
    
    //reflect the change in the xooml structure
    [self.delegate deleteNote:noteID fromCollectionAttribute:attributeName ofType:attributeType];
    
    
    self.needSynchronization = YES;
}

-(void) removeBulletinBoardAttribute:(NSString *)attributeName 
                               ofType:(NSString *)attributeType{
    
    //remove the attribtue from bulletin board attributes
    [self.bulletinBoardAttributes removeAttribute:attributeName forAttributeType:attributeType];
    
    
    //reflect the change in the xooml structure
    [self.delegate deleteCollectionAttribute:attributeName ofType:attributeType];
    
    
    self.needSynchronization = YES;
}

/*--------------------------------------------------
 
                        Update
 
 -------------------------------------------------*/

- (void) updateNoteContentOf:(NSString *)noteID 
              withContentsOf:(id<NoteProtocol>)newNote{
    
    //if noteID is inavlid return
    id <NoteProtocol> oldNote = (self.noteContents)[noteID];
    if (!oldNote) return;
    
    //for attributes in newNote that a value is specified
    //update to old note to those values
    if (newNote.noteText) oldNote.noteText = newNote.noteText;
    if (newNote.noteTextID) oldNote.noteTextID = newNote.noteTextID;
    if (newNote.creationDate) oldNote.creationDate = newNote.creationDate;
    if (newNote.modificationDate) oldNote.modificationDate = newNote.modificationDate;
    
    NSData * noteData = [XoomlManifestParser convertNoteToXooml:(self.noteContents)[noteID]];
    CachedCollectionAttributes * noteAttributes = (self.noteAttributes)[noteID];
    NSString * noteName = [[noteAttributes getAttributeWithName:NOTE_NAME forAttributeType:NOTE_NAME_TYPE] lastObject];
    
    [self.dataModel updateNote:noteName 
                   withContent:noteData 
               inCollection:self.bulletinBoardName];
}

//TODO There may be performance penalities for this way of doing an update
- (void) renameNoteAttribute: (NSString *) oldAttributeName 
                      ofType: (NSString *) attributeType
                     forNote: (NSString *) noteID 
                    withName: (NSString *) newAttributeName{
    //if the note does not exist return
    if (!(self.noteContents)[noteID]) return;
    
    //update the note bulletin board
    [(self.noteAttributes)[noteID] updateAttributeName:oldAttributeName ofType:attributeType withNewName:newAttributeName];
    
    //reflect the changes in the xooml data model
    [self.delegate updateNoteAttribute:oldAttributeName ofType:attributeType forNote:noteID withNewName:newAttributeName];
    
    
    self.needSynchronization = YES;
}


-(void) updateNoteAttributes:(NSString *)noteID 
              withAttributes:(NSDictionary *)newProperties{
    
    if (!(self.noteContents)[noteID]) return;
    
    CachedCollectionAttributes * noteAttribute = (self.noteAttributes)[noteID];
    
    if(newProperties[POSITION_TYPE]){
        NSDictionary * positionProp = newProperties[POSITION_TYPE];
        [noteAttribute updateAttribute:POSITION_X ofType:POSITION_TYPE withNewValue:positionProp[POSITION_X]];
        [noteAttribute updateAttribute:POSITION_Y ofType:POSITION_TYPE withNewValue:positionProp[POSITION_Y]];
        [self.delegate updateNote:noteID withProperties:positionProp];
    }
    

    self.needSynchronization = YES;
    
}
-(void) updateNoteAttribute: (NSString *) attributeName
                     ofType:(NSString *) attributeType 
                    forNote: (NSString *) noteID 
              withNewValues: (NSArray *) newValues{
    
    //iif the noteID is not valid return
    if (!(self.noteContents)[noteID]) return;
    
    //update the note attribute values
    [(self.noteAttributes)[noteID] updateAttribute:attributeName ofType:attributeType withNewValue:newValues];
    
    //reflect the changes in the xooml data model
    [self.delegate updateNoteAttribute:attributeName ofType:attributeType forNote: noteID withValues:newValues];
    
    self.needSynchronization = YES;

}

- (void) renameBulletinBoardAttribute: (NSString *) oldAttributeNAme 
                               ofType: (NSString *) attributeType 
                             withName: (NSString *) newAttributeName{
    
    //update the bulletin board attributes
    [self.bulletinBoardAttributes updateAttributeName: oldAttributeNAme ofType:attributeType withNewName:newAttributeName];
    
    //reflect the changes in the xooml data model
    [self.delegate updateCollectionAttributeName:oldAttributeNAme ofType:attributeType withNewName:newAttributeName];
    
    self.needSynchronization = YES;
}

/*--------------------------------------------------
 
                        Query
 
 -------------------------------------------------*/

- (NSDictionary *) getAllNotes{
    return [self.noteContents copy];
}
- (NSDictionary *) getAllNoteAttributesForNote: (NSString *) noteID{
    
    CachedCollectionAttributes * noteAttributes = (self.noteAttributes)[noteID];
    return [noteAttributes getAllAttributes];
}

- (NSDictionary *) getAllBulletinBoardAttributeNamesOfType: (NSString *) attributeType{
    return [self.bulletinBoardAttributes getAllAttributeNamesForAttributeType:attributeType];
}

- (NSDictionary *) getAllNoteAttributeNamesOfType: (NSString *) attributeType
                                     forNote: (NSString *) noteID{
    
    //if the noteID is invalid return
    if (!(self.noteContents)[noteID]) return nil;
    
    return [(self.noteAttributes)[noteID] getAllAttributeNamesForAttributeType:attributeType];
}

- (id <NoteProtocol>) getNoteContent: (NSString *) noteID{
    return (self.noteContents)[noteID];
}

- (NSArray *) getAllNotesBelongingToBulletinBoardAttribute: (NSString *) attributeName 
                                          forAttributeType: (NSString *) attributeType{
    return [self.bulletinBoardAttributes getAttributeWithName:attributeName forAttributeType:attributeType];
}

- (NSArray *) getAllNotesBelongtingToNoteAttribute: (NSString *) attributeName
                                   ofAttributeType: (NSString *) attributeType
                                           forNote: (NSString *) noteID{
    
    //if the noteID is invalid return 
    if (!(self.noteContents)[noteID]) return nil;
    
    return [(self.noteAttributes)[noteID] getAttributeWithName:attributeName forAttributeType:attributeType];
    
}

-(NSDictionary *) getAllNoteImages{
    
    NSMutableDictionary * images = [[NSMutableDictionary alloc] init];
    for (NSString * noteID in self.noteImages){
        
        NSString * imgPath = (self.noteImages)[noteID];
        NSData * imgData = [self getImageDataForPath:imgPath];
        if (imgData != nil){
            images[noteID] = imgData;
        }
    }
    return images;
}


/*--------------------------------------------------
 
                    Synchronization
 
 -------------------------------------------------*/

+(void) saveBulletinBoard:(id) bulletinBoard{
    
    if ([bulletinBoard isKindOfClass:[MindcloudCollection class]]){
        
        MindcloudCollection * board = (MindcloudCollection *) bulletinBoard;
            [board.dataModel updateCollectionWithName:board.bulletinBoardName andContent:[board.dataSource data]];

    }

}


/*--------------------------------------------------
 
 Synchronization
 
 -------------------------------------------------*/

/*
 Every SYNCHRONIZATION_PERIOD seconds we try to synchrnoize. 
 If the synchronize flag is set the bulletin board is updated from
 the internal datastructures.
 
 
 */


-(void) startTimer{
    [NSTimer scheduledTimerWithTimeInterval: SYNCHRONIZATION_PERIOD 
                                     target:self 
                                   selector:@selector(synchronize:) 
                                   userInfo:nil 
                                    repeats:YES];
}

-(void) stopTimer{
    [self.timer invalidate];
}

-(void) synchronize:(NSTimer *) timer{
    
//    NSLog(@"Periodic Queue: %@",((DropboxDataModel *) self.dataModel).actions);
    if (self.actionInProgress){
        NSLog(@"Synchronization postponed due to an unfinished or failed action");
        return;
    }
    if (self.needSynchronization){
        NSLog(@"==================");
        NSLog(@"Synchronizing");
        
        NSLog(@"Synchronization queue: ");
        NSLog(@"%@", ((DropboxDataModel *) self.dataModel).actions);
        self.needSynchronization = NO;
        
       // self.actionInProgress = YES;
        [MindcloudCollection saveBulletinBoard: self];
    }
}


/*
 This methods completely initiates the bulletin board. 
 When this method is called it assumes that the bulletinboard data has been downloadded to disk so it uses disk to initiate itself. 
 */
#define NOTE_NAME @"name"
-(void) initiateBulletinBoad{
    
    NSData * bulletinBoardData = [self getBulletinBoardData];
    id bulletinBoardController= [[XoomlCollectionManifest alloc]  initWithData:bulletinBoardData];
    
    //Make the bulletinboard controller the datasource and delegate
    //for the bulletin board so the bulletin board can structural and
    //data centric questions from it.
    self.dataSource = bulletinBoardController;
    self.delegate = bulletinBoardController;
    
    //Now start to initialize the bulletin board attributes one by one
    //from the delegate.
    
    NSDictionary * noteInfo = [self.delegate getAllNoteBasicInfo];
    
    //set up note contents
    for(NSString * noteID in noteInfo){
        
        //for each note create a note Object by reading its separate xooml files
        //from the data model
        NSString * noteName = noteInfo[noteID][NOTE_NAME];
        NSData * noteData = [self getNoteDataForNote:noteName];
        
        [self initiateNoteContent:noteData
                        forNoteID:noteID
                          andName:noteName
                    andProperties:noteInfo];
    }
    
    NSLog(@"Note Content Initiated");
    NSLog(@"-----------------------");
    //initiate Linkages
    NSLog(@"-----------------------");
    [self initiateLinkages];
    NSLog(@"Linkages initiated");
    NSLog(@"-----------------------");
    //initiate stacking
    [self initiateStacking];
    NSLog(@"Stacking initiated");
    NSLog(@"-----------------------");
    //initiate grouping
    [self initiateGrouping];
    NSLog(@"Grouping initiated");
    NSLog(@"-----------------------");
    
    
    //send notification to the notification objects 
    //so interested objects can see that the bulletinboard is loaded
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BulletinBoardLoaded"
                                                        object:self];
    
}


/*--------------------------------------------------
 
Notification
 
 -------------------------------------------------*/

-(void)bulletinboardDownloaded: (NSNotification *) notification{
    
    [self initiateBulletinBoad];
}

//TODO Update note name is not provided yet

/*--------------------------------------------------
 
 Query
 
 -------------------------------------------------*/

-(NSData *) getBulletinBoardData{
    
    NSString * path = [FileSystemHelper getPathForBulletinBoardWithName:self.bulletinBoardName];
    NSError * err;
    NSString *data = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    if (!data){
        NSLog(@"Failed to read file from disk: %@", err);
        return nil;
    }
    
    NSLog(@"BulletinBoard : %@ read successful", self.bulletinBoardName);
    
    return [data dataUsingEncoding:NSUTF8StringEncoding];
    
}

-(NSData *) getNoteDataForNote: (NSString *) noteName{
    
    
    NSString * path = [FileSystemHelper getPathForNoteWithName:noteName inBulletinBoardWithName:self.bulletinBoardName];
    NSError * err;
    NSString *data = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    if (!data){
        NSLog(@"Failed to read  note file from disk: %@", err);
        return nil;
    }
    
    NSLog(@"Note: %@ read Successful", noteName);
    
    return [data dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSData *) getImageDataForPath: (NSString *) path{
    NSError * err;
    NSData * data = [NSData dataWithContentsOfFile:path];
    if (!data){
        NSLog(@"Failed to read  image %@ ile from disk: %@", path,err);
        return nil;
    }
    
    NSLog(@"image: %@ read Successful", [path lastPathComponent]);
    
    return data;
    
}


/*-------------------------------------------
 
 Clean up
 -------------------------------------------*/

-(void) cleanUp{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end