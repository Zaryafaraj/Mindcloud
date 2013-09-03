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
#import "XoomlProtocol.h"
#import "MergerThread.h"
#import "CollectionRecorder.h"
#import "MergeResult.h"
#import "FileSystemHelper.h"
#import "NotificationContainer.h"
#import "XoomlFragment.h"
#import "XoomlNamespaceElement.h"
#import "NamespaceDefinitions.h"
#import "XoomlAttributeDefinitions.h"
#import "MindcloudCollection.h"

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
 To record any possible conflicting items for synchronization
 */
@property (strong, atomic) CollectionRecorder * recorder;
/*
 The main interface to carry all the sharing specified actions; associatedItem that anything
 sharing related will be done server side. This is for querying about sharing info and
 getting notified of the listeners
 */
@property (nonatomic, strong) CollectionSharingAdapter * sharingAdapter;

/*
 The manifest of the loaded collection
 */
@property (nonatomic,strong) id <XoomlProtocol> collectionFragment;

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
 Keyed on associatedItemName - valued on associatedItemID. All the associatedItemImages for which we have sent
 a request but we are waiting for response
 */
@property (nonatomic, strong) NSMutableDictionary * waitingAssociatedItemImages;

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
        
        self.recorder = [[CollectionRecorder alloc] init];
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
            self.collectionFragment = [[XoomlFragment alloc] initAsEmpty];
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
                                                 selector:@selector(collectionAssociatedItemsDownloaded:)
                                                     name:COLLECTION_DOWNLOADED_EVENT
                                                   object:nil];
        
        //Gets notified when the server data is merged with local data
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mergeFinished:)
                                                     name:FRAGMENT_MERGE_FINISHED_EVENT
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(associatedItemImageDownloaded:)
                                                     name:IMAGE_DOWNLOADED_EVENT
                                                   object:nil];
        
        //notifications for listener updates
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(listenerDownloadedAssociatedItem:)
                                                     name:LISTENER_DOWNLOADED_ASSOCIATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(listenerDownloadedAssociatedItemImage:)
                                                     name:LISTENER_DOWNLOADED_IMAGE
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(listenerDeletedAssociatedItem:)
                                                     name:LISTENER_DELETED_ASSOCIATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(listenerDownloadedCollectionFragment:)
                                                     name:LISTENER_DOWNLOADED_FRAGMENT
                                                   object:nil];
    }
    return self;
}

-(NSString *) getImagePathForAssociationWithName:(NSString *) associationName
{
    
    NSString * imagePath = [self.dataSource getImagePathForAssociatedItem:associationName
                                                            andCollection:self.collectionName];
    return imagePath;
}

-(void) addAssociationWithName:(NSString *) associationName
             andAssociatedItem:(XoomlFragment *) associatedItemFragment
                andAssociation:(XoomlAssociation *) association;
{
    
    //set the collection manifest association and make sure we flag it for synch later
    [self.collectionFragment addAssociation:association];
    self.needSynchronization = YES;
    
    NSData * content = [[associatedItemFragment toXmlString] dataUsingEncoding:NSUTF8StringEncoding];
    //instantely add the content
    [self.dataSource addAssociatedItemWithName:associationName
                            andFragmentContent:content
                                  ToCollection:self.collectionName];
    
    [self.recorder recordUpdateAssociation:association.ID];
}

-(void) addAssociationWithName: (NSString *) associationName
             andAssociatedItem:(XoomlFragment *) associatedItemFragment
                andAssociation:(XoomlAssociation *)association
       andAssociationImageData:(NSData *) img
                  andImageName:(NSString *) imgName
{
    NSString * associationId = association.refId;
    [self.collectionFragment addAssociation:association];
    
    XoomlNamespaceElement * elem = [self createThumbnailNamespaceElementWithRefId: associationId];
    
    [self.collectionFragment setFragmentNamespaceSubElementWithElement:elem];
    
    
    NSData * content = [[associatedItemFragment toXmlString] dataUsingEncoding:NSUTF8StringEncoding];
     [self.dataSource addAssociatedItemWithName: associationName
                            andFragmentContent: content
                                      andImage: img
                             withImageFileName: imgName
                                  toCollection:self.collectionName];
    
    [self.recorder recordUpdateAssociation:association.ID];
    self.needSynchronization = YES;
}

