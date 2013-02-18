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
#import "CollectionRecorder.h"
#import "MergerThread.h"
#import "MergeResult.h"
#import "NoteResolutionNotification.h"
#import "NoteFragmentResolver.h"

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
@property (nonatomic, strong) NSMutableSet * downloadableImageNotes;
/*
 Each collection may have an original thumbnail. When the collection is loaded if it has a
 thumbnail we set this to the ID of the thumbmnail note else we leave it as nil.
 In the course of working with the collection if the original thumbnail gets deleted
 we set this to nil again. Any new image that is added is a candidate for being the thumbnail
 we save that in the thumbnail stack and make sure deletion to candidates remove them.
 At the end we see original thumbnail should still be the thumbnail by checking
 original. If it should we do nothing, if not we select the top of stack
 and return it. If no new thing had happened we just return the stack
 */
@property NSString * originalThumbnail;
@property (nonatomic, strong) NSMutableArray * thumbnailStack;

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

/*
 To record any possible conflicting items for synchronization
 */
@property (strong, atomic) CollectionRecorder * recorder;

/*
 For resolving different parts of a new note that arrive separately
 */
@property (strong, atomic) NoteFragmentResolver * noteResolver;

/*
 Related to listeners
 All the notes that the listener download but are waiting for the manifest
 */

@end

@implementation MindcloudCollection

#pragma mark - synthesis
@synthesize bulletinBoardName = _bulletinBoardName;

#pragma mark - Initialization
-(id) initCollection:(NSString *)collectionName
      withDataSource:(id<MindcloudDataSource>)dataSource
{
    self = [super init];
    self.recorder = [[CollectionRecorder alloc] init];
    self.thumbnailStack = [NSMutableArray array];
    self.downloadableImageNotes = [NSMutableSet set];
    self.noteImages = [NSMutableDictionary dictionary];
    self.noteContents = [NSMutableDictionary dictionary];
    self.noteAttributes = [NSMutableDictionary dictionary];
    self.collectionAttributes = [NSMutableDictionary dictionary];
    self.waitingNoteImages = [NSMutableDictionary dictionary];
    
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
                                             selector:@selector(mergeFinished:)
                                                 name:MANIFEST_MERGE_FINISHED_EVENT
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noteImageDownloaded:)
                                                 name:IMAGE_DOWNLOADED_EVENT
                                               object:nil];
    
    
    //notifications for note resolver
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noteResolved:)
                                                 name:NOTE_RESOLVED_EVENT
                                               object:nil];
    
    //notifications for listener updates
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listenerDownloadedNote:)
                                                 name:LISTENER_DOWNLOADED_NOTE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listenerDownloadedNoteImage:)
                                                 name:LISTENER_DOWNLOADED_IMAGE
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listenerDeletedNote:)
                                                 name:LISTENER_DELETED_NOTE
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listenerDownloadedManifest:)
                                                 name:LISTENER_DOWNLOADED_MANIFEST
                                               object:nil];
    //Start the synchronization timer
    return self;
}


-(void) loadOfflineCollection:(NSData *) bulletinBoardData{
    
    if (!bulletinBoardData)
    {
        NSLog(@"Collection Files haven't been downloaded properly");
        return;
    }
    self.manifest = [[XoomlCollectionManifest alloc]  initWithData:bulletinBoardData];
    
    self.originalThumbnail = [self.manifest getCollectionThumbnailNoteId];
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
        [self.downloadableImageNotes addObject:noteID];
        NSString * imagePath = [self.dataSource getImagePathForNote:noteModel.noteName
                                                      andCollection:self.bulletinBoardName];
        if (imagePath)
        {
            self.noteImages[noteID] = imagePath;
            [self.thumbnailStack addObject:noteID];
        }
        [self.waitingNoteImages setObject:noteID forKey:noteModel.noteName];
    }
    
    
    self.noteAttributes[noteID] = noteModel;
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
#pragma mark - Notifications

