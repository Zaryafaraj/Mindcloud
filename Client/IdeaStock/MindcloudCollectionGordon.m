//
//  MindcloudGordon.m
//  Mindcloud
//
//  Created by Ali Fathalian on 8/24/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudCollectionGordon.h"
#import "CollectionSharingAdapter.h"
#import "cachedCollectionContainer.h"
#import "SharingAwareObject.h"
#import "CachedObject.h"
#import "MindcloudDataSource.h"
#import "CachedMindCloudDataSource.h"
#import "EventTypes.h"
#import "CollectionManifestProtocol.h"
#import "XoomlCollectionManifest.h"
#import "MergerThread.h"
#import "CollectionRecorder.h"
#import "NoteFragmentResolver.h"
#import "XoomlCollectionParser.h"
#import "MergeResult.h"
#import "FileSystemHelper.h"
#import "NotificationContainer.h"

#define SHARED_SYNCH_PERIOD 1
#define UNSHARED_SYNCH_PERIOD 30
@interface MindcloudCollectionGordon()
/*
 The datasource is connected to the mindcloud servers and can be viewed as the expensive
 permenant storage
 */
@property (nonatomic,strong) id<MindcloudDataSource,
CollectionSharingAdapterDelegate,
SharingAwareObject,
cachedCollectionContainer,
CachedObject> dataSource;

/*
 The main interface to carry all the sharing specified actions; note that anything
 sharing related will be done server side. This is for querying about sharing info and
 getting notified of the listeners
 */
@property (nonatomic, strong) CollectionSharingAdapter * sharingAdapter;

/*
 The manifest of the loaded collection
 */
@property (nonatomic,strong) id <CollectionManifestProtocol> manifest;

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

@property BOOL hasStartedListening;
@property BOOL isInSynchWithServer;

@property (nonatomic,strong) NSString * collectionName;

//delegate should be weak
@property (nonatomic, weak) id<MindcloudCollectionGordonDelegate> delegate;


/*
 Keyed on noteName - valued on noteID. All the noteImages for which we have sent
 a request but we are waiting for response
 */
@property (nonatomic, strong) NSMutableDictionary * waitingNoteImages;

@end

@implementation MindcloudCollectionGordon

-(id)initWithCollectionName:(NSString *)collectionName
                andDelegate:(id<MindcloudCollectionGordonDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.collectionName = collectionName;
        self.hasStartedListening = NO;
        self.isInSynchWithServer = NO;
        if(delegate != nil)
        {
            self.delegate = delegate;
        }
        self.dataSource = [CachedMindCloudDataSource getInstance:collectionName];
        self.sharingAdapter = [[CollectionSharingAdapter alloc] initWithCollectionName:collectionName andDelegate:self.dataSource];
        
        //assume we are not shared for now and ask the server about the sharing info.
        //get notified if you were wrong and change the synch period
        self.synchronizationPeriod = UNSHARED_SYNCH_PERIOD;
        [self.sharingAdapter getSharingInfo];
        
        //Before actually starting the synch period we need to start asking to be
        //notified when the synch is fnished
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cacheIsSynched:)
                                                     name:CACHE_IS_IN_SYNCH_WITH_SERVER
                                                   object:nil];
        
        //This will return a temporary data that was on the disk and also start the
        //synch process once more data is avaialble we will revert to the most updated
        //data. This approach allows the user to see something before collection info
        //is synched from the server. If there is nothing stored locally present user
        //with an empty board that should get merged with the server changes later
        NSData * collectionData = [self.dataSource getCollection:collectionName];
        
        if (collectionData == nil)
        {
            self.manifest = [[XoomlCollectionManifest alloc] initAsEmpty];
        }
        else
        {
            [self loadOfflineCollection:collectionData];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(collectionIsShared:)
                                                     name:COLLECTION_IS_SHARED
                                                   object:nil];
        
        
        //In any case listen for the download to get finished
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(collectionFilesDownloaded:)
                                                     name:COLLECTION_DOWNLOADED_EVENT
                                                   object:nil];
        
        //Gets notified when the server data is merged with local data
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mergeFinished:)
                                                     name:MANIFEST_MERGE_FINISHED_EVENT
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(noteImageDownloaded:)
                                                     name:IMAGE_DOWNLOADED_EVENT
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
    }
    return self;
}

