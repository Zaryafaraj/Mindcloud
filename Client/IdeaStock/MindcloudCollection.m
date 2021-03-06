//
//  MindcloudCollection.m
//  Mindcloud
//
//  Created by Ali Fathalian on 3/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MindcloudCollection.h"
#import "MindcloudCollectionGordon.h"
#import "EventTypes.h"
#import "CollectionRecorder.h"
#import "NoteResolutionNotification.h"
#import "NoteFragmentResolver.h"
#import "FileSystemHelper.h"
#import "CollectionNote.h"
#import "ExternalFileHelper.h"
#import "MessageFactory.h"

@interface MindcloudCollection()

/* Acts as a cache in order to not explicitly call gordon every time we change
 drawing */
@property (nonatomic) BOOL drawingAttributeExists;
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


@property (strong, atomic) MindcloudCollectionGordon * gordonDataSource;

/*
 For resolving different parts of a new note that arrive separately. 
 We register events when a part arrives and this class is smart enough to know whether everything is in place.
 When a subcollection is completely in place. This object sends out a notification
 */
@property (strong, atomic) NoteFragmentResolver * noteResolver;

//this is to make sure we don't redownload or re-retrieve the files from the disk or server.
//once any asset is downloaded there is no more need to downloaded it because sharing events
//will take care of it
@property (strong, atomic) NSMutableSet * downloadedFiles;

@end

@implementation MindcloudCollection
@synthesize bulletinBoardName = _bulletinBoardName;

#pragma mark - Initialization
-(id) initCollection:(NSString *)collectionName
{
    self = [super init];
    
    self.thumbnailStack = [NSMutableArray array];
    self.downloadableImageNotes = [NSMutableSet set];
    self.imagePathsForNotes = [NSMutableDictionary dictionary];
    self.collectionNoteAttributes = [NSMutableDictionary dictionary];
    self.collectionAttributesForNotes = [NSMutableDictionary dictionary];
    self.stackings = [NSMutableDictionary dictionary];
    self.noteToStackingMap = [NSMutableDictionary dictionary];
    self.downloadedFiles = [NSMutableSet set];
    self.bulletinBoardName = collectionName;
    self.drawingAttributeExists = NO;
    self.gordonDataSource = [[MindcloudCollectionGordon alloc] initWithCollectionName:collectionName
                                                                          andDelegate:self];
    
   
    [self.gordonDataSource connectToCollection:collectionName];
    
    self.noteResolver = [[NoteFragmentResolver alloc] initWithCollectionName:collectionName];
    //notifications for note resolver
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noteResolved:)
                                                 name:ASSOCIATION_RESOLVED_EVENT
                                               object:nil];
    return self;
}

-(void) setBulletinBoardName:(NSString *)bulletinBoardName
{
    NSString * oldName = _bulletinBoardName;
    
    //TODO this is a bad way of doing this. We should not save the collection
    //nbame in the path. and create the path dynamically
    for(NSString * noteId in self.imagePathsForNotes)
    {
        NSString * imagePath = self.imagePathsForNotes[noteId];
        NSString * oldPath = [NSString stringWithFormat:@"/%@/", oldName];
        NSString * newPath = [NSString stringWithFormat:@"/%@/", bulletinBoardName];
        imagePath = [imagePath stringByReplacingOccurrencesOfString:oldPath
                                                         withString:newPath];
        self.imagePathsForNotes[noteId] = imagePath;
    }
    _bulletinBoardName = bulletinBoardName;
    self.gordonDataSource.collectionName = bulletinBoardName;
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
            [[NSNotificationCenter defaultCenter] postNotificationName:ASSOCIATION_WITH_IMAGE_ADDED_EVENT
                                                                object:self
                                                              userInfo:userInfo];
            
            [self.thumbnailStack addObject:noteId];
            self.originalThumbnail = nil;
            [self.gordonDataSource setCollectionThumbnailWithImageOfAssociation:noteId];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:ASSOCIATION_ADDED_EVENT
                                                                object:self
                                                              userInfo:userInfo];
            
        }
    }
}

#pragma mark - Creation

