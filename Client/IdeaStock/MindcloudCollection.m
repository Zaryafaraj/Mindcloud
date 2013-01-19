//
//  XoomlBulletinBoard.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MindcloudCollection.h"
#import "XoomlCollectionParser.h"

#import "XoomlCollectionManifest.h"
#import "FileSystemHelper.h"
#import "EventTypes.h"

#pragma mark - Definitions
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
 The datasource is connected to the mindcloud servers and can be viewed as the expensive
 permenant storage
 */
@property (nonatomic,strong) id<MindcloudDataSource> dataSource;
/*
 The manifest of the loaded collection
 */
@property (nonatomic,strong) id <CollectionManifestProtocol> manifest;

/*
 determines the number of files that need to be downloaded during initialization
 probably I can make this a local var
 */
@property int fileCounter;
/*
 this indicates that we need to synchronize
 any action that changes the bulletinBoard data model calls
 this and then nothing else is needed
 */
@property BOOL needSynchronization;
/*
 Synchronization Timer
 */
@property NSTimer * timer;

@end

@implementation MindcloudCollection

#pragma mark - synthesis
@synthesize noteAttributes = _noteAttributes;
@synthesize bulletinBoardAttributes = _bulletinBoardAttributes;
@synthesize noteContents = _noteContents;
@synthesize bulletinBoardName = _bulletinBoardName;
@synthesize noteImages = _noteImages;