-(NSString *) getImagePathForSubCollectionWithName:(NSString *) subCollectionName
{
    
    NSString * imagePath = [self.dataSource getImagePathForNote:subCollectionName
                                                  andCollection:self.collectionName];
    return imagePath;
}

-(void) addSubCollectionContentWithId: (NSString *) subCollectionId
                          withContent:(NSData *) content
              andCollectionAttributes:(CollectionNoteAttribute *) attributes
{
    
    [self.manifest addNoteWithID:subCollectionId andModel:attributes];
    NSString * subCollectionName = attributes.noteName;
    [self.dataSource addNote:subCollectionName
                 withContent:content
                ToCollection:self.collectionName];
    self.needSynchronization = YES;
}

-(void) addSubCollectionContentWithId:(NSString *)subCollectionId
                          withContent:(NSData *)content
                             andImage:(NSData *) img
                         andImageName:(NSString *) imgName
              andCollectionAttributes:(CollectionNoteAttribute *)attributes
{
    
    NSString * noteName = attributes.noteName;
    [self.manifest addNoteWithID:subCollectionId andModel:attributes];
    [self.manifest updateThumbnailWithImageOfNote:subCollectionId];
    [self.dataSource addImageNote: noteName
                  withNoteContent: content
                         andImage: img
                withImageFileName: imgName
                     toCollection:self.collectionName];
    self.needSynchronization = YES;
}

-(void) addCollectionAttributeWithName:(NSString *) stackingName
                             withModel:(StackingModel *)stackingModel
{
    [self.manifest addStacking:stackingName withModel:stackingModel];
    
    self.needSynchronization = YES;
}

-(void) setCollectionThumbnailWithData:(NSData *) thumbnailData
{
    [self.dataSource setThumbnail:thumbnailData forCollection:self.collectionName];
}

-(void) updateCollectionThumbnailWithImageOfSubCollection:(NSString *) subCollectionId
{
    [self.manifest updateThumbnailWithImageOfNote:subCollectionId];
}

-(void) updateSubCollectionContentofSubCollectionWithName:(NSString *) subCollectionName
                                              withContent:(NSData *) content
{
    [self.dataSource updateNote:subCollectionName
                    withContent:content
                   inCollection:self.collectionName];
}

-(void) updateCollectionAttributesForSubCollection:(NSString *) subCollectionId
                          withCollectionAttributes:(CollectionNoteAttribute *) collectionAttribute
{
    [self.manifest updateNote:subCollectionId withNewModel:collectionAttribute];
    self.needSynchronization = YES;
}

-(void) updateCollectionAttributeWithName:(NSString *) attributeName
                             withNewModel:(StackingModel *)stackingModel
{
    [self.manifest updateStacking:attributeName
                     withNewModel:stackingModel];
    self.needSynchronization = YES;
}
-(void) removeSubCollectionWithId:(NSString *)subCollectionId
                          andName:(NSString *)subCollectionName
{
    [self.manifest deleteNote:subCollectionId];
    
    [self.dataSource removeNote:subCollectionName
                 FromCollection:self.collectionName];
    
    self.needSynchronization = YES;
}

-(void) removeSubCollectionThumbnailForSubCollection:(NSString *) subCollectionId
{
    [self.manifest deleteThumbnailForNote:subCollectionId];
}

-(void) removeSubCollectionWithId:(NSString *) subCollectionId
       forCollectionAttributeOfName:(NSString *) collectionAttributeName
{
    [self.manifest removeNotes:@[subCollectionId] fromStacking:collectionAttributeName];
    self.needSynchronization = YES;
}