-(XoomlNamespaceElement *) createThumbnailNamespaceElementWithRefId:(NSString *) refId
{
    XoomlNamespaceElement * thumbnail = [[XoomlNamespaceElement alloc] initWithName:THUMBNAIL_ELEMENT_NAME
                                                                 andParentNamespace: MINDCLOUD_XMLNS];
    [thumbnail addAttributeWithName:THUMBNAIL_REF_ID andValue:refId];
    return thumbnail;
}

-(void) addCollectionFragmentNamespaceElementWithName:(NSString *) namespaceElementName
                                  andNamespaceElement:(XoomlNamespaceElement *) namespaceElement
{
    [self.collectionFragment addFragmentNamespaceSubElement:namespaceElement];
    
    XoomlFragmentNamespaceElement * fragmentNamespaceElement = [self.collectionFragment getFragmentNamespaceElementWithNamespaceURL:namespaceElement.parentNamespace
                                                                                              thatContainsNamespaceSubElementWithId:namespaceElement.ID];
    if (fragmentNamespaceElement != nil)
    {
        [self.recorder recordUpdateFragmentNamespaceElement:fragmentNamespaceElement.ID];
    }
    self.needSynchronization = YES;
    
    [self.recorder recordUpdateFragmentNamespaceSubElement:namespaceElement.ID];
    NSArray * allSubElements = [namespaceElement getAllSubElements].allValues;
    for (XoomlNamespaceElement * namespaceSubElement in allSubElements)
    {
        [self.recorder recordUpdateFragmentSubElementsChild:namespaceSubElement.ID];
    }
}

-(void) setCollectionThumbnailWithData:(NSData *) thumbnailData
{
    [self.dataSource setThumbnail:thumbnailData forCollection:self.collectionName];
}

-(void) setCollectionThumbnailWithImageOfAssociation:(NSString *) associationId
{
    XoomlNamespaceElement * thumbnailElement = [self createThumbnailNamespaceElementWithRefId:associationId];
    [self.collectionFragment setFragmentNamespaceSubElementWithElement:thumbnailElement];
}

-(void) setAssociatedItemWithName:(NSString *) associationName
                 toAssociatedItem:(XoomlFragment *) associatedItemFragment
{
    
    NSData * content = [[associatedItemFragment toXmlString] dataUsingEncoding:NSUTF8StringEncoding];
    [self.dataSource updateAssociatedItem:associationName
                      withFragmentContent:content
                             inCollection:self.collectionName];
    
}

-(void) setAssociationWithId:(NSString *) associationId
               toAssociation:(XoomlAssociation *) association
{
    [self.collectionFragment setAssociationWithId:associationId withNewAssociation:association];
    self.needSynchronization = YES;
    
    [self.recorder recordUpdateAssociation:associationId];
}