-(void) collectionFilesDownloaded: (NSNotification *) notification{
    NSData * bulletinBoardData = [self.dataSource getCollection:self.bulletinBoardName];
    if (!bulletinBoardData)
    {
        NSLog(@"Collection Files haven't been downloaded properly");
        return;
    }
    id<CollectionManifestProtocol> serverManifest = [[XoomlCollectionManifest alloc]  initWithData:bulletinBoardData];
    id<CollectionManifestProtocol> clientManifest = [self.manifest copy];
    MergerThread * mergerThread = [MergerThread getInstance];
    //when the merge is finished we will be notified
    [mergerThread submitClientManifest:clientManifest
                     andServerManifest:serverManifest
                     andActionRecorder:self.recorder
                     ForCollectionName:self.bulletinBoardName];
    
    
}

-(void) mergeFinished:(NSNotification *) notification
{
    MergeResult * mergeResult = notification.userInfo[@"result"];
    
    if (!mergeResult) return;
    
    if (![mergeResult.collectionName isEqualToString:self.bulletinBoardName]) return;
    
    NotificationContainer * notifications = mergeResult.notifications;
    //The order of these updates are optimized
    [self updateCollectionForAddNoteNotifications:notifications.getAddNoteNotifications];
    [self updateCollectionForUpdateNoteNotifications:notifications.getUpdateNoteNotifications];
    [self updateCollectionForAddStackingNotifications:notifications.getAddStackingNotifications];
    [self updateCollectionForUpdateStackingNotifications:notifications.getUpdateStackingNotifications];
    [self updateCollectionForDeleteStackingNotifications:notifications.getDeleteStackingNotifications];
    [self updateCollectionForDeleteNoteNotifications: notifications.getDeleteNoteNotifications];
    
    self.manifest = mergeResult.finalManifest;
    [self startTimer];
    
    if ([self.recorder hasAnythingBeenTouched])
    {
        //rest because we have updated ourselves
        [self.recorder reset];
        self.needSynchronization = YES;
    }
}

//for a new note to appear on the screen, different pieces of an update must arrive.
//the note update in manifest, the note content in a separate xooml, and a note image
//an object called noteResolver keeps track of all these items when received and sends out
//a notification when every piece is there. This method gets called and updates the note
//based on those information
-(void) noteResolved:(NSNotification * ) notification
{
    NSDictionary * dict = notification.userInfo[@"result"];
    NoteResolutionNotification * noteResolution = dict[@"noteResolution"];
    if ([self.bulletinBoardName isEqualToString:noteResolution.collectionName])
    {
        NSString * noteId = noteResolution.noteId;
        self.noteContents[noteId] = noteResolution.noteContent;
        self.noteAttributes[noteId] = noteResolution.noteModel;
        NSDictionary * userInfo =  @{@"result" :  @[noteId]};
        if (noteResolution.hasImage)
        {
            self.noteImages[noteId] = noteResolution.noteImagePath;
            [self.thumbnailStack addObject:noteId];
            [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_NOTE_ADDED_EVENT
                                                                object:self
                                                              userInfo:userInfo];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_ADDED_EVENT
                                                                object:self
                                                              userInfo:userInfo];
            
        }
    }
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


-(void) listenerDownloadedNote:(NSNotification *) notification
{
    NSDictionary * result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    NSString * noteName = result[@"noteName"];
    if ([collectionName isEqualToString:self.bulletinBoardName])
    {
        
        NSData * noteData = [self.dataSource getNoteForTheCollection:collectionName
                                                            WithName:noteName];
        id<NoteProtocol> noteObj = [XoomlCollectionParser xoomlNoteFromXML:noteData];
        NSString * noteId = [noteObj noteTextID];
        
        
        //if its just an update , update it
        if (self.noteContents[noteId])
        {
            //just update the content
            self.noteContents[noteId] = noteObj;
            NSDictionary * userInfo =  @{@"result" :  @[noteId]};
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CONTENT_UPDATED_EVENT
                                                                object:self
                                                              userInfo:userInfo];
        }
        //if its a new note submit the piece of the note that was received to resolver
        else
        {
            [self.noteResolver noteContentReceived:noteObj
                                         forNoteId:noteId];
        }
    }
}