-(void) removeCollectionAttributeOfName:(NSString *) collectionAttributeName
{
    [self.manifest deleteStacking:collectionAttributeName];
    self.needSynchronization = YES;
}

-(void) loadOfflineCollection:(NSData *) collectionData{
    
    if (!collectionData)
    {
        NSLog(@"MindcloudCollectionGordon-collectionData is nil. Collection may not have download properly");
        return;
    }
    
    self.manifest = [[XoomlCollectionManifest alloc]  initWithData:collectionData];
    
    [self notifyDelegateOfCollectionThumbnail:self.manifest];
    [self notifyDelegateOfSubCollections:self.manifest];
    [self notifyDelegateOfCollectionAttributes:self.manifest];
    
}

-(void) notifyDelegateOfSubCollections:(id <CollectionManifestProtocol>) manifest
{
    //get notes from manifest and initalize those
    NSDictionary * noteInfo = [manifest getAllNotesBasicInfo];
    for(NSString * noteID in noteInfo){
        
        //for each note create a note Object by reading its separate xooml files
        //from the data model
        CollectionNoteAttribute * collectionNoteAttribute = noteInfo[noteID];
        NSString * subCollectionName = collectionNoteAttribute.noteName;
        NSData * subCollectionData = [self.dataSource getNoteForTheCollection:self.collectionName
                                                                     WithName:subCollectionName];
        if (!subCollectionData)
        {
            NSLog(@"MindcloudCollectionGordon-Could not retreive note data from dataSource");
        }
        else
        {
            if (self.delegate != nil)
            {
                id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
                [tempDelegate collectionHasSubCollectionWithId:subCollectionName
                                                       andData:subCollectionData
                                                 andAttributes:collectionNoteAttribute];
            }
        }
        
    }
}

-(void) notifyDelegateOfCollectionThumbnail:(id <CollectionManifestProtocol>) manifest
{
    //cause delegate is weak we need to do heavy checking so its not become nil
    if (self.delegate != nil)
    {
        NSString * collectionThumbnail = [manifest getCollectionThumbnailNoteId];
        id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
        [tempDelegate collectionHasThumbnailAtSubCollectionWithId:collectionThumbnail];
    }
}

-(void) notifyDelegateOfCollectionAttributes: (id <CollectionManifestProtocol>) manifest{
    //get the stacking information and cache them
    
    //getAllCollectionAttributes instead
    NSDictionary *stackingInfo = [manifest getAllStackingsInfo];
    for (NSString * stackingName in stackingInfo)
    {
        StackingModel * stackModel = stackingInfo[stackingName];
        if (self.delegate != nil)
        {
            id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
            [tempDelegate collectionHasCollectionAttributeOfType:@"Stacking"
                                                         andName:stackingName
                                                         andData:stackModel];
        }
    }
}
-(void) collectionIsShared:(NSNotification *) notification
{
    NSDictionary * result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    
    //you could be receiving notification for another collection
    //so make sure you are the one who is supposed to be receiving this
    if (collectionName != nil &&
        [collectionName isEqualToString:self.collectionName])
    {
        //make sure the data source knows about that we are shared
        //and synch to get the latest results
        [self.dataSource collectionIsShared:collectionName];
        if ([self.dataSource cacheHasBeenUpdatedLocalyForKey:self.collectionName])
        {
            [self.dataSource refreshCacheForKey:self.collectionName];
        }
        
        //if we start listening before being in sycnh with the server we may overwrite
        //the changes on the server with our out of synch changes.
        //Check whether you are in synch and start listening only if you are
        //if you are the synch event will start listening for you
        if (!self.hasStartedListening && self.isInSynchWithServer)
        {
            self.synchronizationPeriod = SHARED_SYNCH_PERIOD;
            [self.sharingAdapter startListening];
            self.hasStartedListening = YES;
            [self restartTimer];
        }
    }
}


-(void) subCollectionisWaitingForImageWithSubCollectionId:(NSString *) subCollectionId
                                                  andSubCollectionName:(NSString *) subCollectionName
{
    [self.waitingNoteImages setObject:subCollectionId forKey:subCollectionName];
}