-(void) addNoteWithContent: (id <NoteProtocol>) note
              andCollectionAttributes:(CollectionNoteAttribute *) collectionNoteAttribute
{
    NSString * noteID = note.noteId;
    NSString * noteName = collectionNoteAttribute.noteName;
    if (!noteID || !noteName) [NSException raise:NSInvalidArgumentException
                                          format:@"A Values is missing from the required properties dictionary"];
    (self.collectionNoteAttributes)[noteID] = note;
    
    
    
    self.collectionAttributesForNotes[noteID] = collectionNoteAttribute;
    
    
    XoomlFragment * noteFragment = [note toXoomlFragment];
    
    
    [self.gordonDataSource  addAssociationWithName:collectionNoteAttribute.noteName
                                          andAssociatedItem:noteFragment
                             andAssociation:[collectionNoteAttribute toXoomlAssociation]];
    
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
    XoomlFragment * noteFragment =  [noteItem toXoomlFragment];
    NSString * imgPath = [FileSystemHelper getPathForAssociatedItemImageforAssociatedItemName:noteName
                                                          inCollection:self.bulletinBoardName];
    (self.imagePathsForNotes)[noteID] = imgPath;
    [self.thumbnailStack addObject:noteID];
    self.originalThumbnail = nil;
    
    XoomlAssociation * association = [collectionNoteAttribute toXoomlAssociation];
    
    [self.gordonDataSource addAssociationWithName:noteName
                                         andAssociatedItem:noteFragment
                           andAssociation:association
                                       andAssociationImageData:img
                                       andImageName:noteItem.image];
    
}

-(void) setDrawingAttribute
{
    if (!self.drawingAttributeExists)
    {
        
        NSString * fileName = [ExternalFileHelper filenameForScreenDrawing];
        [self.gordonDataSource setCollectionFragmentNamespaceFileWithName:fileName
                                                         andAttributeName:MINDCLOUD_DRAWING_ATTRIBUTE
                                                   andParentNamespaceName:MINDCLOUD_BOARDS_NAMESPACE andFixedId:VERSIONED_MINDCLOUD_DRAWING_ID];
        self.drawingAttributeExists = YES;
    }
}

-(void) saveAllDrawingsFile:(ScreenDrawing *) allDrawings
{
    NSString * fileName = [ExternalFileHelper filenameForScreenDrawing];
    [self.gordonDataSource saveCollectionAsset:allDrawings
                                  withFileName:fileName];
}

-(void) sendDiffDrawings:(ScreenDrawing *)diffDrawings
{
    
    NSString * fileName = [ExternalFileHelper filenameForScreenDrawing];
    [self.gordonDataSource sendCollectionDiffFileWithFilename:fileName
                                                   andContent:diffDrawings];
}

-(void) sendUndoMessage:(NSArray *)orderIndexes
{
    UndoMessage * message = [MessageFactory undoMessageWithOrderIndices:orderIndexes];
    NSString * messageString = [message messageString];
    [self.gordonDataSource sendCustomMessageToEveryone:messageString
                                         withMessageId:message.messageId];
    
}

-(void) sendRedoMessage:(NSArray *)orderIndexes
{
    RedoMessage * message = [MessageFactory redoMessageWithOrderIndices:orderIndexes];
    NSString * messageString = [message messageString];
    [self.gordonDataSource sendCustomMessageToEveryone:messageString
                                         withMessageId:message.messageId];
}

-(void) sendClearMessage
{
    ClearMessage * message = [MessageFactory clearMessage];
    NSString * messageString = [message messageString];
    [self.gordonDataSource sendCustomMessageToEveryone:messageString
                                         withMessageId:message.messageId];
}