-(void) listenerDownloadedNoteImage:(NSNotification *) notification
{
    NSDictionary * result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    NSString * noteName = result[@"noteName"];
    if ([collectionName isEqualToString:self.bulletinBoardName])
    {
        NSString * imagePath = [self.dataSource getImagePathForNote:noteName
                                                      andCollection:collectionName];
        NSData * noteData = [self.dataSource getNoteForTheCollection:collectionName
                                                            WithName:noteName];
        
        id<NoteProtocol> noteObj = [XoomlCollectionParser xoomlNoteFromXML:noteData];
        NSString * noteId = [noteObj noteTextID];
        
        //if this is only an update, update the image path and send the notification
        if (self.noteImages[noteId] && self.noteContents[noteId])
        {
            self.noteImages[noteId] = imagePath;
            self.noteContents[noteId] = noteObj;
            NSDictionary * userInfo =  @{@"result" :  @[noteId]};
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_IMAGE_UPDATED_EVENT
                                                                object:self
                                                              userInfo:userInfo];
            
        }
        else
        {
            [self.noteResolver noteImagePathReceived:imagePath forNoteId:noteId];
        }
    }
}

-(void) listenerDeletedNote:(NSNotification *) notification
{
    //nothing to do here, since the manifest update will remove this note and update the UI
//    NSLog(@"Note Deleted");
}

-(void) listenerDownloadedManifest:(NSNotification *) notification
{
    NSDictionary * result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    if ([collectionName isEqualToString:self.bulletinBoardName])
    {
        NSData * manifestData = [self.dataSource getCollection:collectionName];
        if (!manifestData)
        {
            NSLog(@"Collection File didn't download properly");
            return;
        }
        id<CollectionManifestProtocol> serverManifest = [[XoomlCollectionManifest alloc]
                                                         initWithData:manifestData];
        
        id<CollectionManifestProtocol> clientManifest = [self.manifest copy];
        MergerThread * mergerThread = [MergerThread getInstance];
        //when the merge is finished we will be notified
        [mergerThread submitClientManifest:clientManifest
                         andServerManifest:serverManifest
                         andActionRecorder:self.recorder
                         ForCollectionName:self.bulletinBoardName];
            
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
    
    [self.recorder recordUpdateNote:noteID];
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
    [self.thumbnailStack addObject:noteID];
    self.originalThumbnail = nil;
    [self.manifest updateThumbnailWithImageOfNote:noteID];
    
    [self.dataSource addImageNote: noteName
                  withNoteContent: noteData
                         andImage: img
                withImageFileName: imgName
                     toCollection:self.bulletinBoardName];
    
    [self.recorder recordUpdateNote:noteID];
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
        [self.recorder recordUpdateStack:stackingName];
    }
    else
    {
        [stackingModel addNotes:noteRefs];
        [self.recorder recordUpdateStack:stackingName];
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
            [self.recorder recordUpdateStack:stacking];
        }
    }
}

-(void) removeNotesFromAllStackings:(NSSet *) noteIds
{
    for (NSString * stacking in self.collectionAttributes)
    {
        XoomlStackingModel * stackingModel = self.collectionAttributes[stacking];
        [stackingModel deleteNotes:noteIds];
    }
}

-(void) removeNoteWithID:(NSString *)delNoteID{
    
    id <NoteProtocol> note = (self.noteContents)[delNoteID];
    if (!note) return;
    
    XoomlNoteModel * noteModel = self.noteAttributes[delNoteID];
    NSString *noteName = noteModel.noteName;
    [self.noteContents removeObjectForKey:delNoteID];
    [self.noteAttributes removeObjectForKey:delNoteID];
    if (self.noteImages[delNoteID])
    {
        [self removeNoteImage:delNoteID];
    }
    [self removeNoteFromAllStackings:delNoteID];
    
    [self.manifest deleteNote:delNoteID];
    
    [self.dataSource removeNote:noteName
                 FromCollection:self.bulletinBoardName];
    
    [self.recorder recordDeleteNote:noteName];
    self.needSynchronization = true;
}