-(void) collectionFilesDownloaded: (NSNotification *) notification{
    
    NSData * collectionData = [self.dataSource getCollectionFromCache:self.collectionName];
    if (!collectionData)
    {
        NSLog(@"MindcloudCollectionGordon -Collection Data is nil. Data must have not been downloaded properly");
        return;
    }
    id<CollectionManifestProtocol> serverManifest = [[XoomlCollectionManifest alloc]  initWithData:collectionData];
    id<CollectionManifestProtocol> clientManifest = [self.manifest copy];
    MergerThread * mergerThread = [MergerThread getInstance];
    
    [self initiateSubCollectionsFromDownloadedManifest:serverManifest];
    
    CollectionRecorder * recorder = nil;
    if (self.delegate != nil)
    {
        id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
        recorder = [tempDelegate getEventRecorder];
    }
    
    //when the merge is finished we will be notified
    //its ok if recorder is null its an optional
    [mergerThread submitClientManifest:clientManifest
                     andServerManifest:serverManifest
                     andActionRecorder:recorder
                     ForCollectionName:self.collectionName];
    
    [self notifyDelegateOfCollectionThumbnail:serverManifest];
}

-(void) initiateSubCollectionsFromDownloadedManifest:(id<CollectionManifestProtocol>) manifest
{
    //make sure to add the notes that are downloaded separately
    NSDictionary * subCollectionsInfo = [manifest getAllNotesBasicInfo];
    for(NSString * subCollectionId in subCollectionsInfo)
    {
        CollectionNoteAttribute * subCollectionAttribute = subCollectionsInfo[subCollectionId];
        NSString * subCollectionName = subCollectionAttribute.noteName;
        NSData * subCollectionData = [self.dataSource getNoteForTheCollection:self.collectionName
                                                                     WithName:subCollectionName];
        
        if (!subCollectionData) NSLog(@"MindcloudCollectionGordon - Could not retreive note data from dataSource");
        else
        {
            [self initiateDownloadSubCollection:subCollectionData
                             forSubCollectionId:subCollectionId
                         andCollectionAttribute:subCollectionAttribute];
        }
    }
    
    //send out a note content update
    if (subCollectionsInfo != nil)
    {
        NSDictionary * userDict = @{@"result": subCollectionsInfo.allKeys};
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_CONTENT_UPDATED_EVENT
                                                            object:self
                                                          userInfo:userDict];
    }
}

-(void) initiateDownloadSubCollection:(NSData *) subCollectionData
                   forSubCollectionId:(NSString *) subCollectionId
               andCollectionAttribute:(CollectionNoteAttribute *) subCollectionAttribute
{
    
    if (self.delegate!= nil)
    {
        id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
        [tempDelegate subCollectionPartiallyDownloadedWithId:subCollectionId
                                                     andData:subCollectionData
                                  andSubCollectionAttributes:subCollectionAttribute];
    }
}


