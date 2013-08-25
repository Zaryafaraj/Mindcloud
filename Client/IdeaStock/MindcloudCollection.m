//
//  MindcloudCollection.m
//  Mindcloud
//
//  Created by Ali Fathalian on 3/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MindcloudCollection.h"
#import "XoomlCollectionParser.h"
#import "MindcloudCollectionGordon.h"
#import "EventTypes.h"
#import "CollectionRecorder.h"
#import "NoteResolutionNotification.h"
#import "NoteFragmentResolver.h"
#import "FileSystemHelper.h"

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
 To record any possible conflicting items for synchronization
 */
@property (strong, atomic) CollectionRecorder * recorder;

@property (strong, atomic) MindcloudCollectionGordon * gordonDataSource;

/*
 For resolving different parts of a new note that arrive separately. 
 We register events when a part arrives and this class is smart enough to know whether everything is in place.
 When a subcollection is completely in place. This object sends out a notification
 */
@property (strong, atomic) NoteFragmentResolver * noteResolver;

@end

@implementation MindcloudCollection
@synthesize bulletinBoardName = _bulletinBoardName;

#pragma mark - Initialization
-(id) initCollection:(NSString *)collectionName
{
    self = [super init];
    
    self.recorder = [[CollectionRecorder alloc] init];
    self.thumbnailStack = [NSMutableArray array];
    self.downloadableImageNotes = [NSMutableSet set];
    self.imagePathsForNotes = [NSMutableDictionary dictionary];
    self.collectionNoteAttributes = [NSMutableDictionary dictionary];
    self.collectionAttributesForNotes = [NSMutableDictionary dictionary];
    self.stackings = [NSMutableDictionary dictionary];
    self.noteToStackingMap = [NSMutableDictionary dictionary];
    
    self.bulletinBoardName = collectionName;
    
    self.gordonDataSource = [[MindcloudCollectionGordon alloc] initWithCollectionName:collectionName
                                                                          andDelegate:self];
    
    
    //notifications for note resolver
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noteResolved:)
                                                 name:NOTE_RESOLVED_EVENT
                                               object:nil];
    
    
    
    
    
    return self;
}

#pragma mark - Notifications

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
            [self.gordonDataSource updateCollectionThumbnailWithImageOfSubCollection:noteId];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_ADDED_EVENT
                                                                object:self
                                                              userInfo:userInfo];
            
        }
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
    
    
    
    self.collectionAttributesForNotes[noteID] = collectionNoteAttribute;
    
    NSData * noteData = [XoomlCollectionParser convertNoteToXooml:note];
    [self.gordonDataSource  addSubCollectionContentWithId:noteID
                                              withContent:noteData
                                  andCollectionAttributes:collectionNoteAttribute];
    
    [self.recorder recordUpdateNote:noteID];
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
    
    [self.gordonDataSource addSubCollectionContentWithId:noteID
                                             withContent:noteData
                                                andImage:img
                                            andImageName:imgName
                                 andCollectionAttributes:collectionNoteAttribute];
    [self.recorder recordUpdateNote:noteID];
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
    
    [self.gordonDataSource addCollectionAttributeWithName:stackingName
                                                withModel:stackingModel];
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
    
    [self.gordonDataSource removeSubCollectionWithId:delNoteID andName:noteName];
    
    [self.recorder recordDeleteNote:noteName];
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
        [self.gordonDataSource updateCollectionThumbnailWithImageOfSubCollection:lastThumbnailNoteId];
    }
    else
    {
        [self.gordonDataSource removeSubCollectionThumbnailForSubCollection:delNoteID];
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
    
    [self.gordonDataSource removeSubCollectionWithId:noteID forCollectionAttributeOfName:stackingName];
    [self.recorder recordUpdateStack:stackingName];
    
}

-(void) removeStacking:(NSString *) stackingName
{
    
    StackingModel * stackingModel = self.stackings[stackingName];
    for(NSString * noteId in stackingModel.refIds)
    {
        [self.noteToStackingMap removeObjectForKey:noteId];
    }
    
    [self.stackings removeObjectForKey:stackingName];
    
    [self.gordonDataSource removeCollectionAttributeOfName:stackingName];
    [self.recorder recordDeleteStack:stackingName];
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
    
    [self.gordonDataSource updateSubCollectionContentofSubCollectionWithName:noteName
                                                                 withContent:noteData];
    [self.recorder recordUpdateNote:noteID];
}

-(void) updateNoteAttributes: (NSString *) noteID
                   withModel: (CollectionNoteAttribute *) collectionNoteAttribute
{
    
    if (!(self.collectionNoteAttributes)[noteID]) return;
    
    CollectionNoteAttribute * oldcollectionNoteAttribute = self.collectionAttributesForNotes[noteID];
    oldcollectionNoteAttribute.scaling = collectionNoteAttribute.scaling;
    
    [self.gordonDataSource updateCollectionAttributesForSubCollection:noteID withCollectionAttributes:collectionNoteAttribute];
    [self.recorder recordUpdateNote:noteID];
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
    
    [self.gordonDataSource updateCollectionAttributeWithName:stackingName withNewModel:stackingModel];
    
    [self.recorder recordUpdateStack:stackingName];
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
    [self.gordonDataSource cleanup];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.recorder reset];
}