-(void) setCollectionFragmentNamespaceElementWithName:(NSString *) namespaceElementName
                                   toNamespaceElement:(XoomlNamespaceElement *) namespaceElement
{
    XoomlNamespaceElement * previousElement = [self.collectionFragment getFragmentNamespaceSubElementWithId:namespaceElement.ID
                                                                                                    andName:namespaceElementName
                                                                                           fromNamespaceURL:namespaceElement.parentNamespace];
    NSDictionary * beforeChildren = [previousElement getAllSubElements];
    NSDictionary * afterChildren = [namespaceElement getAllSubElements];
    
    NSSet * beforeChildrenIds = [NSSet setWithArray:beforeChildren.allKeys];
    NSSet * afterChildrenIds = [NSSet setWithArray:afterChildren.allKeys];
    
    NSMutableSet * childrenThatWillBeDeleted = [NSMutableSet setWithSet:beforeChildrenIds];
    [childrenThatWillBeDeleted minusSet:afterChildrenIds];
    
    NSMutableSet * childrenThatWillBeAdded = [NSMutableSet setWithSet:afterChildrenIds];
    [childrenThatWillBeAdded minusSet:beforeChildrenIds];
    
    NSMutableSet * childrenThatPossiblyWillGetUpdated = [NSMutableSet setWithSet:beforeChildrenIds];
    [childrenThatPossiblyWillGetUpdated intersectSet:afterChildrenIds];
    
    //if the value of a possible to be updated object changes between before and after then it will get updated
    NSMutableSet * childrenThatWillGetUpdated = [NSMutableSet set];
    for(NSString * childId in childrenThatPossiblyWillGetUpdated)
    {
        NSString * beforeValue = beforeChildren[childId];
        NSString * afterValue = afterChildren[childId];
        if (![beforeValue isEqualToString:afterValue])
        {
            [childrenThatWillGetUpdated addObject:childId];
        }
    }
    
    [self.collectionFragment setFragmentNamespaceSubElementWithElement:namespaceElement];
    self.needSynchronization = YES;
    
    XoomlFragmentNamespaceElement * fragmentNamespaceElement = [self.collectionFragment getFragmentNamespaceElementWithNamespaceURL:namespaceElement.parentNamespace
                                                                                              thatContainsNamespaceSubElementWithId:namespaceElement.ID];
    if (fragmentNamespaceElement != nil)
    {
        [self.recorder recordUpdateFragmentNamespaceElement:fragmentNamespaceElement.ID];
    }
    [self.recorder recordUpdateFragmentNamespaceSubElement:namespaceElement.ID];
    
    for (NSString * childId in childrenThatWillBeAdded)
    {
        [self.recorder recordUpdateFragmentSubElementsChild:childId];
    }
    for (NSString * childId in childrenThatWillGetUpdated)
    {
        [self.recorder recordUpdateFragmentSubElementsChild:childId];
    }
    for (NSString * childId in childrenThatWillBeDeleted)
    {
        [self.recorder recordDeleteFragmentSubElementsChild:childId];
    }
}

-(void) removeAssociationWithId:(NSString *)associationId
          andAssociatedItemName:(NSString *)associationName
{
    [self.collectionFragment removeAssociation:associationId];
    
    [self.dataSource removeAssociatedItem:associationName
                           FromCollection:self.collectionName];
    
    [self.recorder recordDeleteAssociation:associationId];
    self.needSynchronization = YES;
}

-(void) removeThumbnailForAssociationWithId:(NSString *) associationId
{
    [self.collectionFragment removeFragmentNamespaceSubElementWithName:THUMBNAIL_ELEMENT_NAME forNamespaceURL:MINDCLOUD_XMLNS];
}

-(void) removeCollectionFragmentNamespaceElementWithName:(NSString *) namespaceName
{
    //get this before deleting
    NSArray * elementsToDel = [self.collectionFragment getFragmentNamespaceSubElementsWithName:namespaceName forNamespaceURL:MINDCLOUD_XMLNS];
    
    [self.collectionFragment removeFragmentNamespaceSubElementWithName:namespaceName forNamespaceURL:MINDCLOUD_XMLNS];
    
    self.needSynchronization = YES;
    
    
    
    for(XoomlNamespaceElement * elem in elementsToDel)
    {
        
        XoomlFragmentNamespaceElement * fragmentNamespaceElement = [self.collectionFragment getFragmentNamespaceElementWithNamespaceURL:elem.parentNamespace
                                                                                                  thatContainsNamespaceSubElementWithId:elem.ID];
        if (fragmentNamespaceElement != nil)
        {
            [self.recorder recordUpdateFragmentNamespaceElement:fragmentNamespaceElement.ID];
        }
        
        [self.recorder recordDeleteFragmentNamespaceSubElement:elem.ID];
        NSArray * childrenToDelete = [elem getAllSubElements].allKeys;
        for(NSString * childToDelete in childrenToDelete)
        {
            [self.recorder recordDeleteFragmentSubElementsChild:childToDelete];
        }
    }
}

-(void) loadOfflineCollection:(NSData *) collectionData{
    
    if (!collectionData)
    {
        NSLog(@"MindcloudCollectionGordon-collectionData is nil. Collection may not have download properly");
        return;
    }
    
    NSString * manifestXML = [[NSString alloc] initWithData:collectionData encoding:NSUTF8StringEncoding];
    self.collectionFragment = [[XoomlFragment alloc] initWithXMLString:manifestXML];
    
    [self notifyDelegateOfCollectionThumbnail:self.collectionFragment];
    [self notifyDelegateOfAssociations:self.collectionFragment];
    [self notifyDelegateOfCollectionAttributes:self.collectionFragment];
    
}

