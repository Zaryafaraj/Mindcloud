//
//  MindcloudCollection.m
//  Mindcloud
//
//  Created by Ali Fathalian on 3/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MindcloudCollection.h"
#import "XoomlCollectionParser.h"
#import "SharingAwareObject.h"
#import "CachedObject.h"

#import "XoomlCollectionManifest.h"
#import "FileSystemHelper.h"
#import "EventTypes.h"
#import "CollectionRecorder.h"
#import "MergerThread.h"
#import "MergeResult.h"
#import "NoteResolutionNotification.h"
#import "NoteFragmentResolver.h"
#import "CollectionSharingAdapter.h"
#import "cachedCollectionContainer.h"

#pragma mark - Definitions

#define SHARED_SYNCH_PERIOD 1
#define UNSHARED_SYNCH_PERIOD 30

@interface MindcloudCollection()

/*
 Holds the actual individual note contents. This dictonary is keyed on the noteID.
 The noteIDs in this dictionary determine whether a note belongs to this bulletin board or not.
 */
@property (nonatomic,strong) NSMutableDictionary * collectionNoteAttributes;

@property (nonatomic, strong) NSMutableDictionary * stackings;
/*
 keyed on noteId and valued on XoomlcollectionNoteAttribute
 */
@property (nonatomic,strong) NSMutableDictionary * collectionAttributesForNotes;
/*
 Keyed on noteID and values are image paths;
 */
@property (nonatomic,strong) NSMutableDictionary * imagePathsForNotes;
/*
 For performance reason we hold this map between noteId and stackId ; if the note belongs to a stack id
 */
@property (nonatomic, strong) NSMutableDictionary * noteToStackingMap;
/*
 The datasource is connected to the mindcloud servers and can be viewed as the expensive
 permenant storage
 */
@property (nonatomic,strong) id<MindcloudDataSource,CollectionSharingAdapterDelegate,
SharingAwareObject, cachedCollectionContainer, CachedObject> dataSource;
/*
 The manifest of the loaded collection
 */
@property (nonatomic,strong) id <CollectionManifestProtocol> manifest;
/*
 The main interface to carry all the sharing specified actions; note that anything 
 sharing related will be done server side. This is for querying about sharing info and 
 getting notified of the listeners
 */
@property (nonatomic, strong) CollectionSharingAdapter * sharingAdapter;
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
 this indicates that we need to synchronize
 any action that changes the bulletinBoard data model calls
 this and then nothing else is needed
 */
@property BOOL needSynchronization;
/*
 Determined based on whether the collection is Shared or Not
 */
@property long synchronizationPeriod;
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
@property BOOL hasStartedListening;
@property BOOL isInSynchWithServer;

@end

@implementation MindcloudCollection
@synthesize bulletinBoardName = _bulletinBoardName;

#pragma mark - Initialization
-(id) initCollection:(NSString *)collectionName
      withDataSource:(id<MindcloudDataSource, CollectionSharingAdapterDelegate, SharingAwareObject, cachedCollectionContainer, CachedObject>) dataSource
{
    self = [super init];
    
    self.recorder = [[CollectionRecorder alloc] init];
    self.thumbnailStack = [NSMutableArray array];
    self.downloadableImageNotes = [NSMutableSet set];
    self.imagePathsForNotes = [NSMutableDictionary dictionary];
    self.collectionNoteAttributes = [NSMutableDictionary dictionary];
    self.collectionAttributesForNotes = [NSMutableDictionary dictionary];
    self.stackings = [NSMutableDictionary dictionary];
    self.waitingNoteImages = [NSMutableDictionary dictionary];
    self.noteToStackingMap = [NSMutableDictionary dictionary];
    self.noteResolver = [[NoteFragmentResolver alloc] initWithCollectionName:collectionName];
    self.hasStartedListening = NO;
    self.isInSynchWithServer = NO;
    
    self.dataSource = dataSource;
    self.sharingAdapter = [[CollectionSharingAdapter alloc] initWithCollectionName:collectionName
                                                                       andDelegate:dataSource];
    self.bulletinBoardName = collectionName;
    //first thing to do is figure out if it is sharing or not. We will get
    //notified of the results later
    [self.sharingAdapter getSharingInfo];
    //now ask to download and get the collection
    
    //we should listen to this before we get the data
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cacheIsSynched:)
                                                 name:CACHE_IS_IN_SYNCH_WITH_SERVER
                                               object:nil];
    NSData * collectionData = [self.dataSource getCollection:collectionName];
    self.synchronizationPeriod = UNSHARED_SYNCH_PERIOD;
    
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
    
    //notification for the nature of the sharing
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(collectionIsShared:)
                                                 name:COLLECTION_IS_SHARED
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
        CollectionNoteAttribute * collectionNoteAttribute = noteInfo[noteID];
        NSString * noteName = collectionNoteAttribute.noteName;
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
                            withModel:collectionNoteAttribute];
        }
        
    }
    
    [self initiateStacking];
}

