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
#define SCALE_VALUE @"scale"

#define POSITION_TYPE @"position"
#define SCALE_TYPE @"scale"
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

@property (nonatomic, strong) NSMutableDictionary * collectionAttributes;
/*
 keyed on noteId and valued on XoomlNoteModel
 */
@property (nonatomic,strong) NSMutableDictionary * noteAttributes;
/*
 Keyed on noteID and values are image paths;
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
 Keyed on noteName - valued on noteID. All the noteImages for which we have sent 
 a request but we are waiting for response
 */
@property (nonatomic, strong) NSMutableDictionary * waitingNoteImages;

/*
 Most of the times that we start from empty cache we only know that certain notes have image but 
 we don't know what the actual image is, this helps us to determine the image notes before we download the 
 image
 */
@property (nonatomic, strong) NSMutableSet * imageNotes;
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
@synthesize bulletinBoardName = _bulletinBoardName;

-(NSMutableDictionary *) waitingNoteImages
{
    if (!_waitingNoteImages)
    {
        _waitingNoteImages = [NSMutableDictionary dictionary];
    }
    return _waitingNoteImages;
}

-(NSMutableDictionary *) collectionAttributes
{
    if (!_collectionAttributes){
        _collectionAttributes = [NSMutableDictionary dictionary];
    }
    return _collectionAttributes;
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

-(NSMutableSet *) imageNotes
{
    if (!_imageNotes)
    {
        _imageNotes = [NSMutableSet set];
    }
    return _imageNotes;
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
        [self loadOfflineCollection:collectionData];
    }
    
    //In any case listen for the download to get finished
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(collectionFilesDownloaded:)
                                                 name:COLLECTION_DOWNLOADED_EVENT
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noteImageDownloaded:)
                                                 name:IMAGE_DOWNLOADED_EVENT
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
    NSDictionary * noteInfo = [self.manifest getAllNotesBasicInfo];
    for(NSString * noteID in noteInfo){
        
        XoomlNoteModel * noteModel = noteInfo[noteID];
        //for each note create a note Object by reading its separate xooml files
        //from the data model
        NSData * noteData = [self.dataSource getNoteForTheCollection:self.bulletinBoardName
                                                            WithName:noteModel.noteName];
        if (!noteData)
        {
            NSLog(@"Could not retreive note data from dataSource");
        }
        else
        {
            [self initiateNoteContent:noteData
                            forNoteID:noteID
                            withModel:noteModel];
        }
    }
    
    [self initiateStacking];
    //Let any listener know that the bulletinboard has been reloaded
    [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTION_RELOAD_EVENT
                                                        object:self];
}

-(void) loadOfflineCollection:(NSData *) bulletinBoardData{
    
    if (!bulletinBoardData)
    {
        NSLog(@"Collection Files haven't been downloaded properly");
        return;
    }
    self.manifest = [[XoomlCollectionManifest alloc]  initWithData:bulletinBoardData];
    
    //get notes from manifest and initalize those
    NSDictionary * noteInfo = [self.manifest getAllNotesBasicInfo];
    for(NSString * noteID in noteInfo){
        
        //for each note create a note Object by reading its separate xooml files
        //from the data model
        XoomlNoteModel * noteModel = noteInfo[noteID];
        NSString * noteName = noteModel.noteName;
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
                            withModel:noteModel];
        }
        
    }
    
    [self initiateStacking];
}

-(void) initiateNoteContent: (NSData *) noteData
                  forNoteID: (NSString *) noteID
                  withModel:(XoomlNoteModel *) noteModel
{

    id <NoteProtocol> noteObj = [XoomlCollectionParser xoomlNoteFromXML:noteData];
    if (!noteObj) return ;
    
    (self.noteContents)[noteID] = noteObj;
    //note could have an image or not. If it has an image we have to also add it to note images
    NSString * imgName = noteObj.image;
    if (imgName != nil)
    {
        [self.imageNotes addObject:noteID];
        NSString * imagePath = [self.dataSource getImagePathForNote:noteModel.noteName
                                                      andCollection:self.bulletinBoardName];
        if (imagePath)
        {
            self.noteImages[noteID] = imagePath;
        }
        [self.waitingNoteImages setObject:noteID forKey:noteModel.noteName];
    }
    
    
    self.noteAttributes[noteID] = noteModel;
}