-(void) notifyDelegateOfAssociations:(id <XoomlProtocol>) manifest
{
    //get associatedItems from manifest and initalize those
    NSDictionary * allAssociations = [manifest getAllAssociations];
    for(NSString * associationId in allAssociations){
        
        //for each associatedItem create a associatedItem Object by reading its separate xooml files
        //from the data model
        XoomlAssociation * association = allAssociations[associationId];
        NSString * associatedItemName = association.associatedItem;
        NSData * associationData = [self.dataSource getAssociatedItemForTheCollection:self.collectionName
                                                                             WithName:associatedItemName];
        
        if (associatedItemName == nil)
        {
            NSLog(@"MindcloudCollectionGordon - One of associationItemName or associatedItemId is nil");
            continue;
        }
        if (!associationData)
        {
            NSLog(@"MindcloudCollectionGordon-Could not retreive associatedItem data from dataSource");
        }
        else
        {
            
            if (self.delegate != nil)
            {
                
                NSString * associationXML = [[NSString alloc] initWithData:associationData encoding:NSUTF8StringEncoding];
                XoomlFragment * fragment = [[XoomlFragment alloc] initWithXMLString:associationXML];
                id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
                [tempDelegate collectionFragmentHasAssociationWithId:associatedItemName
                                                       andAssociatedItemFragment:fragment
                                                 andAssociation:association];
            }
        }
        
    }
}

-(void) notifyDelegateOfCollectionThumbnail:(id <XoomlProtocol>) manifest
{
    //cause delegate is weak we need to do heavy checking so its not become nil
    if (self.delegate != nil)
    {
        NSArray * allElems = [manifest getFragmentNamespaceSubElementsWithName:THUMBNAIL_ELEMENT_NAME forNamespaceURL:MINDCLOUD_XMLNS];
        if (allElems == nil || [allElems count] == 0)
        {
            NSLog(@"MindcloudCollectionGordon- No thumbnail found for manifest");
            return;
        }
        else if ([allElems count] > 1)
        {
            NSLog(@"MindcloudCollectionGordon - More than one thumbnail found for manifest");
        }
        XoomlNamespaceElement * thumbnailElem = [allElems lastObject];
        NSString * thumbnailRefId = [thumbnailElem getAttributeWithName:THUMBNAIL_REF_ID];
        id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
        if (tempDelegate != nil && thumbnailRefId != nil)
        {
            [tempDelegate collectionThumbnailIsForAssociationWithId:thumbnailRefId];
        }
    }
}