-(void) initiateNoteContent: (NSData *) noteData
                  forNoteID: (NSString *) noteID
                  withModel:(CollectionNoteAttribute *) collectionNoteAttribute
{
    
    id <NoteProtocol> noteObj = [XoomlCollectionParser xoomlNoteFromXML:noteData];
    if (!noteObj) return ;
    
    (self.collectionNoteAttributes)[noteID] = noteObj;
    //note could have an image or not. If it has an image we have to also add it to note images
    NSString * imgName = noteObj.image;
    if (imgName != nil)
    {
        [self.downloadableImageNotes addObject:noteID];
        NSString * imagePath = [self.dataSource getImagePathForNote:collectionNoteAttribute.noteName
                                                      andCollection:self.bulletinBoardName];
        if (imagePath)
        {
            self.imagePathsForNotes[noteID] = imagePath;
            [self.thumbnailStack addObject:noteID];
        }
        [self.waitingNoteImages setObject:noteID forKey:collectionNoteAttribute.noteName];
    }
    
    
    self.collectionAttributesForNotes[noteID] = collectionNoteAttribute;
}

-(void) initiateStacking{
    //get the stacking information and cache them
    NSDictionary *stackingInfo = [self.manifest getAllStackingsInfo];
    for (NSString * stackingName in stackingInfo)
    {
        StackingModel * stackModel = stackingInfo[stackingName];
        self.stackings[stackingName] = stackModel;
        for (NSString * refId in stackModel.refIds)
        {
            self.noteToStackingMap[refId] = stackingName;
        }
    }
}
#pragma mark - Notifications
-(void) cacheIsSynched:(NSNotification *) notification
{
    self.isInSynchWithServer = YES;
}

-(void) collectionIsShared:(NSNotification *) notification
{
    NSDictionary * result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    if (collectionName != nil &&
        [collectionName isEqualToString:self.bulletinBoardName])
    {
        [self.dataSource collectionIsShared:collectionName];
        if ([self.dataSource isKeyCached:self.bulletinBoardName])
        {
            [self.dataSource refreshCacheForKey:self.bulletinBoardName];
        }
        
        //if we start listenenign or synching too fast before being in synch we will overwrite the server
        //with stale data
        if (!self.hasStartedListening && self.isInSynchWithServer)
        {
            self.synchronizationPeriod = SHARED_SYNCH_PERIOD;
            [self.sharingAdapter startListening];
            self.hasStartedListening = YES;
            [self restartTimer];
        }
    }
}
-(void) collectionFilesDownloaded: (NSNotification *) notification{
    NSData * bulletinBoardData = [self.dataSource getCollectionFromCache:self.bulletinBoardName];
    if (!bulletinBoardData)
    {
        NSLog(@"Collection Files haven't been downloaded properly");
        return;
    }
    id<CollectionManifestProtocol> serverManifest = [[XoomlCollectionManifest alloc]  initWithData:bulletinBoardData];
    id<CollectionManifestProtocol> clientManifest = [self.manifest copy];
    MergerThread * mergerThread = [MergerThread getInstance];
    [self initiateNotesFromDownloadedManifest:serverManifest];
    //when the merge is finished we will be notified
    [mergerThread submitClientManifest:clientManifest
                     andServerManifest:serverManifest
                     andActionRecorder:self.recorder
                     ForCollectionName:self.bulletinBoardName];
    
    self.originalThumbnail = [serverManifest getCollectionThumbnailNoteId];
}