-(void) noteImageDownloaded:(NSNotification *) notification
{
    
    NSDictionary * dict = notification.userInfo[@"result"];
    NSString * collectionName = dict[@"collectionName"];
    NSString * noteName = dict[@"noteName"];
    NSString * imgPath = [FileSystemHelper getPathForNoteImageforNoteName:noteName
                                               inBulletinBoard:self.bulletinBoardName];
    if (imgPath != nil && ![imgPath isEqualToString:@""])
    {
        NSString * noteID = self.waitingNoteImages[noteName];
        if (noteID)
        {
            (self.noteImages)[noteID] = imgPath;
            [self.waitingNoteImages removeObjectForKey:noteName];
            //send out a notification
            NSDictionary * userInfo = @{@"result" :
                                            @{@"collectionName":collectionName,
                                              @"noteId":noteID}
                                        };
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_IMAGE_READY_EVENT
                                                                object:self
                                                              userInfo:userInfo];
            
        }
        
    }
}
-(void) initiateStacking{
    //get the stacking information and cache them
    NSDictionary *stackingInfo = [self.manifest getAllStackingsInfo];
    for (NSString * stackingName in stackingInfo)
    {
        NSString * stackModel = stackingInfo[stackingName];
        self.collectionAttributes[stackingName] = stackModel;
    }
}

#pragma mark - Creation

-(void) addNoteContent: (id <NoteProtocol>) note
         andModel:(XoomlNoteModel *) noteModel
         forNoteWithID:(NSString *) noteID
{
    NSString * noteName = noteModel.noteName;
    if (!noteID || !noteName) [NSException raise:NSInvalidArgumentException
                                          format:@"A Values is missing from the required properties dictionary"];
    (self.noteContents)[noteID] = note;
    
    
    [self.manifest addNoteWithID:noteID andModel:noteModel];
    
    self.noteAttributes[noteID] = noteModel;
    
    NSData * noteData = [XoomlCollectionParser convertNoteToXooml:note];
    [self.dataSource addNote:noteName
                 withContent:noteData
                ToCollection:self.bulletinBoardName];
    
    self.needSynchronization = YES;
}