-(void) removeNoteImage:(NSString *) delNoteID
{
    
    [self.noteImages removeObjectForKey:delNoteID];
    if (delNoteID != nil && [self.originalThumbnail isEqualToString:delNoteID])
    {
        //its no longer the original thumbnail
        self.originalThumbnail = nil;
    }
    [self.thumbnailStack removeObject:delNoteID];
    if ([self.thumbnailStack count] > 0)
    {
        NSString * lastThumbnailNoteId = [self.thumbnailStack lastObject];
        [self.manifest updateThumbnailWithImageOfNote:lastThumbnailNoteId];
    }
    else
    {
        [self.manifest deleteThumbnailForNote:delNoteID];
    }
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
    [self.recorder recordUpdateStack:stackingName];
    
    self.needSynchronization = YES;
}

-(void) removeStacking:(NSString *) stackingName
{
    
    [self.collectionAttributes removeObjectForKey:stackingName];
    
    [self.manifest deleteStacking:stackingName];
    [self.recorder recordDeleteStack:stackingName];
    
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
    
    NSData * noteData = nil;
    if (self.noteImages[noteID])
    {
        noteData = [XoomlCollectionParser convertImageNoteToXooml:oldNote];
    }
    else
    {
        noteData = [XoomlCollectionParser convertNoteToXooml:oldNote];
    }
    
    XoomlNoteModel * noteModel = self.noteAttributes[noteID];
    NSString * noteName = noteModel.noteName;
    
    [self.dataSource updateNote:noteName
                    withContent:noteData
                   inCollection:self.bulletinBoardName];
    [self.recorder recordUpdateNote:noteID];
}

-(void) updateNoteAttributes: (NSString *) noteID
                   withModel: (XoomlNoteModel *) noteModel
{
    
    if (!(self.noteContents)[noteID]) return;
    
    XoomlNoteModel * oldNoteModel = self.noteAttributes[noteID];
    oldNoteModel.scaling = noteModel.scaling;
    
    [self.manifest updateNote:noteID withNewModel:noteModel];
    [self.recorder recordUpdateNote:noteID];
    self.needSynchronization = YES;
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
    
    [self.recorder recordUpdateStack:stackingName];
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

-(NSArray *) getAllNoteNames
{
    NSMutableArray * result = [NSMutableArray array];
    for (NSString * noteId in self.noteAttributes)
    {
        XoomlNoteModel * noteModel = self.noteAttributes[noteId];
        NSString * noteName = noteModel.noteName;
        [result addObject:noteName];
    }
    return [result copy];
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
    return [self.downloadableImageNotes containsObject:noteId] ? YES:NO;
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

#pragma mark - merge helpers
-(void) updateCollectionForAddNoteNotifications:(NSArray *) notifications
{
    //the contents of these notes may be added later by another notifiaction
    for(AddNoteNotification * notification in notifications)
    {
        NSString * noteId = notification.getNoteId;
        XoomlNoteModel * noteModel = [[XoomlNoteModel alloc] initWithName:notification.getNoteName
                                                             andPositionX:notification.getPositionX
                                                             andPositionY:notification.getPositionY
                                                               andScaling:notification.getScale];
        
        //the note resolver takes care of updates when all the information is at hand
        [self.noteResolver noteModelReceived:noteModel forNoteId:noteId];
    }
}

-(void) updateCollectionForUpdateNoteNotifications:(NSArray *) notifications
{
    NSMutableArray * updatedNotes = [NSMutableArray array];
    for (UpdateNoteNotification * notification in notifications)
    {
        XoomlNoteModel * note = self.noteAttributes[notification.getNoteId];
        note.positionX = notification.getNotePositionX;
        note.positionY = notification.getNotePositionY;
        note.scaling = notification.getNoteScale;
        [updatedNotes addObject:notification.getNoteId];
    }
    
    NSDictionary * userInfo = @{@"result" : [updatedNotes copy]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_UPDATED_EVENT
                                                        object:self
                                                      userInfo:userInfo];
}

-(void) updateCollectionForDeleteNoteNotifications:(NSArray *) notifications
{
    NSMutableSet * deletedNotes = [NSMutableSet set];
    for (DeleteNoteNotification * notification in notifications)
    {
        [self.noteContents removeObjectForKey:notification.getNoteId];
        [self.noteAttributes removeObjectForKey:notification.getNoteId];
        if (self.noteImages[notification.getNoteId])
        {
            [self removeNoteImage:notification.getNoteId];
        }
        [deletedNotes addObject:notification.getNoteId];
    }
    [self removeNotesFromAllStackings:deletedNotes];
    
    NSDictionary * userInfo =  @{@"result" :  deletedNotes.allObjects};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_DELETED_EVENT
                                                        object:self
                                                      userInfo:userInfo];
}

-(void) updateCollectionForAddStackingNotifications:(NSArray *) notifications
{
    //for a stacking we add it anyways and add notes that are alread there.
    //When a new note comes in that was part of the stacking but we didn't have it
    //the UI checks for it and adds it
    NSMutableArray * addedStackings = [NSMutableArray array];
    for (AddStackingNotification * notification in notifications)
    {
        NSSet * refIds = [NSSet setWithArray:notification.getNoteRefs];
        XoomlStackingModel * stackingModel = [[XoomlStackingModel alloc] initWithName:notification.getStackId
                                                                             andScale:notification.getScale
                                                                            andRefIds:refIds];
        self.collectionAttributes[notification.getStackId] = stackingModel;
        [addedStackings addObject:notification.getStackId];
    }
    
    NSDictionary * userInfo =  @{@"result" :  addedStackings};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:STACK_ADDED_EVENT
                                                        object:self
                                                      userInfo:userInfo];
}