-(void) initiateNotesFromDownloadedManifest:(id<CollectionManifestProtocol>) manifest
{
    //make sure to add the notes that are downloaded separately
    NSDictionary * noteInfos = [manifest getAllNotesBasicInfo];
    for(NSString * noteId in noteInfos)
    {
        CollectionNoteAttribute * collectionNoteAttribute = noteInfos[noteId];
        NSString * noteName = collectionNoteAttribute.noteName;
        NSData * noteData = [self.dataSource getNoteForTheCollection:self.bulletinBoardName
                                                            WithName:noteName];
        
        if (!noteData) NSLog(@"Could not retreive note data from dataSource");
        else
        {
            [self initiateDownloadedNoteContent:noteData
                                      forNoteId:noteId
                                   andcollectionNoteAttribute:collectionNoteAttribute];
        }
    }
    
    //send out a note content update
    if (noteInfos != nil)
    {
        NSDictionary * userDict = @{@"result": noteInfos.allKeys};
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CONTENT_UPDATED_EVENT
                                                            object:self
                                                          userInfo:userDict];
    }
}

-(void) initiateDownloadedNoteContent:(NSData *) noteData
                            forNoteId:(NSString *) noteID
                         andcollectionNoteAttribute:(CollectionNoteAttribute *)collectionNoteAttribute
{
    
    id <NoteProtocol> noteObj = [XoomlCollectionParser xoomlNoteFromXML:noteData];
    if (!noteObj) return ;
    
    [self.noteResolver noteContentReceived:noteObj forNoteId:noteID];
    //set the note content as soon as you receive it
    self.collectionNoteAttributes[noteID] = noteObj;
    //note could have an image or not. If it has an image we have to also add it to note images
    NSString * imgName = noteObj.image;
    if (imgName != nil)
    {
        [self.downloadableImageNotes addObject:noteID];
        NSString * imagePath = [self.dataSource getImagePathForNote:collectionNoteAttribute.noteName
                                                      andCollection:self.bulletinBoardName];
        if (imagePath)
        {
            [self.noteResolver noteImagePathReceived:imagePath forNoteId:noteID];
            [self.thumbnailStack addObject:noteID];
        }
        [self.waitingNoteImages setObject:noteID forKey:collectionNoteAttribute.noteName];
    }
}

-(void) mergeFinished:(NSNotification *) notification
{
    NSLog(@"merge Finished");
    MergeResult * mergeResult = notification.userInfo[@"result"];
    
    if (!mergeResult) return;
    
    if (![mergeResult.collectionName isEqualToString:self.bulletinBoardName]) return;
    
    NotificationContainer * notifications = mergeResult.notifications;
    //The order of these updates are optimized
    [self updateCollectionForDeleteStackingNotifications:notifications.getDeleteStackingNotifications];
    [self updateCollectionForDeleteNoteNotifications: notifications.getDeleteNoteNotifications];
    [self updateCollectionForAddNoteNotifications:notifications.getAddNoteNotifications];
    [self updateCollectionForAddStackingNotifications:notifications.getAddStackingNotifications];
    [self updateCollectionForUpdateStackingNotifications:notifications.getUpdateStackingNotifications];
    [self updateCollectionForUpdateNoteNotifications:notifications.getUpdateNoteNotifications];
    
    self.manifest = mergeResult.finalManifest;
    [self startTimer];
    
    if ([self.recorder hasAnythingBeenTouched])
    {
        //rest because we have updated ourselves
        [self.recorder reset];
        self.needSynchronization = YES;
    }
    
    //if its the first time that we are synching a shared collection then start listening here
    if (self.sharingAdapter.isShared && !self.isInSynchWithServer)
    {
        self.synchronizationPeriod = SHARED_SYNCH_PERIOD;
        [self.sharingAdapter startListening];
        self.hasStartedListening = YES;
        [self restartTimer];
    }
    self.isInSynchWithServer = YES;
}

