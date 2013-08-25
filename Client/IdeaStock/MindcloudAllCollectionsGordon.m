//
//  MindcloudAllCollectionsGordon.m
//  Mindcloud
//
//  Created by Ali Fathalian on 8/25/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudAllCollectionsGordon.h"
#import "SharingAwareObject.h"
#import "MindcloudSharingAdapter.h"
#import "MindcloudDataSource.h"
#import "CachedMindCloudDataSource.h"
#import "EventTypes.h"

#define SYNCHRONIZATION_PERIOD 10

@interface MindcloudAllCollectionsGordon()

@property (strong, nonatomic) id<MindcloudDataSource, SharingAwareObject> dataSource;
@property (strong, nonatomic) MindcloudSharingAdapter * sharingAdapter;
@property (weak, nonatomic) id<MindcloudAllCollectionsGordonDelegate> delegate;
@property (atomic,strong) NSTimer * timer;
@property BOOL shouldSaveCategories;

@end

@implementation MindcloudAllCollectionsGordon


-(id) initWithDelegate:(id<MindcloudAllCollectionsGordonDelegate>) delegate
{
    self = [super init];
    if (self)
    {
        self.shouldSaveCategories = NO;
        self.dataSource = [[CachedMindCloudDataSource alloc] init];
        self.sharingAdapter = [[MindcloudSharingAdapter alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(collectionShared:)
                                                     name:COLLECTION_SHARED
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(allCollectionsReceived:)
                                                     name: ALL_COLLECTIONS_LIST_DOWNLOADED_EVENT
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(categoriesReceived:)
                                                     name: CATEGORIES_RECEIVED_EVENT
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(thumbnailReceived:)
                                                     name: THUMBNAIL_RECEIVED_EVENT
                                                   object:nil];
        
        [self startTimer];
    }
    return self;
}


-(id<MindcloudAllCollectionsGordonDelegate>) delegate
{
    if (_delegate != nil)
    {
        id<MindcloudAllCollectionsGordonDelegate> tempDel = _delegate;
        return tempDel;
    }
    return nil;
}

-(void) addCollectionWithName:(NSString *) collectionName
{
    
    [self.dataSource addCollectionWithName:collectionName];
    self.shouldSaveCategories = YES;
}

-(void) promiseSavingCategories
{
    self.shouldSaveCategories = YES;
}

-(void) deleteCollectionWithName:(NSString *) collectionName
{
    CachedMindCloudDataSource * collectionDataSource = [CachedMindCloudDataSource getInstance:collectionName];
    [collectionDataSource deleteCollectionFor:collectionName];
}

-(NSArray *) getAllCollections
{
    return [self.dataSource getAllCollections];
}

-(NSDictionary *) getAllCategoriesMappings
{
    return [self.dataSource getCategories];
}

-(void) renameCollectionWithName:(NSString *) collectionName
                              to:(NSString *) newCollectionName
{
    [self.dataSource renameCollectionWithName:collectionName to:newCollectionName];
    self.shouldSaveCategories = YES;
}

-(NSData *) getThumbnailForCollection:(NSString *) collectionName
{
    //these are collection specific data sources
    CachedMindCloudDataSource * dataSource = [CachedMindCloudDataSource getInstance:collectionName];
    NSData * imgData = [dataSource getThumbnailForCollection:collectionName];
    return imgData;
}

-(void) shareCollection:(NSString *) collectionName
{
    [self.sharingAdapter shareCollection:collectionName];
}

-(void) unshareCollection:(NSString *) collectionName
{
    [self.sharingAdapter unshareCollection:collectionName];
    [self.dataSource collectionIsNotShared:collectionName];
}

-(void) subscribeToCollectionWithSecret:(NSString *) secret
{
    [self.sharingAdapter subscriberToCollection:secret];
}

#pragma mark - notifications

-(void) collectionShared:(NSNotification *) notification
{
    NSDictionary * result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    if (collectionName)
    {
        
        id<MindcloudAllCollectionsGordonDelegate> tempDel = self.delegate;
        if (tempDel)
        {
            [tempDel collectionGotShared:collectionName];
            
        }
        self.shouldSaveCategories = YES;
    }
}

-(void) allCollectionsReceived:(NSNotification *) notification
{
    NSArray* allCollections = notification.userInfo[@"result"];
    
    id<MindcloudAllCollectionsGordonDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        [tempDel collectionsLoaded:allCollections];
        
    }
}

-(void) categoriesReceived:(NSNotification *) notification
{
    
    NSDictionary * dict = notification.userInfo[@"result"];
    
    id<MindcloudAllCollectionsGordonDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        [tempDel categoriesLoaded:dict];
        
    }
}

-(void) thumbnailReceived:(NSNotification *) notification
{
    
    NSDictionary * dict = notification.userInfo[@"result"];
    NSString * collectionName = dict[@"collectionName"];
    NSData * imgData = dict[@"data"];
    //if there is no image on the server use our default image
    if (!imgData)
    {
        UIImage * defaultImage = [UIImage imageNamed: @"felt-red-ipad-background.jpg"];
        imgData = UIImageJPEGRepresentation(defaultImage, 1);
    }
    
    id<MindcloudAllCollectionsGordonDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        [tempDel thumbnailLoadedForCollection:collectionName andData:imgData];
        
    }
    
}

#pragma mark - timer

-(void) startTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:SYNCHRONIZATION_PERIOD
                                                  target:self
                                                selector:@selector(saveCategories:)
                                                userInfo:nil
                                                 repeats:YES];
}

-(void) stopTimer{
    [self.timer invalidate];
}

#pragma mark - synchronization
-(void) saveCategories
{
    if (self.shouldSaveCategories)
    {
        id<MindcloudAllCollectionsGordonDelegate> tempDel = self.delegate;
        if (tempDel)
        {
            NSData * categoriesData = [tempDel getCategoriesData];
            [self.dataSource saveCategories:categoriesData];
            self.shouldSaveCategories = NO;
        }
    }
}

-(void) saveCategories:(NSTimer *) timer
{
    [self saveCategories];
}

-(void) synchronize
{
    [self saveCategories];
}

-(void) stopSynchronization
{
    [self stopTimer];
}

-(void) refresh
{
    [self stopTimer];
    [self getAllCollections];
    [self startTimer];
}

-(void) cleanup
{
    [self saveCategories];
    [self stopTimer];
}
@end