-(void) updateCollectionForUpdateStackingNotifications:(NSArray *) notifications
{
    //we treat update stacking just like add stacking. New notes will be added to
    //it once they arrive
    NSMutableArray * updatedStackings = [NSMutableArray array];
    for(UpdateStackNotification * notification in notifications)
    {
        
        NSSet * refIds = [NSSet setWithArray:notification.getNoteRefs];
        XoomlStackingModel * stackingModel = [[XoomlStackingModel alloc] initWithName:notification.getStackId
                                                                             andScale:notification.getScale
                                                                            andRefIds:refIds];
        self.collectionAttributes[notification.getStackId] = stackingModel;
        [updatedStackings addObject:notification.getStackId];
    }
    
    NSDictionary * userInfo =  @{@"result" :  updatedStackings};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:STACK_UPDATED_EVENT
                                                        object:self
                                                      userInfo:userInfo];
}

-(void) updateCollectionForDeleteStackingNotifications:(NSArray *) notifications
{
    NSMutableArray * deletedStackings = [NSMutableArray array];
    for (DeleteStackingNotification * notification in notifications)
    {
        NSString * stackingName = notification.getStackingId;
        [self.collectionAttributes removeObjectForKey:stackingName];
        [deletedStackings addObject:stackingName];
    }
    
    NSDictionary * userInfo =  @{@"result" :  deletedStackings};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:STACK_DELETED_EVENT
                                                        object:self
                                                      userInfo:userInfo];
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
        [board.recorder reset];
    }
}

-(void) startTimer{
    
    if (self.timer.isValid) return;
    
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
    [self.recorder reset];
}

#pragma - thumbnail related actions
-(void) saveThumbnail:(NSData *)thumbnailData
{
    [self.dataSource setThumbnail:thumbnailData forCollection:self.bulletinBoardName];
}

#pragma mark - thumbnail delegate

-(BOOL) isUpdateThumbnailNeccessary
{
    return self.originalThumbnail == nil ? YES : NO;
}

-(NSData *) getLastThumbnailImage
{
    if([self.thumbnailStack count] == 0) return nil;
    
    NSString * thumbnailNoteId = [self.thumbnailStack lastObject];
    NSString * thumbnailPath = self.noteImages[thumbnailNoteId];
    if (thumbnailPath == nil) return nil;
    NSData * thumbnailData = [ self getImageDataForPath:thumbnailPath];
    return thumbnailData;
}


@end