-(void) addImageNoteContent:(id <NoteProtocol> )noteItem
              andModel:(XoomlNoteModel *) noteModel
                   andImage: (NSData *) img
                    forNote:(NSString *) noteID
{
    NSString * noteName = noteModel.noteName;
    if (!noteID || !noteName) [NSException raise:NSInvalidArgumentException
                                          format:@"A Values is missing from the required properties dictionary"];
    
    (self.noteContents)[noteID] = noteItem;
    
    [self.manifest addNoteWithID:noteID andModel:noteModel];
    
    self.noteAttributes[noteID] = noteModel;
    
    //just save the noteID that has images not the image itself. This is
    //for performance reasons, anytime that an image is needed we will load
    //it from the disk. The dictionary holds noteID and imageFile Path
    NSData * noteData = [XoomlCollectionParser convertImageNoteToXooml:noteItem];
    NSString * imgName = [XoomlCollectionParser getXoomlImageReference: noteItem];
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

-(void) addNotesWithIDs: (NSArray *) noteIDs
             toStacking:(NSString *) stackingName
{
    //validate that all the notes exist
    for (NSString * noteId in noteIDs){
        if (!self.noteContents[noteId]) return;
    }
    
    NSSet * noteRefs = [NSSet setWithArray:noteIDs];
    XoomlStackingModel * stackingModel = self.collectionAttributes[stackingName];
    if (!stackingModel)
    {
        stackingModel = [[XoomlStackingModel alloc] initWithName:stackingName
                                                        andScale:@"1.0"
                                                       andRefIds:noteRefs];
        self.collectionAttributes[stackingName] = stackingModel;
    }
    else
    {
        [stackingModel addNotes:noteRefs];
    }
    
    [self.manifest addStacking:stackingName withModel:stackingModel];
    
    self.needSynchronization = YES;
}

#pragma mark - Deletion

-(void) removeNoteFromAllStackings:(NSString *) noteId
{
    for (NSString * stacking in self.collectionAttributes)
    {
        XoomlStackingModel * stackingModel = self.collectionAttributes[stacking];
        if ([stackingModel.refIds containsObject:noteId])
        {
            [stackingModel deleteNotes:[NSSet setWithObject:noteId]];
        }
    }
}
-(void) removeNoteWithID:(NSString *)delNoteID{
    
    id <NoteProtocol> note = (self.noteContents)[delNoteID];
    if (!note) return;
    
    XoomlNoteModel * noteModel = self.noteAttributes[delNoteID];
    NSString *noteName = noteModel.noteName;
    [self.noteContents removeObjectForKey:delNoteID];
    [self.noteAttributes removeObjectForKey:delNoteID];
    [self removeNoteFromAllStackings:delNoteID];
    
    [self.manifest deleteNote:delNoteID];
    
    [self.dataSource removeNote:noteName
                 FromCollection:self.bulletinBoardName];
    
    self.needSynchronization = true;
}

-(void) removeNote:(NSString *) noteID
      fromStacking:(NSString *) stackingName
{
    //if the noteId is not valid return
    if (!(self.noteContents)[noteID]) return;
    
    XoomlStackingModel * stacking = self.collectionAttributes[stackingName];
    [stacking deleteNotes:[NSSet setWithObject:noteID]];
    
    //reflect the change in the xooml structure
    [self.manifest removeNotes:@[noteID] fromStacking:stackingName];
    
    self.needSynchronization = YES;
}

-(void) removeStacking:(NSString *) stackingName
{

    [self.collectionAttributes removeObjectForKey:stackingName];
    
    [self.manifest deleteStacking:stackingName];
    
    self.needSynchronization = YES;
}

#pragma mark - Update

- (void) updateNoteContentOf:(NSString *)noteID
              withContentsOf:(id<NoteProtocol>)newNote{
    
    id <NoteProtocol> oldNote = self.noteContents[noteID];
    if (!oldNote) return;
    
    //for attributes in newNote that a value is specified; update those
    if (newNote.noteText) oldNote.noteText = newNote.noteText;
    if (newNote.noteTextID) oldNote.noteTextID = newNote.noteTextID;
    
    //Old note now is updated; Serialize and send update datasource
    NSData * noteData = [XoomlCollectionParser convertNoteToXooml:oldNote];
    XoomlNoteModel * noteModel = self.noteAttributes[noteID];
    NSString * noteName = noteModel.noteName;
    
    [self.dataSource updateNote:noteName
                    withContent:noteData
                   inCollection:self.bulletinBoardName];
}

-(void) updateNoteAttributes: (NSString *) noteID
                   withModel: (XoomlNoteModel *) noteModel
{

    if (!(self.noteContents)[noteID]) return;
    
    if(noteModel.positionX && noteModel.positionY)
    {
        
        XoomlNoteModel * oldNoteModel = self.noteAttributes[noteID];
        oldNoteModel.positionX = noteModel.positionX;
        oldNoteModel.positionY = noteModel.positionY;
        
        [self.manifest changeNotePosition:noteID
                                      toX:noteModel.positionX
                                     andY:noteModel.positionY];

        self.needSynchronization = YES;
    }
    if (noteModel.scaling)
    {
        
        XoomlNoteModel * oldNoteModel = self.noteAttributes[noteID];
        oldNoteModel.scaling = noteModel.scaling;
        
        [self.manifest updateNote:noteID withNewModel:noteModel];
        
        self.needSynchronization = YES;
    }
}

//this is ugly as it isn't consistent and doesn't update the notes in the stacking
//its for performance reasons
-(void) updateStacking:(NSString *) stackingName
          withNewModel:(XoomlStackingModel *) stackingModel
{
    XoomlStackingModel * oldStackingModel =  self.collectionAttributes[stackingName];
    if (stackingModel.scale)
    {
        oldStackingModel.scale = stackingModel.scale;
    }
    if (stackingModel.name)
    {
        oldStackingModel.name = stackingModel.name;
    }
    
    [self.manifest updateStacking:stackingName
                     withNewModel:stackingModel];
    
    self.needSynchronization = YES;
}

#pragma mark - Query

- (NSDictionary *) getAllNotesContents{
    
    return [self.noteContents copy];
}

-(XoomlNoteModel *) getNoteModelFor: (NSString *) noteID
{
    return self.noteAttributes[noteID] ;
}

-(XoomlStackingModel *) getStackModelFor:(NSString *) stackID
{
    return self.collectionAttributes[stackID];
}
-(NSDictionary *) getAllStackings
{
    return [self.collectionAttributes copy];
}

- (id <NoteProtocol>) getNoteContent: (NSString *) noteID{
    
    //ToDo: maybe add a clone method to note to return a clone not the obj itself
    return (self.noteContents)[noteID];
}

-(NSData *) getImageForNote:(NSString *) noteID
{
    NSString * imgPath = self.noteImages[noteID];
    
    if (!imgPath) return nil;
    
    NSData * imgData = [self getImageDataForPath:imgPath];
    return imgData;
}

-(BOOL) doesNoteHaveImage:(NSString *)noteId
{
    return [self.imageNotes containsObject:noteId] ? YES:NO;
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

#pragma mark - cleanup
-(void) cleanUp{
    //check out of the notification center
    [self stopTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - thumbnail
-(void) saveThumbnail:(NSData *)thumbnailData
{
    [self.dataSource setThumbnail:thumbnailData forCollection:self.bulletinBoardName];
}

@end