-(void) addNotesWithIDs: (NSArray *) noteIDs
             toStacking:(NSString *) stackingId
{
    //validate that all the notes exist
    for (NSString * noteId in noteIDs){
        if (!self.collectionNoteAttributes[noteId]) return;
    }
    
    NSSet * noteRefs = [NSSet setWithArray:noteIDs];
    CollectionStackingAttribute * stackingModel = self.stackings[stackingId];
    if (!stackingModel)
    {
        stackingModel = [[CollectionStackingAttribute alloc] initWithId:stackingId
                                                        andScale:@"1.0"
                                                       andRefIds:noteRefs];
        self.stackings[stackingId] = stackingModel;
    }
    else
    {
        [stackingModel addNotes:noteRefs];
    }
    
    for(NSString * noteId in noteIDs)
    {
        self.noteToStackingMap[noteId] = stackingId;
    }
    
    [self.gordonDataSource setCollectionFragmentNamespaceSubElementWithNewElement:[stackingModel toXoomlNamespaceElement]];
}

#pragma mark - Deletion

-(void) removeNoteFromAllStackings:(NSString *) noteId
{
    for (NSString * stacking in self.stackings)
    {
        CollectionStackingAttribute * stackingModel = self.stackings[stacking];
        if ([stackingModel.refIds containsObject:noteId])
        {
            [stackingModel deleteNotes:[NSSet setWithObject:noteId]];
            XoomlNamespaceElement * elemToUpdate = [stackingModel toXoomlNamespaceElement];
            [self.gordonDataSource setCollectionFragmentNamespaceSubElementWithNewElement:elemToUpdate];
            [self.noteToStackingMap removeObjectForKey:noteId];
        }
    }
}

-(void) removeNotesFromAllStackings:(NSSet *) noteIds
{
    //could be more optmized using the noteStacking mapping instead of this iteration
    for (NSString * stacking in self.stackings)
    {
        CollectionStackingAttribute * stackingModel = self.stackings[stacking];
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
    
    [self.gordonDataSource removeAssociationWithRefId:delNoteID
                                andAssociatedItemName:noteName ];
    
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
        [self.gordonDataSource setCollectionThumbnailWithImageOfAssociation:lastThumbnailNoteId];
    }
    else
    {
        //If there is no thumbnail available for the collection remove the association
        [self.gordonDataSource removeThumbnailForCollection];
    }
}

-(void) removeNote:(NSString *) noteID
      fromStacking:(NSString *) stackingId
{
    //if the noteId is not valid return
    if (!(self.collectionNoteAttributes)[noteID]) return;
    
    CollectionStackingAttribute * stacking = self.stackings[stackingId];
    [stacking deleteNotes:[NSSet setWithObject:noteID]];
    [self.noteToStackingMap removeObjectForKey:noteID];
    
    //if stacking is nil it means that removing that note caused the stacking to
    //get deleted so we should remove the stacking
    if (stacking == nil)
    {
        [self.gordonDataSource removeCollectionFragmentNamespaceSubElementWithId:stackingId
                                                                   fromNamespace:MINDCLOUD_BOARDS_NAMESPACE];
    }
    else
    {
        XoomlNamespaceElement * element = [stacking toXoomlNamespaceElement];
        [self.gordonDataSource setCollectionFragmentNamespaceSubElementWithNewElement:element];
    }
}

-(void) removeStacking:(NSString *) stackingId
{
    
    CollectionStackingAttribute * stackingModel = self.stackings[stackingId];
    for(NSString * noteId in stackingModel.refIds)
    {
        [self.noteToStackingMap removeObjectForKey:noteId];
    }
    
    [self.stackings removeObjectForKey:stackingId];
    
    [self.gordonDataSource removeCollectionFragmentNamespaceSubElementWithId: stackingId fromNamespace:MINDCLOUD_BOARDS_NAMESPACE];
}

#pragma mark - Update

- (void) updateNoteContentOf:(NSString *)noteID
              withContentsOf:(id<NoteProtocol>)newNote{
    
    id <NoteProtocol> oldNote = self.collectionNoteAttributes[noteID];
    if (!oldNote) return;
    
    //for attributes in newNote that a value is specified; update those
    NSString * newNoteText = newNote.noteText;
    NSString * newNoteId = newNote.noteId;
    newNote = [oldNote prototype];
    if (newNoteText)
    {
        newNote.noteText = newNoteText;
    }
    
    if (newNoteId)
    {
        newNote.noteId = newNoteId;
    }
    
    XoomlFragment * noteFragment = [newNote toXoomlFragment];
    self.collectionNoteAttributes[noteID] = newNote;
    
    CollectionNoteAttribute * collectionNoteAttribute = self.collectionAttributesForNotes[noteID];
    NSString * noteName = collectionNoteAttribute.noteName;
    
    [self.gordonDataSource setAssociatedItemWithName:noteName
                                                                 toAssociatedItem:noteFragment];
}