-(void) noteImageDownloaded:(NSNotification *) notification
{
    
    NSDictionary * dict = notification.userInfo[@"result"];
    NSString * collectionName = dict[@"collectionName"];
    NSString * noteName = dict[@"noteName"];
    NSString * imgPath = [FileSystemHelper getPathForSubCollectionImageforSubCollectionName:noteName
                                                          inCollection:self.collectionName];
    if (imgPath != nil && ![imgPath isEqualToString:@""])
    {
        NSString * noteID = self.waitingNoteImages[noteName];
        if (noteID)
        {
            
            if (self.delegate)
            {
                id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
                [tempDelegate subCollectionWithId:noteID
                          downloadedImageWithPath:imgPath];
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
/*
 Gets called when we finish merging two manifests
 */
-(void) mergeFinished:(NSNotification *) notification
{
    NSLog(@"MindcloudCollectionGordon - merge Finished");
    MergeResult * mergeResult = notification.userInfo[@"result"];
    
    if (!mergeResult) return;
    
    if (![mergeResult.collectionName isEqualToString:self.collectionName]) return;
    
    
    CollectionRecorder * recorder = nil;
    if (self.delegate != nil)
    {
        id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
        recorder = [tempDelegate getEventRecorder];
        NotificationContainer * notifications = mergeResult.notifications;
        [tempDelegate eventsOccurredWithNotifications:notifications];
    }
    
    self.manifest = mergeResult.finalManifest;
    [self startTimer];
    
    if (recorder && [recorder hasAnythingBeenTouched])
    {
        [recorder reset];
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

-(void) listenerDownloadedNote:(NSNotification *) notification
{
    NSDictionary * result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    NSArray * notes = result[@"notes"];
    if ([collectionName isEqualToString:self.collectionName])
    {
        for (NSString * subCollectionId in notes)
        {
            NSData * subCollectionData = [self.dataSource getNoteForTheCollection:collectionName
                                                                WithName:subCollectionId];
            
            if (self.delegate)
            {
                id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
                [tempDelegate eventOccuredWithDownloadingOfSubColection:subCollectionId
                                                   andSubCollectionData:subCollectionData];
            }
        }
    }
}

-(void) cacheIsSynched:(NSNotification *) notification
{
    self.isInSynchWithServer = YES;
}

-(void) listenerDownloadedNoteImage:(NSNotification *) notification
{
    NSDictionary * result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    NSString * noteName = result[@"noteName"];
    if ([collectionName isEqualToString:self.collectionName])
    {
        NSString * imagePath = [self.dataSource getImagePathForNote:noteName
                                                      andCollection:collectionName];
        NSData * noteData = [self.dataSource getNoteForTheCollection:collectionName
                                                            WithName:noteName];
        if (self.delegate)
        {
            id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
            [tempDelegate eventOccuredWithDownloadingOfSubCollectionImage:noteName
                                                            withImagePath:imagePath
                                                     andSubCollectionData:noteData];
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
    if ([collectionName isEqualToString:self.collectionName])
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
        
        CollectionRecorder * recorder = nil;
        if (self.delegate != nil)
        {
            id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
            recorder = [tempDelegate getEventRecorder];
        }
        
        //when the merge is finished we will be notified
        [mergerThread submitClientManifest:clientManifest
                         andServerManifest:serverManifest
                         andActionRecorder:recorder
                         ForCollectionName:self.collectionName];
            
    }
}

-(void)restartTimer{
    [self stopTimer];
    [self startTimer];
}

-(void) startTimer{
    
    if (self.timer.isValid) return;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.synchronizationPeriod
                                                  target:self
                                                selector:@selector(synchronize:)
                                                userInfo:nil
                                                 repeats:YES];
    NSLog(@"MindCloudCollectionGordon-Timer started for %ld seconds", self.synchronizationPeriod);
}

-(void) stopTimer{
    [self.timer invalidate];
}

#pragma mark - Synchronization Helpers
/*
 Every SYNCHRONIZATION_PERIOD seconds we try to synchrnoize.
 If the synchronize flag is set the bulletin board is updated from Xooml Data in manifest
 */
+(void) saveBulletinBoard:(id) collectionObj{
    
    if ([collectionObj isKindOfClass:[self class]]){
        
        MindcloudCollectionGordon * collection = (MindcloudCollectionGordon *) collectionObj;
        [collection.dataSource updateCollectionWithName:collection.collectionName
                                        andContent:[collection.manifest data]];
        if (collection.delegate != nil)
        {
            id<MindcloudCollectionGordonDelegate> tempDelegate = collection.delegate;
            CollectionRecorder * recorder = [tempDelegate getEventRecorder];
            [recorder reset];
        }
    }
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
    [self.dataSource getCollection:self.collectionName];
}

#pragma mark - cleanup
-(void) cleanup{
    //check out of the notification center
    [self.sharingAdapter stopListening];
    [self stopTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