-(CachedCollectionAttributes *) bulletinBoardAttributes{
    if (!_bulletinBoardAttributes){
        
        _bulletinBoardAttributes = [[CachedCollectionAttributes alloc]
                                    initWithAttributes:@[STACKING_TYPE,GROUPING_TYPE]];
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

#pragma mark - Initialization
-(id) initCollection:(NSString *)collectionName
      withDataSource:(id<MindcloudDataSource>)dataSource
{
    self = [super init];
    self.dataSource = dataSource;
    self.bulletinBoardName = collectionName;
    //now ask to download and get the collection
    NSData * collectionData = [self.dataSource getCollection:collectionName];
    //If there is a partial collection on the disk from previous usage use that
    //temporarily until its updated. Note that getCollection takes care of the
    //update
    if (collectionData == nil)
    {
        self.manifest = [[XoomlCollectionManifest alloc] initAsEmpty];
    }
    else
    {
        [self loadCollection:collectionData];
    }
    
    //In any case listen for the download to get finished
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(collectionFilesDownloaded:)
                                                 name:COLLECTION_DOWNLOADED_EVENT
                                               object:nil];
    //Start the synchronization timer
    [self startTimer];
    return self;
}

-(void) collectionFilesDownloaded: (NSNotification *) notification{
    NSData * bulletinBoardData = [self.dataSource getCollection:self.bulletinBoardName];
    if (!bulletinBoardData)
    {
        NSLog(@"Collection Files haven't been downloaded properly");
        return;
    }
    self.manifest = [[XoomlCollectionManifest alloc]  initWithData:bulletinBoardData];
    
    //get notes from manifest and initalize those
    NSDictionary * noteInfo = [self.manifest getAllNoteBasicInfo];
    for(NSString * noteID in noteInfo){
        
        //for each note create a note Object by reading its separate xooml files
        //from the data model
        NSString * noteName = noteInfo[noteID][NOTE_NAME];
        NSData * noteData = [self.dataSource getNoteForTheCollection:self.bulletinBoardName
                                                            WithName:noteName];
        if (!noteData)
        {
            NSLog(@"Could not retreive note data from dataSource");
        }
        else
        {
            [self initiateNoteContent:noteData
                            forNoteID:noteID
                              andName:noteName
                        andProperties:noteInfo];
        }
        
    }
    
    [self initiateStacking];
    NSLog(@"Notes Initiated");
    //Let any listener know that the bulletinboard has been reloaded
    [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTION_RELOAD_EVENT
                                                        object:self];
}

-(void) loadCollection:(NSData *) bulletinBoardData{
    
    if (!bulletinBoardData)
    {
        NSLog(@"Collection Files haven't been downloaded properly");
        return;
    }
    self.manifest = [[XoomlCollectionManifest alloc]  initWithData:bulletinBoardData];
    
    //get notes from manifest and initalize those
    NSDictionary * noteInfo = [self.manifest getAllNoteBasicInfo];
    for(NSString * noteID in noteInfo){
        
        //for each note create a note Object by reading its separate xooml files
        //from the data model
        NSString * noteName = noteInfo[noteID][NOTE_NAME];
        NSData * noteData = [self.dataSource getNoteForTheCollection:self.bulletinBoardName
                                                            WithName:noteName];
        if (!noteData)
        {
            NSLog(@"Could not retreive note data from dataSource");
        }
        else
        {
            [self initiateNoteContent:noteData
                            forNoteID:noteID
                              andName:noteName
                        andProperties:noteInfo];
        }
        
    }
    
    [self initiateStacking];
    NSLog(@"Notes Initiated");
    //Let any listener know that the bulletinboard has been reloaded
    [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTION_RELOAD_EVENT
                                                        object:self];
}

-(void) initiateNoteContent: (NSData *) noteData
                  forNoteID: (NSString *) noteID
                    andName: (NSString *) noteName
              andProperties: (NSDictionary *) noteInfos{
    
    id <NoteProtocol> noteObj = [XoomlCollectionParser xoomlNoteFromXML:noteData];
    if (!noteObj) return ;
    
    (self.noteContents)[noteID] = noteObj;
    //note could have an image or not. If it has an image we have to also add it to note images
    NSString * imgName = noteObj.image;
    if (imgName != nil)
    {
        NSString * imgPath = [FileSystemHelper getPathForNoteImageforNoteName:noteName
                                                   inBulletinBoard:self.bulletinBoardName];
        if (imgPath != nil && ![imgPath isEqualToString:@""])
        {
            (self.noteImages)[noteID] = imgPath;
        }
    }
    
    //cache the note specific attributes
    NSDictionary * noteInfo = noteInfos[noteID];
    NSString * positionX = noteInfo[POSITION_X];
    if (!positionX ) positionX = DEFAULT_X_POSITION;
    NSString * positionY = noteInfo[POSITION_Y];
    if (!positionY) positionY = DEFAULT_Y_POSITION;
    NSString * isVisible = noteInfo[IS_VISIBLE];
    if (! isVisible) isVisible = DEFAULT_VISIBILITY;
    
    CachedCollectionAttributes * noteAttribute = [self createBulletinBoardAttributeForNotes];
    [noteAttribute createAttributeWithName:POSITION_X
                          forAttributeType: POSITION_TYPE
                                 andValues:@[positionX]];
    [noteAttribute createAttributeWithName:POSITION_Y
                          forAttributeType:POSITION_TYPE
                                 andValues:@[positionY]];
    [noteAttribute createAttributeWithName:IS_VISIBLE
                          forAttributeType:VISIBILITY_TYPE
                                 andValues:@[isVisible]];
    [noteAttribute createAttributeWithName:NOTE_NAME
                          forAttributeType: NOTE_NAME_TYPE
                                 andValues:@[noteName]];
    (self.noteAttributes)[noteID] = noteAttribute;
}


-(void) initiateLinkages{
    //For every note in the note content get all the linked notes and cache them
    for (NSString * noteID in self.noteContents)
    {
        NSDictionary *linkageInfo = [self.manifest getNoteAttributeInfo:LINKAGE_TYPE forNote:noteID];
        for(NSString *linkageName in linkageInfo)
        {
            NSArray * refIDs = linkageInfo[linkageName];
            for (NSString * refID in refIDs)
            {
                if ((self.noteContents)[refID])
                {
                    [(self.noteAttributes)[noteID] addValues:@[refID]
                                                 ToAttribute:linkageName
                                            forAttributeType:LINKAGE_TYPE];
                }
            }
        }
    }
}

-(void) initiateStacking{
    //get the stacking information and cache them
    NSDictionary *stackingInfo = [self.manifest getCollectionAttributeInfo:STACKING_TYPE];
    for (NSString * stackingName in stackingInfo)
    {
        NSArray * refIDs = stackingInfo[stackingName];
        for (NSString * refID in refIDs)
        {
            if(!(self.noteContents)[refIDs])
            {
                [self.bulletinBoardAttributes addValues:@[refID] ToAttribute:stackingName forAttributeType:STACKING_TYPE];
            }
        }
    }
}

-(void) initiateGrouping{
    //get the grouping information and cache them
    NSDictionary *groupingInfo = [self.manifest getCollectionAttributeInfo:GROUPING_TYPE];
    for (NSString * groupingName in groupingInfo)
    {
        NSArray * refIDs = groupingInfo[groupingName];
        for (NSString * refID in refIDs)
        {
            if(!(self.noteContents)[refIDs])
            {
                [self.bulletinBoardAttributes addValues:@[refID] ToAttribute:groupingName forAttributeType:GROUPING_TYPE];
            }
        }
    }
}

#pragma mark - Creation

-(void) addNoteContent: (id <NoteProtocol>) note
         andProperties: (NSDictionary *) properties{
    
    NSString * noteID = properties[NOTE_ID];
    NSString * noteName = properties[NOTE_NAME];
    if (!noteID || !noteName) [NSException raise:NSInvalidArgumentException
                                          format:@"A Values is missing from the required properties dictionary"];
    (self.noteContents)[noteID] = note;
    
    NSString * positionX = properties[POSITION_X];
    NSString * positionY = properties[POSITION_Y];
    NSString * isVisible = properties[IS_VISIBLE];
    if (!positionX) positionX = DEFAULT_X_POSITION;
    if (!positionY) positionY = DEFAULT_Y_POSITION;
    if (!isVisible) isVisible = DEFAULT_VISIBILITY;
    NSDictionary *noteProperties = @{NOTE_NAME: noteName,
                                     NOTE_ID: noteID,
                                     POSITION_X: positionX,
                                     POSITION_Y: positionY,
                                     IS_VISIBLE: isVisible};
    
    [self.manifest addNoteWithID:noteID andProperties:noteProperties];
    
    CachedCollectionAttributes * noteAttribute = [self createBulletinBoardAttributeForNotes];
    [noteAttribute createAttributeWithName:NOTE_NAME
                          forAttributeType:NOTE_NAME_TYPE
                                 andValues:@[noteName]];
    [noteAttribute createAttributeWithName:POSITION_X
                          forAttributeType: POSITION_TYPE
                                 andValues:@[positionX]];
    [noteAttribute createAttributeWithName:POSITION_Y
                          forAttributeType:POSITION_TYPE
                                 andValues:@[positionY]];
    [noteAttribute createAttributeWithName:IS_VISIBLE
                          forAttributeType:VISIBILITY_TYPE
                                 andValues:@[isVisible]];
    (self.noteAttributes)[noteID] = noteAttribute;
    
    NSData * noteData = [XoomlCollectionParser convertNoteToXooml:note];
    [self.dataSource addNote:noteName withContent:noteData  ToCollection:self.bulletinBoardName];
    
    self.needSynchronization = YES;
}

- (void) addImageNoteContent:(id <NoteProtocol> )note
               andProperties:properties
                    andImage: (NSData *) img{
    
    NSString * noteID = properties[NOTE_ID];
    NSString * noteName = properties[NOTE_NAME];
    if (!noteID || !noteName) [NSException raise:NSInvalidArgumentException
                                          format:@"A Values is missing from the required properties dictionary"];
    
    (self.noteContents)[noteID] = note;
    
    NSString * positionX = properties[POSITION_X];
    NSString * positionY = properties[POSITION_Y];
    NSString * isVisible = properties[IS_VISIBLE];
    if (!positionY) positionY = DEFAULT_Y_POSITION;
    if (!positionX) positionX = DEFAULT_X_POSITION;
    if(!isVisible) isVisible = DEFAULT_VISIBILITY;
    NSDictionary *noteProperties = @{NOTE_NAME: noteName,
                                     NOTE_ID: noteID,
                                     POSITION_X: positionX,
                                     POSITION_Y: positionY,
                                     IS_VISIBLE: isVisible};
    [self.manifest addNoteWithID:noteID andProperties:noteProperties];
    
    CachedCollectionAttributes * noteAttribute = [self createBulletinBoardAttributeForNotes];
    [noteAttribute createAttributeWithName:NOTE_NAME
                          forAttributeType:NOTE_NAME_TYPE
                                 andValues:@[noteName]];
    [noteAttribute createAttributeWithName:POSITION_X
                          forAttributeType:POSITION_TYPE
                                 andValues:@[positionX]];
    [noteAttribute createAttributeWithName:POSITION_Y
                          forAttributeType:POSITION_TYPE
                                 andValues:@[positionY]];
    [noteAttribute createAttributeWithName:IS_VISIBLE
                          forAttributeType:VISIBILITY_TYPE
                                 andValues:@[isVisible]];
    (self.noteAttributes)[noteID] = noteAttribute;
    
    //just save the noteID that has images not the image itself. This is
    //for performance reasons, anytime that an image is needed we will load
    //it from the disk. The dictionary holds noteID and imageFile Path
    NSData * noteData = [XoomlCollectionParser convertImageNoteToXooml:note];
    NSString * imgName = [XoomlCollectionParser getXoomlImageReference: note];
    NSString * imgPath = [FileSystemHelper getPathForNoteImageforNoteName:noteName
                                                          inBulletinBoard:self.bulletinBoardName];
    (self.noteImages)[noteID] = imgPath;
    
    [self.dataSource addImageNote: noteName
                  withNoteContent: noteData
                         andImage: img
                withImageFileName: imgName
                     toCollection:self.bulletinBoardName];
    
    self.needSynchronization = YES;
}

-(void) addNoteAttribute: (NSString *) attributeName
        forAttributeType: (NSString *) attributeType
                 forNote: (NSString *) noteID
               andValues: (NSArray *) values{
    
    if(!(self.noteContents)[noteID]) return;
    
    //get the noteattributes for the specified note. If there are no attributes for that
    //note create a new bulletinboard attribute list.
    CachedCollectionAttributes * noteAttributes = (self.noteAttributes)[noteID];
    if(!noteAttributes) noteAttributes = [self createBulletinBoardAttributeForNotes];
    [noteAttributes createAttributeWithName:attributeName
                           forAttributeType:attributeType
                                  andValues:values];
    
    [self.manifest addNoteAttribute:attributeName
                            forType:attributeType
                            forNote:noteID withValues:values];
    
    self.needSynchronization = YES;
}


-(void) addNote: (NSString *) targetNoteID
toAttributeName: (NSString *) attributeName
forAttributeType: (NSString *) attributeType
         ofNote: (NSString *) sourceNoteId{
    
    if (!(self.noteContents)[targetNoteID] || !(self.noteContents)[sourceNoteId]) return;
    
    // add the target noteValue to the source notes attribute list
    [(self.noteAttributes)[sourceNoteId] addValues:@[targetNoteID]
                                       ToAttribute:attributeName
                                  forAttributeType:attributeType];
    
    [self.manifest addNoteAttribute:attributeName
                            forType:attributeType
                            forNote:sourceNoteId
                         withValues:@[targetNoteID]];
    
    self.needSynchronization = YES;
}

-(void) addBulletinBoardAttribute: (NSString *) attributeName
                 forAttributeType: (NSString *) attributeType{
    
    [self.bulletinBoardAttributes createAttributeWithName:attributeName
                                         forAttributeType:attributeType];
    
    [self.manifest addCollectionAttribute:attributeName
                                  forType:attributeType
                               withValues:@[]];
}

-(void) addNoteWithID:(NSString *)noteID
toBulletinBoardAttribute:(NSString *)attributeName
     forAttributeType:(NSString *)attributeType{
    
    if (!(self.noteContents)[noteID]) return;
    
    [self.bulletinBoardAttributes addValues:@[noteID]
                                ToAttribute:attributeName
                           forAttributeType:attributeType];
    
    [self.manifest addCollectionAttribute:attributeName
                                  forType:attributeType
                               withValues:@[noteID]];
    
    self.needSynchronization = YES;
}

#pragma mark - Deletion

-(void) removeNoteWithID:(NSString *)delNoteID{
    
    id <NoteProtocol> note = (self.noteContents)[delNoteID];
    if (!note) return;
    
    [self.noteContents removeObjectForKey:delNoteID];
    
    //remove all the references to the note
    for (NSString * noteID in self.noteAttributes){
        [(self.noteAttributes)[noteID] removeAllOccurancesOfValue:delNoteID];
    }
    [self.bulletinBoardAttributes removeAllOccurancesOfValue:delNoteID];
    
    [self.manifest deleteNote:delNoteID];
    
    NSString *noteName = [[(self.noteAttributes)[delNoteID]
                           getAttributeWithName:NOTE_NAME
                           forAttributeType:NOTE_NAME_TYPE] lastObject];
    [self.dataSource removeNote:noteName
                 FromCollection:self.bulletinBoardName];
    
    self.needSynchronization = true;
}

-(void) removeNote: (NSString *) targetNoteID
     fromAttribute: (NSString *) attributeName
            ofType: (NSString *) attributeType
  fromAttributesOf: (NSString *) sourceNoteID{
    
    if (!(self.noteContents)[targetNoteID] || !(self.noteContents)[sourceNoteID]) return;
    
    [(self.noteAttributes)[sourceNoteID] removeNote:targetNoteID
                                      fromAttribute:attributeName
                                             ofType:attributeType
                                   fromAttributesOf:sourceNoteID];
    
    [self.manifest deleteNote:targetNoteID
            fromNoteAttribute:attributeName
                       ofType:attributeType
                      forNote:sourceNoteID];
    
    self.needSynchronization = YES;
}

-(void) removeNoteAttribute: (NSString *) attributeName
                     ofType: (NSString *) attributeType
                   FromNote: (NSString *) noteID{
    
    if (!(self.noteContents)[noteID]) return;
    
    [(self.noteAttributes)[noteID] removeAttribute:attributeName
                                  forAttributeType:attributeType];
    
    [self.manifest deleteNoteAttribute:attributeName
                                ofType:attributeType
                              fromNote:noteID];
    
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
    [self.manifest deleteNote:noteID fromCollectionAttribute:attributeName ofType:attributeType];
    
    
    self.needSynchronization = YES;
}

-(void) removeBulletinBoardAttribute:(NSString *)attributeName
                              ofType:(NSString *)attributeType{
    
    [self.bulletinBoardAttributes removeAttribute:attributeName
                                 forAttributeType:attributeType];
    
    [self.manifest deleteCollectionAttribute:attributeName ofType:attributeType];
    
    self.needSynchronization = YES;
}

#pragma mark - Update

- (void) updateNoteContentOf:(NSString *)noteID
              withContentsOf:(id<NoteProtocol>)newNote{
    
    id <NoteProtocol> oldNote = (self.noteContents)[noteID];
    if (!oldNote) return;
    
    //for attributes in newNote that a value is specified; update those
    if (newNote.noteText) oldNote.noteText = newNote.noteText;
    if (newNote.noteTextID) oldNote.noteTextID = newNote.noteTextID;
    
    //Old note now is updated; Serialize and send update datasource
    NSData * noteData = [XoomlCollectionParser convertNoteToXooml:oldNote];
    CachedCollectionAttributes * noteAttributes = (self.noteAttributes)[noteID];
    NSString * noteName = [[noteAttributes getAttributeWithName:NOTE_NAME
                                               forAttributeType:NOTE_NAME_TYPE] lastObject];
    [self.dataSource updateNote:noteName
                    withContent:noteData
                   inCollection:self.bulletinBoardName];
}

- (void) renameNoteAttribute: (NSString *) oldAttributeName
                      ofType: (NSString *) attributeType
                     forNote: (NSString *) noteID
                    withName: (NSString *) newAttributeName{
    
    if (!(self.noteContents)[noteID]) return;
    
    [(self.noteAttributes)[noteID] updateAttributeName:oldAttributeName
                                                ofType:attributeType
                                           withNewName:newAttributeName];
    
    [self.manifest updateNoteAttribute:oldAttributeName
                                ofType:attributeType
                               forNote:noteID
                           withNewName:newAttributeName];
    
    self.needSynchronization = YES;
}

-(void) updateNoteAttributes:(NSString *)noteID
              withAttributes:(NSDictionary *)newProperties{
    
    if (!(self.noteContents)[noteID]) return;
    
    if(newProperties[POSITION_TYPE]){
        
        CachedCollectionAttributes * noteAttribute = (self.noteAttributes)[noteID];
        NSDictionary * positionProp = newProperties[POSITION_TYPE];
        [noteAttribute updateAttribute:POSITION_X
                                ofType:POSITION_TYPE
                          withNewValue:positionProp[POSITION_X]];
        [noteAttribute updateAttribute:POSITION_Y
                                ofType:POSITION_TYPE
                          withNewValue:positionProp[POSITION_Y]];
        
        [self.manifest updateNote:noteID withProperties:positionProp];
        
        self.needSynchronization = YES;
    }
}

-(void) updateNoteAttribute: (NSString *) attributeName
                     ofType:(NSString *) attributeType
                    forNote: (NSString *) noteID
              withNewValues: (NSArray *) newValues{
    
    if (!(self.noteContents)[noteID]) return;
    
    [(self.noteAttributes)[noteID] updateAttribute:attributeName
                                            ofType:attributeType
                                      withNewValue:newValues];
    
    [self.manifest updateNoteAttribute:attributeName
                                ofType:attributeType
                               forNote: noteID
                            withValues:newValues];
    
    self.needSynchronization = YES;
}

- (void) renameBulletinBoardAttribute: (NSString *) oldAttributeNAme
                               ofType: (NSString *) attributeType
                             withName: (NSString *) newAttributeName{
    
    [self.bulletinBoardAttributes updateAttributeName: oldAttributeNAme
                                               ofType:attributeType
                                          withNewName:newAttributeName];
    
    [self.manifest updateCollectionAttributeName:oldAttributeNAme
                                          ofType:attributeType
                                     withNewName:newAttributeName];
    
    self.needSynchronization = YES;
}

#pragma mark - Query

- (NSDictionary *) getAllNotes{
    
    return [self.noteContents copy];
}

- (NSDictionary *) getAllNoteAttributesForNote: (NSString *) noteID{
    
    return [(self.noteAttributes)[noteID] getAllAttributes];
}

- (NSDictionary *) getAllBulletinBoardAttributeNamesOfType: (NSString *) attributeType{
    
    return [self.bulletinBoardAttributes getAllAttributeNamesForAttributeType:attributeType];
}

- (NSDictionary *) getAllNoteAttributeNamesOfType: (NSString *) attributeType
                                          forNote: (NSString *) noteID{
    
    if (!(self.noteContents)[noteID]) return nil;
    
    return [(self.noteAttributes)[noteID] getAllAttributeNamesForAttributeType:attributeType];
}

- (id <NoteProtocol>) getNoteContent: (NSString *) noteID{
    
    //ToDo: maybe add a clone method to note to return a clone not the obj itself
    return (self.noteContents)[noteID];
}

- (NSArray *) getAllNotesBelongingToBulletinBoardAttribute: (NSString *) attributeName
                                          forAttributeType: (NSString *) attributeType{
    
    return [self.bulletinBoardAttributes getAttributeWithName:attributeName
                                             forAttributeType:attributeType];
}

- (NSArray *) getAllNotesBelongtingToNoteAttribute: (NSString *) attributeName
                                   ofAttributeType: (NSString *) attributeType
                                           forNote: (NSString *) noteID{
    
    if (!(self.noteContents)[noteID]) return nil;
    
    return [(self.noteAttributes)[noteID] getAttributeWithName:attributeName
                                              forAttributeType:attributeType];
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

#pragma mark - Synchronization Helpers
/*
 Every SYNCHRONIZATION_PERIOD seconds we try to synchrnoize.
 If the synchronize flag is set the bulletin board is updated from Xooml Data in manifest
 */
+(void) saveBulletinBoard:(id) bulletinBoard{
    
    if ([bulletinBoard isKindOfClass:[MindcloudCollection class]]){
        
        MindcloudCollection * board = (MindcloudCollection *) bulletinBoard;
        [board.dataSource updateCollectionWithName:board.bulletinBoardName
                                        andContent:[board.manifest data]];
    }
}

-(void) startTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval: SYNCHRONIZATION_PERIOD
                                     target:self
                                   selector:@selector(synchronize:)
                                   userInfo:nil
                                    repeats:YES];
}

-(void) stopTimer{
    [self.timer invalidate];
}

-(void)synchronize
{
    [self synchronize:self.timer];
}

-(void) synchronize:(NSTimer *) timer{
    
    if (self.needSynchronization){
        self.needSynchronization = NO;
        [MindcloudCollection saveBulletinBoard: self];
    }
}

#pragma mark - Helpers
-(NSData *) getImageDataForPath: (NSString *) path{
    
    NSError * err;
    NSData * data = [NSData dataWithContentsOfFile:path];
    if (!data){
        NSLog(@"Failed to read  image %@ ile from disk: %@", path,err);
        return nil;
    }
    return data;
}

-(CachedCollectionAttributes *) createBulletinBoardAttributeForNotes{
    return [[CachedCollectionAttributes alloc] initWithAttributes:@[NOTE_NAME_TYPE,
                                                                    LINKAGE_TYPE,
                                                                    POSITION_TYPE,
                                                                    VISIBILITY_TYPE]];
}

#pragma mark - cleanup
-(void) cleanUp{
    //check out of the notification center
    NSLog(@"Finishing up");
    [self stopTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end