-(void) updateNoteAttributes: (NSString *) noteID
                   withModel: (CollectionNoteAttribute *) collectionNoteAttribute
{
    
    if (!(self.collectionNoteAttributes)[noteID]) return;
    
    CollectionNoteAttribute * oldcollectionNoteAttribute = self.collectionAttributesForNotes[noteID];
    oldcollectionNoteAttribute.scaling = collectionNoteAttribute.scaling;
    
    [self.gordonDataSource setAssociationWithRefId:noteID
                                     toAssociation:[collectionNoteAttribute toXoomlAssociation]];
}

//this is ugly as it isn't consistent and doesn't update the notes in the stacking
//its for performance reasons
-(void) updateStacking:(NSString *) stackingId
          withNewModel:(CollectionStackingAttribute *) stackingModel
{
    CollectionStackingAttribute * oldStackingModel =  self.stackings[stackingId];
    if (stackingModel.scale)
    {
        oldStackingModel.scale = stackingModel.scale;
    }
    if (stackingModel.ID)
    {
        oldStackingModel.ID = stackingModel.ID;
    }
    
    [self.gordonDataSource setCollectionFragmentNamespaceSubElementWithNewElement:[stackingModel toXoomlNamespaceElement]];
    
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

-(CollectionStackingAttribute *) getStackModelFor:(NSString *) stackID
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
-(void) updateCollectionForAddAssociationNotifications:(NSArray *) possibleNotifications
{
    //the contents of these notes may be added later by another notifiaction
    for(AddAssociationNotification * associationNotification in possibleNotifications)
    {
        CollectionNoteAttribute * newCollectionNoteAttribute = [CollectionNoteAttribute CollectionNoteAttributeFromAssociation:[associationNotification getAssociation]];
        
        NSString * noteId = [associationNotification getAssociation].refId;
        
        if (newCollectionNoteAttribute != nil && noteId != nil)
        {
            //the note resolver takes care of updates when all the information is at hand
            [self.noteResolver CollectionNoteAttributeReceived:newCollectionNoteAttribute forNoteId:noteId];
            
        }
    }
}

-(void) updateCollectionForUpdateAssociationNotifications:(NSArray *) possibleAssociations
{
    NSMutableArray * updatedNotes = [NSMutableArray array];
    for (UpdateAssociationNotification * associationNotification in possibleAssociations)
    {
        
        CollectionNoteAttribute * newCollectionNoteAttribute = [CollectionNoteAttribute CollectionNoteAttributeFromAssociation:[associationNotification getAssociation]];
        
        //if we are not a note ignore
        if (newCollectionNoteAttribute == nil) continue;
        
        NSString * noteId = [associationNotification getAssociation].refId;
        
        if (noteId == nil) continue;
        [updatedNotes addObject:noteId];
        //TODO make sure we need to add this here
        self.collectionAttributesForNotes[noteId] = newCollectionNoteAttribute;
    }
    
    if ([updatedNotes count] == 0) return;
    
    NSDictionary * userInfo = @{@"result" : [updatedNotes copy]};
    
    NSLog(@"MindcloudCollection: Update Note Event: %@", updatedNotes);
    [[NSNotificationCenter defaultCenter] postNotificationName:ASSOCIATION_UPDATED_EVENT
                                                        object:self
                                                      userInfo:userInfo];
}

-(void) updateCollectionForDeleteAssociationNotifications:(NSArray *) possibleAssociationsNotifications
{
    NSMutableDictionary * deletedNotes = [NSMutableDictionary dictionary];
    for (DeleteAssociationNotification * notification in possibleAssociationsNotifications)
    {
        
        NSString * noteId = [notification getRefId];
        
        if (noteId == nil) break;
        
        [self.collectionNoteAttributes removeObjectForKey:noteId];
        [self.collectionAttributesForNotes removeObjectForKey:noteId];
        if (self.imagePathsForNotes[noteId])
        {
            [self removeNoteImage:noteId];
        }
        NSString * correspondingStacking = self.noteToStackingMap[noteId];
        if (correspondingStacking)
        {
            deletedNotes[noteId] = @{@"stacking":correspondingStacking};
        }
        else
        {
            deletedNotes[noteId] = @{};
        }
    }
    
    if ([deletedNotes count] == 0 ) return;
    
    [self removeNotesFromAllStackings:[NSSet setWithArray:[deletedNotes allKeys]]];
    
    NSDictionary * userInfo =  @{@"result" :  deletedNotes};
    
    NSLog(@"MindcloudCollection: Delete Note Event: %@", deletedNotes);
    [[NSNotificationCenter defaultCenter] postNotificationName:ASSOCIATION_DELETED_KEY
                                                        object:self
                                                      userInfo:userInfo];
}

-(void) updateCollectionForAddSubelementNotifications:(NSArray *) notifications
{
    //for a stacking we add it anyways and add notes that are alread there.
    //When a new note comes in that was part of the stacking but we didn't have it
    //the UI checks for it and adds it
    NSMutableArray * addedStackings = [NSMutableArray array];
    for (AddFragmentNamespaceSubElementNotification * notification in notifications)
    {
        XoomlNamespaceElement * subElement = [notification getSubElement];
        if ([subElement.name isEqualToString:MINDCLOUD_DRAWING_ATTRIBUTE])
        {
            //we have a drawing. Download it. Once the download is done. The notificatiosn
            //will take care of displaying it
            [self.gordonDataSource getCollectionAssetForNamespaceElement:subElement];
        }
        else
        {
            CollectionStackingAttribute * newStackingModel = [CollectionStackingAttribute collectionSTackingAttributeFromNamespaceElement:[notification getSubElement]];
            
            //if its not a stacking ignore
            if(newStackingModel == nil) continue;
            
            NSString * stackId = [notification getSubElement].ID;
            self.stackings[stackId] = newStackingModel;
            for (NSString * noteId in newStackingModel.refIds)
            {
                self.noteToStackingMap[noteId] = newStackingModel.ID;
            }
            [addedStackings addObject:stackId];
        }
        
        if ([addedStackings count] == 0) return;
        
    }
    
    if (addedStackings.count > 0)
    {
        NSDictionary * userInfo =  @{@"result" :  addedStackings};
        
        NSLog(@"MindcloudCollection: Add Stacking Event: %@", addedStackings);
        [[NSNotificationCenter defaultCenter] postNotificationName:STACK_ADDED_EVENT
                                                            object:self
                                                          userInfo:userInfo];
    }
}

-(void) updateCollectionForUpdateSubelementNotifications:(NSArray *) notifications
{
    //we treat update stacking just like add stacking. New notes will be added to
    //it once they arrive
    NSMutableArray * updatedStackings = [NSMutableArray array];
    for(UpdateFragmentNamespaceSubElementNotification * notification in notifications)
    {
        
        XoomlNamespaceElement * subElement = [notification getSubElement];
        if ([subElement.name isEqualToString:MINDCLOUD_DRAWING_ATTRIBUTE])
        {
            //we have a drawing. Download it. Once the download is done. The notificatiosn
            //will take care of displaying it
            //make sure that we get the item only once.
            //the later downloading of this item should
            //happen when listeners are notified
            if (![self.downloadedFiles containsObject:subElement.name])
            {
                [self.gordonDataSource getCollectionAssetForNamespaceElement:subElement];
            }
        }
        else
        {
            CollectionStackingAttribute * newStackingModel = [CollectionStackingAttribute collectionSTackingAttributeFromNamespaceElement:[notification getSubElement]];
            
            //if its not a stacking ignore
            if(newStackingModel == nil) continue;
            
            NSString * stackId = [notification getSubElement].ID;
            //get the old stacking and remove the deleted notes
            CollectionStackingAttribute * oldStacking = self.stackings[stackId];
            if (oldStacking)
            {
                NSMutableSet * deletedNotes = [oldStacking.refIds mutableCopy];
                [deletedNotes minusSet:newStackingModel.refIds];
                for (NSString * deletedNote in deletedNotes)
                {
                    [self.noteToStackingMap removeObjectForKey:deletedNote];
                    
                }
            }
            
            for (NSString * noteId in newStackingModel.refIds)
            {
                self.noteToStackingMap[noteId] = newStackingModel.ID;
            }
            
            self.stackings[stackId] = newStackingModel;
            [updatedStackings addObject:stackId];
        }
    
    }
    
    if ([updatedStackings count] == 0) return;
    
    NSDictionary * userInfo =  @{@"result" :  updatedStackings};
    
    NSLog(@"MindcloudCollection: Update Stacking Event: %@", updatedStackings);
    [[NSNotificationCenter defaultCenter] postNotificationName:STACK_UPDATED_EVENT
                                                        object:self
                                                      userInfo:userInfo];
}

-(void) updateCollectionForDeleteNamespaceSubElementNotifications:(NSArray *) notifications
{
    NSMutableArray * deletedStackings = [NSMutableArray array];
    for (DeleteFragmentNamespaceSubElementNotification * notification in notifications)
    {
        
        NSString * stackingId = notification.getSubElementId;
        
        CollectionStackingAttribute * stackingModel = self.stackings[stackingId];
        
        //if its not there. Its either not a stacking or we don't have. Forget it
        if (stackingModel == nil) continue;
        
        for (NSString * noteId in stackingModel.refIds)
        {
            [self.noteToStackingMap removeObjectForKey:noteId];
        }
        
        [self.stackings removeObjectForKey:stackingId];
        [deletedStackings addObject:stackingId];
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
    //make sure if we have renamed
    NSData * thumbnailData = [self getImageDataForPath:thumbnailPath];
    return thumbnailData;
}

#pragma mark - Gordon delegate

-(void) collectionThumbnailIsForAssociationWithId:(NSString *)associationId
{
    if (associationId != nil)
    {
        self.originalThumbnail = associationId;
    }
}

-(void) collectionFragmentHasAssociationWithId:(NSString *) associationId
                                 andAssociatedItemFragment:(XoomlFragment *) noteFragment
                           andAssociation:(XoomlAssociation *) association
{
    
    CollectionNoteAttribute * attribute = [CollectionNoteAttribute CollectionNoteAttributeFromAssociation:association];
    if (attribute == nil) return;
    id <NoteProtocol> noteObj = [[CollectionNote alloc] initWithXoomlFragment:noteFragment];
    if (!noteObj) return ;
    
    (self.collectionNoteAttributes)[associationId] = noteObj;
    //note could have an image or not. If it has an image we have to also add it to note images
    NSString * imgName = noteObj.image;
    if (imgName != nil)
    {
        [self.downloadableImageNotes addObject:associationId];
        NSString * imagePath = [self.gordonDataSource getImagePathForAssociationWithName:association.associatedItem];
        if (imagePath)
        {
            self.imagePathsForNotes[associationId] = imagePath;
            [self.thumbnailStack addObject:associationId];
        }
        
        [self.gordonDataSource associatedItemIsWaitingForImageForAssociationWithId:associationId andAssociationName:association.associatedItem];
    }
    
    
    self.collectionAttributesForNotes[associationId] = attribute;
}

-(void) collectionHasNamespaceElementWithName:(NSString *) namespaceType
                                       andContent:(XoomlNamespaceElement *) namespaceElement
{
    CollectionStackingAttribute * stackingModel = [CollectionStackingAttribute collectionSTackingAttributeFromNamespaceElement:namespaceElement];
    if (stackingModel == nil) return;
    
    
    //Get STacking type and check against associationType
    self.stackings[stackingModel.ID] = stackingModel;
    for (NSString * refId in stackingModel.refIds)
    {
        self.noteToStackingMap[refId] = stackingModel.ID;
    }
}


-(void) associatedItemPartiallyDownloadedWithId:(NSString *) associationId
                                       andFragment:(XoomlFragment *) noteFragment
                    andAssociation:(XoomlAssociation *) association
{
    
    id <NoteProtocol> noteObj = [[CollectionNote alloc] initWithXoomlFragment:noteFragment];
    if (!noteObj) return ;
    
    //register the
    [self.noteResolver noteContentReceived:noteObj forNoteId:associationId];
    
    
    //set the note content as soon as you receive it
    self.collectionNoteAttributes[associationId] = noteObj;
    //note could have an image or not. If it has an image we have to also add it to note images
    NSString * imgName = noteObj.image;
    if (imgName != nil)
    {
        [self.downloadableImageNotes addObject:associationId];
        NSString * imagePath = [self.gordonDataSource getImagePathForAssociationWithName:association.associatedItem];
        
        if (imagePath)
        {
            [self.noteResolver noteImagePathReceived:imagePath forNoteId:associationId];
            [self.thumbnailStack addObject:associationId];
        }
        [self.gordonDataSource associatedItemIsWaitingForImageForAssociationWithId:associationId andAssociationName:association.associatedItem];
    }
}

-(void) getAllCollectionAssetsAsync
{
    [self.gordonDataSource getAllCollectionAssetsAsynch];
}

-(void) collectionDidDownloadCollectionAsset:(NSData *)asset
                                 forFileName:(NSString *)fileName
                            andAttributeName:(NSString *)attributeName
{
   if ([attributeName isEqualToString:MINDCLOUD_DRAWING_ATTRIBUTE])
   {
       ScreenDrawing * screenDrawing = [ScreenDrawing deserializeFromData:asset];
       NSLog(@"MindcloudCollection-Drawing downloaded");
       [self.downloadedFiles addObject:attributeName];
       NSDictionary * userInfo =  @{@"result" :  screenDrawing};
    
       [[NSNotificationCenter defaultCenter] postNotificationName:DRAWING_DOWNLOADED_EVENT
                                                           object:self
                                                         userInfo:userInfo];
   }
}

//when anything happens to a collection you will get these info
-(void) eventsOccurredWithNotifications: (NotificationContainer *) notifications
{
    //we pick the items we are intersted in from the notification container
    //The order of these updates are optimized
    NSArray * possibleDeleteSubElements = notifications.getDeleteFragmentNamespaceSubElementNotifications;
    NSArray * possibleDeleteAssociations = notifications.getDeleteAssociationNotifications;
    NSArray * possibleAddAssociation = notifications.getAddAssociationNotifications;
    NSArray * possibleAddSubElements = notifications.getAddFragmentNamespaceSubElementNotifications;
    NSArray * possibleUpdateSubElements = notifications.getUpdateFragmentNamespaceSubElementNotifications;
    NSArray * possibleUpdateAssociations = notifications.getUpdateAssociationNotifications;
    
    [self updateCollectionForDeleteNamespaceSubElementNotifications:possibleDeleteSubElements];
    [self updateCollectionForDeleteAssociationNotifications: possibleDeleteAssociations];
    [self updateCollectionForAddAssociationNotifications:possibleAddAssociation];
    [self updateCollectionForAddSubelementNotifications:possibleAddSubElements];
    [self updateCollectionForUpdateSubelementNotifications:possibleUpdateSubElements];
    [self updateCollectionForUpdateAssociationNotifications:possibleUpdateAssociations];
}

-(void) associationWithId:(NSString *) associationId
    downloadedImageWithPath:(NSString *) imagePath
{
    
    (self.imagePathsForNotes)[associationId] = imagePath;
    //if we are waiting for this let the resolver know
    if ([self.noteResolver hasNoteWaitingForResolution:associationId])
    {
        [self.noteResolver noteImagePathReceived:imagePath forNoteId:associationId];
    }
}

-(void) eventOccuredWithDownloadingOfAssociatedItemWithId:(NSString *) associationId
                             andAssociatedItemFragment:(XoomlFragment *) noteFragment
{
    
    id <NoteProtocol> noteObj = [[CollectionNote alloc] initWithXoomlFragment:noteFragment];
    NSString * noteId = noteObj.noteId ;
    
    
    //if its just an update , update it
    if (self.collectionNoteAttributes[noteId])
    {
        //just update the content
        self.collectionNoteAttributes[noteId] = noteObj;
        NSDictionary * userInfo =  @{@"result" :  @[noteId]};
        [[NSNotificationCenter defaultCenter] postNotificationName:ASSOCIATION_CONTENT_UPDATED_EVENT
                                                            object:self
                                                          userInfo:userInfo];
    }
    //if its a new note submit the piece of the note that was received to resolver
    else
    {
        [self.noteResolver noteContentReceived:noteObj forNoteId:noteId];
    }
    
}

-(void) eventOccuredWithDownloadingOfAssocitedItemImage:(NSString *) associationId
                                          withImagePath:(NSString *) imagePath
                                   andAssociatedItemFragment:(XoomlFragment *) noteFragment
{
    id <NoteProtocol> noteObj = [[CollectionNote alloc] initWithXoomlFragment:noteFragment];
    NSString * noteId = noteObj.noteId;
    
    //if this is only an update, update the image path and send the notification
    if (self.imagePathsForNotes[noteId] && self.collectionNoteAttributes[noteId])
    {
        self.imagePathsForNotes[noteId] = imagePath;
        self.collectionNoteAttributes[noteId] = noteObj;
        
        //update thumbnail
        [self.thumbnailStack addObject:noteId];
        self.originalThumbnail = nil;
        [self.gordonDataSource setCollectionThumbnailWithImageOfAssociation:associationId];
        
        NSDictionary * userInfo =  @{@"result" :  @[noteId]};
        [[NSNotificationCenter defaultCenter] postNotificationName:ASSOCIATION_IMAGE_UPDATED_EVENT
                                                            object:self
                                                          userInfo:userInfo];
        
    }
    else
    {
        [self.noteResolver noteImagePathReceived:imagePath forNoteId:noteId];
    }
}

-(void) eventOccuredWithDownloadingOfCollectionAssetDiff:(NSData *)diffContent
                                             forFileName:(NSString *)fileName
{
    if ([fileName isEqualToString:[ExternalFileHelper filenameForScreenDrawing]])
    {
       NSLog(@"MindcloudCollection-Drawing Diff Received");
        
        ScreenDrawing * screenDrawing = [ScreenDrawing deserializeFromData:diffContent];
        NSDictionary * userInfo =  @{@"result" :  screenDrawing};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DRAWING_DIFF_DOWNLOADED_EVENT
                                                            object:self
                                                          userInfo:userInfo];
    }
}

-(void) eventOccuredWithReceivingOfMessage:(NSString *)message
                             withMessageID:(NSString *)messageId
{
    PeerMessage * peerMessage = [MessageFactory messageFromString:message
                                                withMessageId:messageId];
    if ([peerMessage isKindOfClass:[ClearMessage class]])
    {
        NSDictionary * userInfo =  @{};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CLEAR_OCCURRED_EVENT
                                                            object:self
                                                          userInfo:userInfo];
        
    }
    else if ([peerMessage isKindOfClass:[UndoMessage class]])
    {
        NSDictionary * userInfo =  @{@"result" : peerMessage};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UNDO_OCCURRED_EVENT
                                                            object:self
                                                          userInfo:userInfo];
    }
    else if ([peerMessage isKindOfClass:[RedoMessage class]])
    {
        NSDictionary * userInfo =  @{@"result" : peerMessage};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:REDO_OCCURRED_EVENT
                                                            object:self
                                                          userInfo:userInfo];
    }
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

-(void) savePendingAssets
{
    [self.delegate savePendingAsset];
}

- (void) promiseSaving
{
    [self.gordonDataSource promiseSynchronization];
}

- (void) promiseSavingDrawings
{
    [self.gordonDataSource promiseSavingAssets];
    [self setDrawingAttribute];
    //if manifest is in need of modification, modify it
}

@end