-(void) notifyDelegateOfCollectionAttributes: (id <XoomlProtocol>) manifest{
    //get the stacking information and cache them
    
    NSArray * allFragmentNamespaceElements = [manifest getAllFragmentNamespaceSubElementsForNamespaceURL:MINDCLOUD_XMLNS];
    
    for (XoomlNamespaceElement * namespaceElement in allFragmentNamespaceElements)
    {
        if (self.delegate != nil)
        {
            NSString * elementType = namespaceElement.name;
            id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
            [tempDelegate collectionHasNamespaceElementWithName:elementType
                                                         andContent:namespaceElement];
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


-(void) associatedItemIsWaitingForImageForAssociationWithId:(NSString *) associationId
                                         andAssociationName:(NSString *) associationName
{
    [self.waitingAssociatedItemImages setObject:associationId forKey:associationName];
}

-(void) collectionAssociatedItemsDownloaded: (NSNotification *) notification{
    
    NSData * collectionData = [self.dataSource getCollectionFromCache:self.collectionName];
    if (!collectionData)
    {
        NSLog(@"MindcloudCollectionGordon -Collection Data is nil. Data must have not been downloaded properly");
        return;
    }
    
    NSString * manifestXML = [[NSString alloc] initWithData:collectionData encoding:NSUTF8StringEncoding];
    id<XoomlProtocol> serverManifest = [[XoomlFragment alloc]  initWithXMLString:manifestXML];
    id<XoomlProtocol> clientManifest = [self.collectionFragment copy];
    MergerThread * mergerThread = [MergerThread getInstance];
    
    [self initiateAssociationsFromDownloadedManifest:serverManifest];
    
    
    //when the merge is finished we will be notified
    //its ok if recorder is null its an optional
    [mergerThread submitClientManifest:clientManifest
                     andServerManifest:serverManifest
                     andActionRecorder:self.recorder
                     ForCollectionName:self.collectionName];
    
    [self notifyDelegateOfCollectionThumbnail:serverManifest];
}

-(void) initiateAssociationsFromDownloadedManifest:(id<XoomlProtocol>) manifest
{
    //make sure to add all the associations to be downloaded separately
    NSDictionary * allAssociations = [manifest getAllAssociations];
    NSMutableArray * associtedItemIds = [NSMutableArray array];
    for(NSString * associationId in allAssociations)
    {
        XoomlAssociation * association = allAssociations[associationId];
        
        NSString * associatedItemName = association.associatedItem;
        NSString * associatedItemId = association.refId;
        NSData * associationData = [self.dataSource getAssociatedItemForTheCollection:self.collectionName
                                                                               WithName:associatedItemName];
        
        if (associatedItemName == nil || associatedItemId == nil)
        {
            NSLog(@"MindcloudCollectionGordon - One of associationItemName or associatedItemId is nil");
            continue;
        }
        
        [associtedItemIds addObject:associatedItemId];
        
        if (!associationData)
        {
            NSLog(@"MindcloudCollectionGordon - Could not retreive associatedItem data from dataSource");
            continue;
            
        }
        else
        {
            [self initiateDownloadAssociation:associationData
                             forAssociationId:associatedItemId
                         andCollectionAttribute:association];
        }
    }
    
    //send out a associatedItem content update
    if (allAssociations != nil)
    {
        NSDictionary * userDict = @{@"result": associtedItemIds};
        [[NSNotificationCenter defaultCenter] postNotificationName:ASSOCIATION_CONTENT_UPDATED_EVENT
                                                            object:self
                                                          userInfo:userDict];
    }
}

-(void) initiateDownloadAssociation:(NSData *) associationData
                   forAssociationId:(NSString *) associationId
               andCollectionAttribute:(XoomlAssociation *) association
{
    
    if (self.delegate!= nil)
    {
        
        NSString * associationXML = [[NSString alloc] initWithData:associationData encoding:NSUTF8StringEncoding];
        XoomlFragment * fragment = [[XoomlFragment alloc] initWithXMLString:associationXML];
        if (fragment)
        {
            id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
            [tempDelegate associatedItemPartiallyDownloadedWithId:associationId
                                                         andFragment:fragment
                                      andAssociation:association];
        }
    }
}


-(void) associatedItemImageDownloaded:(NSNotification *) notification
{
    
    NSDictionary * dict = notification.userInfo[@"result"];
    NSString * collectionName = dict[@"collectionName"];
    NSString * associatedItemName = dict[@"associatedItemName"];
    NSString * imgPath = [FileSystemHelper getPathForAssociatedItemImageforAssociatedItemName:associatedItemName
                                                                               inCollection:self.collectionName];
    if (imgPath != nil && ![imgPath isEqualToString:@""])
    {
        NSString * associatedItemID = self.waitingAssociatedItemImages[associatedItemName];
        if (associatedItemID)
        {
            
            if (self.delegate)
            {
                id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
                [tempDelegate associationWithId:associatedItemID
                          downloadedImageWithPath:imgPath];
            }
            
            [self.waitingAssociatedItemImages removeObjectForKey:associatedItemName];
            //send out a notification
            NSDictionary * userInfo = @{@"result" :
                                            @{@"collectionName":collectionName,
                                              @"associatedItemId":associatedItemID}
                                        };
            [[NSNotificationCenter defaultCenter] postNotificationName:ASSOCIATION_IMAGE_READY_EVENT
                                                                object:self
                                                              userInfo:userInfo];
        }
    }
}


#pragma mark - sharing events

-(void) listenerDownloadedAssociatedItem:(NSNotification *) notification
{
    NSDictionary * result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    NSArray * associatedItems = result[@"associatedItems"];
    if ([collectionName isEqualToString:self.collectionName])
    {
        for (NSString * associationId in associatedItems)
        {
            NSData * associationData = [self.dataSource getAssociatedItemForTheCollection:collectionName
                                                                                   WithName:associationId];
            
            
            
            NSString * associationXML = [[NSString alloc] initWithData:associationData encoding:NSUTF8StringEncoding];
            XoomlFragment * fragment = [[XoomlFragment alloc] initWithXMLString:associationXML];
            if (self.delegate && fragment)
            {
                
                id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
                [tempDelegate eventOccuredWithDownloadingOfAssociatedItemWithId:associationId
                                                   andAssociatedItemFragment:fragment];
            }
        }
    }
}

-(void) listenerDownloadedAssociatedItemImage:(NSNotification *) notification
{
    NSDictionary * result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    NSString * associatedItemName = result[@"associatedItems"];
    if ([collectionName isEqualToString:self.collectionName])
    {
        NSString * imagePath = [self.dataSource getImagePathForAssociatedItem:associatedItemName
                                                                andCollection:collectionName];
        NSData * associatedItemData = [self.dataSource getAssociatedItemForTheCollection:collectionName
                                                                                WithName:associatedItemName];
        
        NSString * associationXML = [[NSString alloc] initWithData:associatedItemData encoding:NSUTF8StringEncoding];
        XoomlFragment * fragment = [[XoomlFragment alloc] initWithXMLString:associationXML];
        if (self.delegate && fragment)
        {
            id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
            [tempDelegate eventOccuredWithDownloadingOfAssocitedItemImage:associatedItemName
                                                            withImagePath:imagePath
                                                     andAssociatedItemFragment:fragment];
        }
    }
}

-(void) listenerDeletedAssociatedItem:(NSNotification *) notification
{
    //nothing to do here, since the manifest update will remove this associatedItem and update the UI
    //    NSLog(@"AssociatedItem Deleted");
}

-(void) listenerDownloadedCollectionFragment:(NSNotification *) notification
{
    NSDictionary * result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    if ([collectionName isEqualToString:self.collectionName])
    {
        NSData * manifestData = [self.dataSource getCollectionFromCache:collectionName];
        if (!manifestData)
        {
            NSLog(@"MindcloudCollectionGordon -Collection File didn't download properly");
            return;
        }
        NSString * manifestXML = [[NSString alloc] initWithData:manifestData encoding:NSUTF8StringEncoding];
        id<XoomlProtocol> serverManifest = [[XoomlFragment alloc]
                                            initWithXMLString:manifestXML];
        
        id<XoomlProtocol> clientManifest = [self.collectionFragment copy];
        MergerThread * mergerThread = [MergerThread getInstance];
        
        
        //when the merge is finished we will be notified
        [mergerThread submitClientManifest:clientManifest
                         andServerManifest:serverManifest
                         andActionRecorder:self.recorder
                         ForCollectionName:self.collectionName];
        
    }
}

/*! Gets called when we finish merging two manifests
 */
-(void) mergeFinished:(NSNotification *) notification
{
    NSLog(@"MindcloudCollectionGordon - merge Finished");
    MergeResult * mergeResult = notification.userInfo[@"result"];
    
    if (!mergeResult) return;
    
    if (![mergeResult.collectionName isEqualToString:self.collectionName]) return;
    
    
    if (self.delegate != nil)
    {
        id<MindcloudCollectionGordonDelegate> tempDelegate = self.delegate;
        NotificationContainer * notifications = mergeResult.notifications;
        [tempDelegate eventsOccurredWithNotifications:notifications];
    }
    
    self.collectionFragment = mergeResult.finalManifest;
    [self startTimer];
    
    if (self.recorder && [self.recorder hasAnythingBeenTouched])
    {
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


-(void) cacheIsSynched:(NSNotification *) notification
{
    self.isInSynchWithServer = YES;
}

#pragma mark - timers
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
                                     andFragmentContent:[collection.collectionFragment data]];
        [collection.recorder reset];
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
    [self.recorder reset];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