#pragma - thumbnail related actions
-(void) saveThumbnail:(NSData *)thumbnailData
{
    [self.gordonDataSource setCollectionThumbnailWithData:thumbnailData];
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

#pragma mark - Gordon delegate

-(void) collectionHasThumbnailAtSubCollectionWithId:(NSString *)subCollectionId
{
    if (subCollectionId != nil)
    {
        self.originalThumbnail = subCollectionId;
    }
}

-(void) collectionHasSubCollectionWithId:(NSString *)subCollectionId
                                 andData:(NSData *) subCollectionData
                           andAttributes:(CollectionNoteAttribute *)attribute
{
    
    id <NoteProtocol> noteObj = [XoomlCollectionParser xoomlNoteFromXML:subCollectionData];
    if (!noteObj) return ;
    
    (self.collectionNoteAttributes)[subCollectionId] = noteObj;
    //note could have an image or not. If it has an image we have to also add it to note images
    NSString * imgName = noteObj.image;
    if (imgName != nil)
    {
        [self.downloadableImageNotes addObject:subCollectionId];
        NSString * imagePath = [self.gordonDataSource getImagePathForSubCollectionWithName:attribute.noteName];
        if (imagePath)
        {
            self.imagePathsForNotes[subCollectionId] = imagePath;
            [self.thumbnailStack addObject:subCollectionId];
        }
        
        [self.gordonDataSource subCollectionisWaitingForImageWithSubCollectionId:subCollectionId andSubCollectionName:attribute.noteName];
    }
    
    
    self.collectionAttributesForNotes[subCollectionId] = attribute;
}

-(void) collectionHasCollectionAttributeOfType:(NSString *) subCollectionType
                                       andName:(NSString *) attributeName
                                       andData:(StackingModel *) stackingModel
{
    //Get STacking type and check against subCollectionType
    self.stackings[attributeName] = stackingModel;
    for (NSString * refId in stackingModel.refIds)
    {
        self.noteToStackingMap[refId] = attributeName;
    }
}


-(void) subCollectionPartiallyDownloadedWithId:(NSString *) subCollectionId
                                       andData:(NSData *) subCollectionData
                    andSubCollectionAttributes:(CollectionNoteAttribute *) subCollectionAttribute
{
    
    id <NoteProtocol> noteObj = [XoomlCollectionParser xoomlNoteFromXML:subCollectionData];
    if (!noteObj) return ;
    
    //register the
    [self.noteResolver noteContentReceived:noteObj forNoteId:subCollectionId];
    
    
    //set the note content as soon as you receive it
    self.collectionNoteAttributes[subCollectionId] = noteObj;
    //note could have an image or not. If it has an image we have to also add it to note images
    NSString * imgName = noteObj.image;
    if (imgName != nil)
    {
        [self.downloadableImageNotes addObject:subCollectionId];
        NSString * imagePath = [self.gordonDataSource getImagePathForSubCollectionWithName:subCollectionAttribute.noteName];
        
        if (imagePath)
        {
            [self.noteResolver noteImagePathReceived:imagePath forNoteId:subCollectionId];
            [self.thumbnailStack addObject:subCollectionId];
        }
        [self.gordonDataSource subCollectionisWaitingForImageWithSubCollectionId:subCollectionId andSubCollectionName:subCollectionAttribute.noteName];
    }
}


//when anything happens to a collection you will get these info
-(void) eventsOccurredWithNotifications: (NotificationContainer *) notifications
{
    //The order of these updates are optimized
    [self updateCollectionForDeleteStackingNotifications:notifications.getDeleteStackingNotifications];
    [self updateCollectionForDeleteNoteNotifications: notifications.getDeleteNoteNotifications];
    [self updateCollectionForAddNoteNotifications:notifications.getAddNoteNotifications];
    [self updateCollectionForAddStackingNotifications:notifications.getAddStackingNotifications];
    [self updateCollectionForUpdateStackingNotifications:notifications.getUpdateStackingNotifications];
    [self updateCollectionForUpdateNoteNotifications:notifications.getUpdateNoteNotifications];
}

-(void) subCollectionWithId:(NSString *) subCollectionId
    downloadedImageWithPath:(NSString *) imagePath
{
    
    (self.imagePathsForNotes)[subCollectionId] = imagePath;
    //if we are waiting for this let the resolver know
    if ([self.noteResolver hasNoteWaitingForResolution:subCollectionId])
    {
        [self.noteResolver noteImagePathReceived:imagePath forNoteId:subCollectionId];
    }
}

-(void) eventOccuredWithDownloadingOfSubColection:(NSString *) subCollectionName
                             andSubCollectionData:(NSData *) subCollectionData
{
    id<NoteProtocol> noteObj = [XoomlCollectionParser xoomlNoteFromXML:subCollectionData];
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

-(void) eventOccuredWithDownloadingOfSubCollectionImage:(NSString *) subCollectionId
                                          withImagePath:(NSString *) imagePath
                                   andSubCollectionData:(NSData *) subCollectionData
{
    id<NoteProtocol> noteObj = [XoomlCollectionParser xoomlNoteFromXML:subCollectionData];
    NSString * noteId = [noteObj noteTextID];
    
    //if this is only an update, update the image path and send the notification
    if (self.imagePathsForNotes[noteId] && self.collectionNoteAttributes[noteId])
    {
        self.imagePathsForNotes[noteId] = imagePath;
        self.collectionNoteAttributes[noteId] = noteObj;
        
        //update thumbnail
        [self.thumbnailStack addObject:noteId];
        self.originalThumbnail = nil;
        [self.gordonDataSource updateCollectionThumbnailWithImageOfSubCollection:subCollectionId];
        
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

-(CollectionRecorder *) getEventRecorder
{
    return self.recorder;
}

-(void) refresh
{
    [self.gordonDataSource refresh];
}

-(void) pause
{
    [self.gordonDataSource stopSynchronization];
}

-(void) save
{
    [self.gordonDataSource synchronize];
}

@end