//for a new note to appear on the screen, different pieces of an update must arrive.
//the note update in manifest, the note content in a separate xooml, and a note image
//an object called noteResolver keeps track of all these items when received and sends out
//a notification when every piece is there. This method gets called and updates the note
//based on those information
-(void) noteResolved:(NSNotification * ) notification
{
    NoteResolutionNotification * noteResolution = notification.userInfo[@"result"];
    if ([self.bulletinBoardName isEqualToString:noteResolution.collectionName])
    {
        NSString * noteId = noteResolution.noteId;
        self.collectionNoteAttributes[noteId] = noteResolution.noteContent;
        self.collectionAttributesForNotes[noteId] = noteResolution.collectionNoteAttribute;
        NSDictionary * userInfo =  @{@"result" :  @[noteId]};
        if (noteResolution.hasImage)
        {
            self.imagePathsForNotes[noteId] = noteResolution.noteImagePath;
            [self.thumbnailStack addObject:noteId];
            [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_NOTE_ADDED_EVENT
                                                                object:self
                                                              userInfo:userInfo];
            
            [self.thumbnailStack addObject:noteId];
            self.originalThumbnail = nil;
            [self.manifest updateThumbnailWithImageOfNote:noteId];
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
            (self.imagePathsForNotes)[noteID] = imgPath;
            //if we are waiting for this let the resolver know
            if ([self.noteResolver hasNoteWaitingForResolution:noteID])
            {
                [self.noteResolver noteImagePathReceived:imgPath forNoteId:noteID];
            }
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
    NSArray * notes = result[@"notes"];
    if ([collectionName isEqualToString:self.bulletinBoardName])
    {
        for (NSString * noteName in notes)
        {
            NSData * noteData = [self.dataSource getNoteForTheCollection:collectionName
                                                                WithName:noteName];
            id<NoteProtocol> noteObj = [XoomlCollectionParser xoomlNoteFromXML:noteData];
            NSString * noteId = [noteObj noteTextID];
            
            
            //if its just an update , update it
            if (self.collectionNoteAttributes[noteId])
            {
                //just update the content
                self.collectionNoteAttributes[noteId] = noteObj;
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
        if (self.imagePathsForNotes[noteId] && self.collectionNoteAttributes[noteId])
        {
            self.imagePathsForNotes[noteId] = imagePath;
            self.collectionNoteAttributes[noteId] = noteObj;
            
            //update thumbnail
            [self.thumbnailStack addObject:noteId];
            self.originalThumbnail = nil;
            [self.manifest updateThumbnailWithImageOfNote:noteId];
            
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
        NSData * manifestData = [self.dataSource getCollectionFromCache:collectionName];
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
              andModel:(CollectionNoteAttribute *) collectionNoteAttribute
         forNoteWithID:(NSString *) noteID
{
    NSString * noteName = collectionNoteAttribute.noteName;
    if (!noteID || !noteName) [NSException raise:NSInvalidArgumentException
                                          format:@"A Values is missing from the required properties dictionary"];
    (self.collectionNoteAttributes)[noteID] = note;
    
    
    [self.manifest addNoteWithID:noteID andModel:collectionNoteAttribute];
    
    self.collectionAttributesForNotes[noteID] = collectionNoteAttribute;
    
    NSData * noteData = [XoomlCollectionParser convertNoteToXooml:note];
    [self.dataSource addNote:noteName
                 withContent:noteData
                ToCollection:self.bulletinBoardName];
    
    [self.recorder recordUpdateNote:noteID];
    self.needSynchronization = YES;
}

-(void) addImageNoteContent:(id <NoteProtocol> )noteItem
                   andModel:(CollectionNoteAttribute *) collectionNoteAttribute
                   andImage: (NSData *) img
                    forNote:(NSString *) noteID
{
    NSString * noteName = collectionNoteAttribute.noteName;
    if (!noteID || !noteName) [NSException raise:NSInvalidArgumentException
                                          format:@"A Values is missing from the required properties dictionary"];
    
    (self.collectionNoteAttributes)[noteID] = noteItem;
    
    [self.manifest addNoteWithID:noteID andModel:collectionNoteAttribute];
    
    self.collectionAttributesForNotes[noteID] = collectionNoteAttribute;
    
    //just save the noteID that has images not the image itself. This is
    //for performance reasons, anytime that an image is needed we will load
    //it from the disk. The dictionary holds noteID and imageFile Path
    NSData * noteData = [XoomlCollectionParser convertImageNoteToXooml:noteItem];
    NSString * imgName = [XoomlCollectionParser getXoomlImageReference: noteItem];
    NSString * imgPath = [FileSystemHelper getPathForNoteImageforNoteName:noteName
                                                          inBulletinBoard:self.bulletinBoardName];
    (self.imagePathsForNotes)[noteID] = imgPath;
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
        if (!self.collectionNoteAttributes[noteId]) return;
    }
    
    NSSet * noteRefs = [NSSet setWithArray:noteIDs];
    StackingModel * stackingModel = self.stackings[stackingName];
    if (!stackingModel)
    {
        stackingModel = [[StackingModel alloc] initWithName:stackingName
                                                        andScale:@"1.0"
                                                       andRefIds:noteRefs];
        self.stackings[stackingName] = stackingModel;
        [self.recorder recordUpdateStack:stackingName];
    }
    else
    {
        [stackingModel addNotes:noteRefs];
        [self.recorder recordUpdateStack:stackingName];
    }
    
    for(NSString * noteId in noteIDs)
    {
        self.noteToStackingMap[noteId] = stackingName;
    }
    
    [self.manifest addStacking:stackingName withModel:stackingModel];
    
    self.needSynchronization = YES;
}

#pragma mark - Deletion

-(void) removeNoteFromAllStackings:(NSString *) noteId
{
    for (NSString * stacking in self.stackings)
    {
        StackingModel * stackingModel = self.stackings[stacking];
        if ([stackingModel.refIds containsObject:noteId])
        {
            [stackingModel deleteNotes:[NSSet setWithObject:noteId]];
            [self.recorder recordUpdateStack:stacking];
            [self.noteToStackingMap removeObjectForKey:noteId];
        }
    }
}

-(void) removeNotesFromAllStackings:(NSSet *) noteIds
{
    //could be more optmized using the noteStacking mapping instead of this iteration
    for (NSString * stacking in self.stackings)
    {
        StackingModel * stackingModel = self.stackings[stacking];
        [stackingModel deleteNotes:noteIds];
    }
    
    for(NSString * noteId in noteIds)
    {
        [self.noteToStackingMap removeObjectForKey:noteId];
    }
}

-(void) removeNoteWithID:(NSString *)delNoteID{
    
    id <NoteProtocol> note = (self.collectionNoteAttributes)[delNoteID];
    if (!note) return;
    
    CollectionNoteAttribute * collectionNoteAttribute = self.collectionAttributesForNotes[delNoteID];
    NSString *noteName = collectionNoteAttribute.noteName;
    [self.collectionNoteAttributes removeObjectForKey:delNoteID];
    [self.collectionAttributesForNotes removeObjectForKey:delNoteID];
    if (self.imagePathsForNotes[delNoteID])
    {
        [self removeNoteImage:delNoteID];
    }
    [self removeNoteFromAllStackings:delNoteID];
    
    [self.manifest deleteNote:delNoteID];
    
    [self.dataSource removeNote:noteName
                 FromCollection:self.bulletinBoardName];
    
    [self.recorder recordDeleteNote:noteName];
    self.needSynchronization = YES;
}

-(void) removeNoteImage:(NSString *) delNoteID
{
    
    [self.imagePathsForNotes removeObjectForKey:delNoteID];
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
    if (!(self.collectionNoteAttributes)[noteID]) return;
    
    StackingModel * stacking = self.stackings[stackingName];
    [stacking deleteNotes:[NSSet setWithObject:noteID]];
    [self.noteToStackingMap removeObjectForKey:noteID];
    
    //reflect the change in the xooml structure
    [self.manifest removeNotes:@[noteID] fromStacking:stackingName];
    [self.recorder recordUpdateStack:stackingName];
    
    self.needSynchronization = YES;
}

-(void) removeStacking:(NSString *) stackingName
{
    
    StackingModel * stackingModel = self.stackings[stackingName];
    for(NSString * noteId in stackingModel.refIds)
    {
        [self.noteToStackingMap removeObjectForKey:noteId];
    }
    
    [self.stackings removeObjectForKey:stackingName];
    
    [self.manifest deleteStacking:stackingName];
    [self.recorder recordDeleteStack:stackingName];
    
    self.needSynchronization = YES;
}

#pragma mark - Update

- (void) updateNoteContentOf:(NSString *)noteID
              withContentsOf:(id<NoteProtocol>)newNote{
    
    id <NoteProtocol> oldNote = self.collectionNoteAttributes[noteID];
    if (!oldNote) return;
    
    //for attributes in newNote that a value is specified; update those
    
    if (newNote.noteText) oldNote.noteText = newNote.noteText;
    if (newNote.noteTextID) oldNote.noteTextID = newNote.noteTextID;
    
    NSData * noteData = nil;
    if (self.imagePathsForNotes[noteID])
    {
        noteData = [XoomlCollectionParser convertImageNoteToXooml:oldNote];
    }
    else
    {
        noteData = [XoomlCollectionParser convertNoteToXooml:oldNote];
    }
    
    CollectionNoteAttribute * collectionNoteAttribute = self.collectionAttributesForNotes[noteID];
    NSString * noteName = collectionNoteAttribute.noteName;
    
    [self.dataSource updateNote:noteName
                    withContent:noteData
                   inCollection:self.bulletinBoardName];
    [self.recorder recordUpdateNote:noteID];
}

-(void) updateNoteAttributes: (NSString *) noteID
                   withModel: (CollectionNoteAttribute *) collectionNoteAttribute
{
    
    if (!(self.collectionNoteAttributes)[noteID]) return;
    
    CollectionNoteAttribute * oldcollectionNoteAttribute = self.collectionAttributesForNotes[noteID];
    oldcollectionNoteAttribute.scaling = collectionNoteAttribute.scaling;
    
    [self.manifest updateNote:noteID withNewModel:collectionNoteAttribute];
    [self.recorder recordUpdateNote:noteID];
    self.needSynchronization = YES;
}

//this is ugly as it isn't consistent and doesn't update the notes in the stacking
//its for performance reasons
-(void) updateStacking:(NSString *) stackingName
          withNewModel:(StackingModel *) stackingModel
{
    StackingModel * oldStackingModel =  self.stackings[stackingName];
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
    
    return [self.collectionNoteAttributes copy];
}

-(CollectionNoteAttribute *) getNoteModelFor: (NSString *) noteID
{
    return self.collectionAttributesForNotes[noteID] ;
}

-(NSArray *) getAllNoteNames
{
    NSMutableArray * result = [NSMutableArray array];
    for (NSString * noteId in self.collectionAttributesForNotes)
    {
        CollectionNoteAttribute * collectionNoteAttribute = self.collectionAttributesForNotes[noteId];
        NSString * noteName = collectionNoteAttribute.noteName;
        [result addObject:noteName];
    }
    return [result copy];
}

-(StackingModel *) getStackModelFor:(NSString *) stackID
{
    return self.stackings[stackID];
}
-(NSDictionary *) getAllStackings
{
    return [self.stackings copy];
}

-(NSString *) stackingForNote:(NSString *)noteId
{
    NSString * stackId =  self.noteToStackingMap[noteId];
    return stackId;
}

- (id <NoteProtocol>) getNoteContent: (NSString *) noteID{
    
    //ToDo: maybe add a clone method to note to return a clone not the obj itself
    return (self.collectionNoteAttributes)[noteID];
}

-(NSData *) getImageForNote:(NSString *) noteID
{
    NSString * imgPath = self.imagePathsForNotes[noteID];
    
    if (!imgPath) return nil;
    
    NSData * imgData = [self getImageDataForPath:imgPath];
    return imgData;
}

-(BOOL) doesNoteHaveImage:(NSString *)noteId
{
    return [self.downloadableImageNotes containsObject:noteId] || self.imagePathsForNotes[noteId];
}

-(NSDictionary *) getAllNoteImages{
    
    NSMutableDictionary * images = [[NSMutableDictionary alloc] init];
    for (NSString * noteID in self.imagePathsForNotes){
        
        NSString * imgPath = (self.imagePathsForNotes)[noteID];
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
        CollectionNoteAttribute * collectionNoteAttribute = [[CollectionNoteAttribute alloc] initWithName:notification.getNoteName
                                                             andPositionX:notification.getPositionX
                                                             andPositionY:notification.getPositionY
                                                               andScaling:notification.getScale];
        
        //the note resolver takes care of updates when all the information is at hand
        [self.noteResolver CollectionNoteAttributeReceived:collectionNoteAttribute forNoteId:noteId];
    }
}

-(void) updateCollectionForUpdateNoteNotifications:(NSArray *) notifications
{
    NSMutableArray * updatedNotes = [NSMutableArray array];
    for (UpdateNoteNotification * notification in notifications)
    {
        CollectionNoteAttribute * note = self.collectionAttributesForNotes[notification.getNoteId];
        note.positionX = notification.getNotePositionX;
        note.positionY = notification.getNotePositionY;
        note.scaling = notification.getNoteScale;
        [updatedNotes addObject:notification.getNoteId];
    }
    
    if ([updatedNotes count] == 0) return;
    
    NSDictionary * userInfo = @{@"result" : [updatedNotes copy]};
    
    NSLog(@"MindcloudCollection: Update Note Event: %@", updatedNotes);
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_UPDATED_EVENT
                                                        object:self
                                                      userInfo:userInfo];
}

-(void) updateCollectionForDeleteNoteNotifications:(NSArray *) notifications
{
    NSMutableDictionary * deletedNotes = [NSMutableDictionary dictionary];
    for (DeleteNoteNotification * notification in notifications)
    {
        [self.collectionNoteAttributes removeObjectForKey:notification.getNoteId];
        [self.collectionAttributesForNotes removeObjectForKey:notification.getNoteId];
        if (self.imagePathsForNotes[notification.getNoteId])
        {
            [self removeNoteImage:notification.getNoteId];
        }
        NSString * correspondingStacking = self.noteToStackingMap[notification.getNoteId];
        if (correspondingStacking)
        {
            deletedNotes[notification.getNoteId] = @{@"stacking":correspondingStacking};
        }
        else
        {
            deletedNotes[notification.getNoteId] = @{};
        }
    }
    
    if ([deletedNotes count] == 0 ) return;
    
    [self removeNotesFromAllStackings:[NSSet setWithArray:[deletedNotes allKeys]]];
    
    NSDictionary * userInfo =  @{@"result" :  deletedNotes};
    
    NSLog(@"MindcloudCollection: Delete Note Event: %@", deletedNotes);
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
        StackingModel * stackingModel = [[StackingModel alloc] initWithName:notification.getStackId
                                                                             andScale:notification.getScale
                                                                            andRefIds:refIds];
        self.stackings[notification.getStackId] = stackingModel;
        for (NSString * noteId in stackingModel.refIds)
        {
            self.noteToStackingMap[noteId] = stackingModel.name;
        }
        [addedStackings addObject:notification.getStackId];
    }
    
    if ([addedStackings count] == 0) return;
    
    NSDictionary * userInfo =  @{@"result" :  addedStackings};
    
    NSLog(@"MindcloudCollection: Add Stacking Event: %@", addedStackings);
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
        StackingModel * stackingModel = [[StackingModel alloc] initWithName:notification.getStackId
                                                                             andScale:notification.getScale
                                                                            andRefIds:refIds];
        
        //get the old stacking and remove the deleted notes
        StackingModel * oldStacking = self.stackings[notification.getStackId];
        if (oldStacking)
        {
            NSMutableSet * deletedNotes = [oldStacking.refIds mutableCopy];
            [deletedNotes minusSet:stackingModel.refIds];
            for (NSString * deletedNote in deletedNotes)
            {
                [self.noteToStackingMap removeObjectForKey:deletedNote];
                
            }
        }
        
        for (NSString * noteId in stackingModel.refIds)
        {
            self.noteToStackingMap[noteId] = stackingModel.name;
        }
        
        self.stackings[notification.getStackId] = stackingModel;
        [updatedStackings addObject:notification.getStackId];
    }
    
    if ([updatedStackings count] == 0) return;
    
    NSDictionary * userInfo =  @{@"result" :  updatedStackings};
    
    NSLog(@"MindcloudCollection: Update Stacking Event: %@", updatedStackings);
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
        StackingModel * stackingModel = self.stackings[stackingName];
        for (NSString * noteId in stackingModel.refIds)
        {
            [self.noteToStackingMap removeObjectForKey:noteId];
        }
        
        [self.stackings removeObjectForKey:stackingName];
        [deletedStackings addObject:stackingName];
    }
    
    if ([deletedStackings count] == 0) return;
    
    NSDictionary * userInfo =  @{@"result" :  deletedStackings};
    
    NSLog(@"MindcloudCollection: Delete Stacking Event: %@", deletedStackings);
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
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.synchronizationPeriod
                                                  target:self
                                                selector:@selector(synchronize:)
                                                userInfo:nil
                                                 repeats:YES];
    NSLog(@"Timer started for %ld seconds", self.synchronizationPeriod);
}

-(void) stopTimer{
    [self.timer invalidate];
}

-(void)restartTimer{
    [self stopTimer];
    [self startTimer];
}

-(void)synchronize
{
    [self synchronize:self.timer];
}

-(void) synchronize:(NSTimer *) timer{
    
    //only save the manifest file in case its in synch with the server
    if (self.needSynchronization && self.isInSynchWithServer){
        self.needSynchronization = NO;
        [MindcloudCollection saveBulletinBoard: self];
    }
}

-(void) stopSynchronization
{
    if (self.sharingAdapter.isShared)
    {
        [self.sharingAdapter stopListening];
    }
}

-(void) refresh
{
    if (self.sharingAdapter.isShared)
    {
        [self.sharingAdapter adjustListeners];
    }
    [self.dataSource getCollection:self.bulletinBoardName];
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
    [self.sharingAdapter stopListening];
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
    NSString * thumbnailPath = self.imagePathsForNotes[thumbnailNoteId];
    if (thumbnailPath == nil) return nil;
    NSData * thumbnailData = [ self getImageDataForPath:thumbnailPath];
    return thumbnailData;
}
@end