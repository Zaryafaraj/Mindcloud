//
//  CollectionsModel.m
//  IdeaStock
//
//  Created by Ali Fathalian on 10/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MindcloudAllCollections.h"
#import "MindcloudDataSource.h"
#import "SharingAwareObject.h"
#import "MindcloudSharingAdapter.h"
#import "CachedMindCloudDataSource.h"
#import "EventTypes.h"
#import "XoomlCategoryParser.h"

#define SYNCHRONIZATION_PERIOD 10
@interface MindcloudAllCollections()

/*Dictionary of arrays keyed on the category name. Each array contains all the collections
 belonging to that category*/
@property (nonatomic, strong) NSMutableDictionary * collections;
@property (atomic, strong) NSMutableDictionary * collectionImages;

@property (strong, nonatomic) id<MindcloudDataSource, SharingAwareObject> dataSource;
@property (strong, nonatomic) MindcloudSharingAdapter * sharingAdapter;
@property (weak, nonatomic) id<MindcloudAllCollectionsDelegate> delegate;
@property (atomic,strong) NSTimer * timer;
@property BOOL shouldSaveCategories;
@end

@implementation MindcloudAllCollections

-(id) initWithDelegate:(id<MindcloudAllCollectionsDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.collections = [NSMutableDictionary dictionary];
        self.collectionImages = [NSMutableDictionary dictionary];
        self.dataSource = [[CachedMindCloudDataSource alloc] init];
        self.sharingAdapter = [[MindcloudSharingAdapter alloc] init];
        self.delegate = delegate;
        
        
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
    }
    return self;
}

-(id<MindcloudAllCollectionsDelegate>) delegate
{
    if (_delegate != nil)
    {
        id<MindcloudAllCollectionsDelegate> tempDel = _delegate;
        return tempDel;
    }
    return nil;
}

-(id) initWithCollections:(NSArray *)collections
{
    self = [self init];
    [self reloadCollectionsWithNewCollections:collections];
    return self;
}

-(void) reloadCollectionsWithNewCollections:(NSArray *) collections
{
    self.collections[ALL] = [collections mutableCopy];
    self.collections[UNCATEGORIZED_KEY] = [collections mutableCopy];
    self.collections[SHARED_COLLECTIONS_KEY] = [NSMutableArray array];
    
}

-(id) initWithCollections:(NSArray *)collections andCategories:(NSDictionary *)categories
{
    self = [self init];
    [self applyCategories:categories toCollections:collections];
    return self;
}

-(void) applyCategories:(NSDictionary *)categories
{
    [self applyCategories:categories toCollections:self.collections[UNCATEGORIZED_KEY]];
    self.shouldSaveCategories = YES;
}

-(void) addCollection: (NSString *) collection toCategory: (NSString *) category
{
    
    [self.dataSource addCollectionWithName:collection];
    if (self.collections[category]) [self.collections[category] insertObject:collection atIndex:0];
    else self.collections[category] = [NSMutableArray arrayWithObject:collection];
    
    //if we added to all then it should be in uncategoriez category automatically
    if ([category isEqualToString:ALL])
    {
        if (![self.collections[UNCATEGORIZED_KEY] containsObject:collection])
        {
            [self.collections[UNCATEGORIZED_KEY] addObject:collection];
        }
    }
    //if we add to a category it should be in all automatically
    else
    {
        if (![self.collections[ALL] containsObject:collection])
        {
            [self.collections[ALL] addObject:collection];
        }
    }
    
    self.shouldSaveCategories = YES;
}

-(void) addCategory: (NSString *) category
{
    if (![category isEqualToString:ALL] &&
        ![category isEqualToString:UNCATEGORIZED_KEY] &&
        ![category isEqualToString:SHARED_COLLECTIONS_KEY]){
        self.collections[category] = [NSMutableArray array];
    }
    self.shouldSaveCategories = YES;
}

-(void) batchRemoveCollections:(NSArray *) collections fromCategory:(NSString *) category
{
    for(NSString * collectionName in collections)
    {
        if (collectionName)
        {
            
            CachedMindCloudDataSource * collectionDataSource = [CachedMindCloudDataSource getInstance:collectionName];
            [collectionDataSource deleteCollectionFor:collectionName];
            
        }
    }
    
    //we now delete the model so we don't mess it up when we are querying it for collectionNames
    for(NSString * collectionName in collections)
    {
        [self removeCollection:collectionName fromCategory:category];
    }
}

-(void) removeCollection:(NSString *) collection fromCategory: (NSString *) cateogry
{
    if (self.collections[cateogry])
    {
        if ([self.collections[cateogry] containsObject:collection])
        {
            [self.collections[cateogry] removeObject:collection];
        }
        if (self.collectionImages[collection])
        {
            [self.collectionImages removeObjectForKey:collection];
        }
    }
    
    //if the deleted from all we need to delete it from the corresponding category
    if ([cateogry isEqualToString:ALL])
    {
        for (NSString * category in self.collections)
        {
            if (self.collections[category] == nil)
            {
                NSLog(@"Null pointer in the collcetion Model");
                return;
            }
            
            [self.collections[category] removeObject:collection];
        }
    }
    //if we deleted from something other than all we need to delete it from all and shared
    else
    {
        [self.collections[ALL] removeObject:collection];
        [self.collections[SHARED_COLLECTIONS_KEY] removeObject:collection];
    }
}

-(void) removeCategory: (NSString *) category
{
    //you can't remove the default categories
    if ([category isEqualToString:UNCATEGORIZED_KEY] ||
        [category isEqualToString:ALL] ||
        [category isEqualToString:SHARED_COLLECTIONS_KEY])
    {
        return;
    }
    
    //move all the collections to uncategorized category
    for(NSString * collection in self.collections[category])
    {
        [self.collections[UNCATEGORIZED_KEY] addObject:collection];
    }
    
    [self.collections removeObjectForKey:category];
    
    self.shouldSaveCategories = YES;
}

-(NSArray *) getAllCollections
{
    return [self.dataSource getAllCollections];
}

-(NSArray *) getAllCategories
{
    
    NSArray * answer = [[self.collections allKeys] sortedArrayUsingComparator:^(NSString * first, NSString * second){
        //{All, Uncategorized,..., the rest}
        if ([first isEqual:ALL])
        {
            return NSOrderedAscending;
        }
        if ([second isEqual:ALL])
        {
            return NSOrderedDescending;
        }
        if ([first isEqual:UNCATEGORIZED_KEY])
        {
            return NSOrderedAscending;
        }
        if ([second isEqual:UNCATEGORIZED_KEY])
        {
            return NSOrderedDescending;
        }
        if ([first isEqualToString:SHARED_COLLECTIONS_KEY])
        {
            return NSOrderedAscending;
        }
        else if ([second isEqualToString:SHARED_COLLECTIONS_KEY])
        {
            return NSOrderedDescending;
        }
        else
        {
            return (int)[[first lowercaseString] compare:[second lowercaseString]];
        }
    }];
    return answer;
}

-(NSDictionary *) getAllCategoriesMappings
{
   return [self.dataSource getCategories];
}

-(void) saveAllCategories:(BOOL) stopSynchingAfter;
{
    [self saveCategories];
    if(stopSynchingAfter)
    {
        [self stopTimer];
    }
    
}

-(void) promiseSavingAllCategories
{
    self.shouldSaveCategories = YES;
}
-(NSArray *) getEditableCategories
{
    
    NSMutableArray * editablesArray = [[self.collections allKeys] mutableCopy];
    [editablesArray removeObject:ALL];
//    [editablesArray removeObject:UNCATEGORIZED_KEY];
    [editablesArray removeObject:SHARED_COLLECTIONS_KEY];
    
    NSArray * answer = [editablesArray sortedArrayUsingComparator:^(NSString * first, NSString * second){
        
        if ([first isEqual:UNCATEGORIZED_KEY])
        {
            return NSOrderedAscending;
        }
        if ([second isEqual:UNCATEGORIZED_KEY])
        {
            return NSOrderedDescending;
        }
        if ([first isEqualToString:SHARED_COLLECTIONS_KEY])
        {
            return NSOrderedAscending;
        }
        else if ([second isEqualToString:SHARED_COLLECTIONS_KEY])
        {
            return NSOrderedDescending;
        }
        else
        {
            return (int)[[first lowercaseString] compare:[second lowercaseString]];
        }
    }];
    return answer;
}

-(NSArray *) getCollectionsForCategory: (NSString *) category
{
    if (!category) category = UNCATEGORIZED_KEY;
    
    return [self.collections[category] copy];
}
-(NSString *) getCollectionAt:(int)index forCategory:(NSString *)cat
{
    return self.collections[cat][index];
}

-(void) renameCategory:(NSString *)category toNewCategory:(NSString *)newCategory
{
    //you can't rename the default categories
    if ([category isEqualToString:UNCATEGORIZED_KEY] ||
        [category isEqualToString:ALL] ||
        [category isEqualToString:SHARED_COLLECTIONS_KEY])
    {
        return;
    }
    if (self.collections[category])
    {
        self.collections[newCategory] = [self.collections[category] mutableCopy];
        [self.collections removeObjectForKey:category];
    }
    
    self.shouldSaveCategories = YES;
}

-(void) renameCollection:(NSString *)collection
              inCategory:(NSString *)category
         toNewCollection:(NSString *)newCollection
{
    
    [self.dataSource renameCollectionWithName:collection to:newCollection];
    if (self.collections[category])
    {
        [self.collections[category] addObject:newCollection];
        [self.collections[category] removeObject:collection];
        //if we are renaming in anything other than all, all should be updated too
        if (![category isEqualToString:ALL])
        {
            [self.collections[ALL] removeObject:collection];
            [self.collections[ALL] addObject:newCollection];
        }
        //if we update in all the actual category should be updated too
        else
        {
            for(NSString * category in self.collections)
            {
                if ([self.collections[category] containsObject:collection])
                {
                    [self.collections[category] removeObject:collection];
                    [self.collections[category] addObject:newCollection];
                    
                }
            }
        }
        //rename the image
        if (self.collectionImages[collection])
        {
            NSData * tempImgData = self.collectionImages[collection];
            [self.collectionImages removeObjectForKey:collection];
            self.collectionImages[newCollection] = tempImgData;
        }
    }
    
    self.shouldSaveCategories = YES;
}

-(void) moveCollection:(NSString *)collectionName
          fromCategory:(NSString *)oldCategory
         toNewCategory:(NSString *)newCategory
{
    
    if (self.collections[oldCategory] && self.collections[newCategory])
    {
        if ([self.collections[newCategory] containsObject:collectionName]) return;
        
        [self.collections[newCategory] addObject:collectionName];
        //you can't move stuff from all categories
        if (![oldCategory isEqualToString:ALL])
        {
            [self.collections[oldCategory] removeObject:collectionName];
        }
        else
        {
            //remove it from uncategorized in case it is there
            [self.collections[UNCATEGORIZED_KEY] removeObject:collectionName];
        }
    }
}

-(void) applyCategories:(NSDictionary *)categories
          toCollections: (NSArray *) collections
{
    NSMutableDictionary * uncategorizedCollections = [NSMutableDictionary dictionary];
    //initially all the collections are uncategorized
    for (NSString * collection in collections)
    {
        uncategorizedCollections[collection] = @YES;
    }
    
    for (NSString * categoryName in categories)
    {
        //for each category in the applied categories, create an empty category
        self.collections[categoryName] = [NSMutableArray array];
        //populate the empty category only what it contains are in the list of collectiosn
        for (NSString * collectionForCategorization in categories[categoryName])
        {
            if (uncategorizedCollections[collectionForCategorization] != nil)
            {
                uncategorizedCollections[collectionForCategorization] = @NO;
                [self.collections[categoryName] addObject:collectionForCategorization];
            }
        }
    }
    
    NSMutableArray * uncategorizedArray = [NSMutableArray array];
    for (NSString * collection in uncategorizedCollections)
    {
        if ([uncategorizedCollections[collection] isEqual:@YES])
        {
            [uncategorizedArray addObject:collection];
        }
    }
    
    if (collections == nil) self.collections = [NSMutableDictionary dictionary];
    else self.collections[ALL] = [collections mutableCopy];
    if (uncategorizedArray == nil) self.collections[UNCATEGORIZED_KEY] = [NSMutableArray array];
    else self.collections[UNCATEGORIZED_KEY] = [uncategorizedArray mutableCopy];
}


-(BOOL) doesNameExist:(NSString *)name
{
    for (NSString * category in self.collections)
    {
        for (NSString * collection in self.collections[category])
        {
            if ([name isEqualToString:collection])
            {
                return true;
            }
        }
    }
    return false;
}

-(int) numberOfCollectionsInCategory: (NSString *) category
{
    return [self.collections[category] count];
}

-(int) numberOfCategories
{
    return [self.collections count];
}

-(BOOL) canRemoveCategory: (NSString *) category
{
    if ([category isEqualToString:UNCATEGORIZED_KEY] ||
        [category isEqualToString:ALL] ||
        [category isEqualToString:SHARED_COLLECTIONS_KEY])
    {
        return NO;
    }
    else
    {
        return YES;
    }
    
}

-(BOOL) isCategoryEditable:(NSString *) categoryName
{
    if ([categoryName isEqual:ALL] ||
        [categoryName isEqual:UNCATEGORIZED_KEY] ||
        [categoryName isEqual:SHARED_COLLECTIONS_KEY])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(void) setImageData:(NSData *)imgData
       forCollection:(NSString *)collectionName
{
    if (imgData)
    {
        self.collectionImages[collectionName] = imgData;
    }
}

-(NSData *)getImageDataForCollection:(NSString *)collectionName
{
    if(self.collectionImages[collectionName])
    {
        return self.collectionImages[collectionName];
    }
    else
    {
        //these are collection specific data sources
        CachedMindCloudDataSource * dataSource = [CachedMindCloudDataSource getInstance:collectionName];
        NSData * imgData = [dataSource getThumbnailForCollection:collectionName];
        if(imgData != nil)
        {
            [self setImageData: imgData forCollection: collectionName];
        }
        return imgData;
    }
}

-(void) subscribeToCollectionWithSecret:(NSString *) sharingSecret
{
    [self.sharingAdapter subscriberToCollection:sharingSecret];
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

#pragma mark notification events

-(void) collectionShared:(NSNotification *) notification
{
    NSDictionary * result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    if (collectionName)
    {
        id<MindcloudAllCollectionsDelegate> tempDel = self.delegate;
        if (tempDel)
        {
            [self moveCollection:collectionName fromCategory:[tempDel activeCategory]
                   toNewCategory:SHARED_COLLECTIONS_KEY];
        //        [self swithToCategory:SHARED_COLLECTIONS_KEY];
            
        }
        self.shouldSaveCategories = YES;
    }
}


-(void) allCollectionsReceived:(NSNotification *) notification
{
    NSArray* allCollections = notification.userInfo[@"result"];
    [self reloadCollectionsWithNewCollections:allCollections];
    id <MindcloudAllCollectionsDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        [tempDel collectionsLoaded];
    }
}

-(void) categoriesReceived:(NSNotification *) notification
{
    
    NSDictionary * dict = notification.userInfo[@"result"];
    [self applyCategories:dict];
    //to synchronize the categories with reality
    [self saveCategories];
    id <MindcloudAllCollectionsDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        [tempDel categoriesLoaded];
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
    
    [self setImageData:imgData forCollection:collectionName];
    
    id <MindcloudAllCollectionsDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        [tempDel thumbnailLoadedForCollection:collectionName
                                withImageData:imgData];
    }
}

#pragma mark - synchronization
-(void) saveCategories
{
    if (self.shouldSaveCategories)
    {
        NSData * categoriesData = [XoomlCategoryParser serializeToXooml:self];
        [self.dataSource saveCategories:categoriesData];
        self.shouldSaveCategories = NO;
    }
}

-(void) saveCategories:(NSTimer *) timer
{
    [self saveCategories];
}

#pragma mark CategoryModelProtocol
-(NSArray *)getAllSerializableCategories
{
    NSMutableArray * serializableCategories = [[self.collections allKeys] mutableCopy];
    [serializableCategories removeObject:ALL];
    [serializableCategories removeObject:UNCATEGORIZED_KEY];
    return [serializableCategories copy];
}

-(NSArray *) getSerializableCollectionsForCategory:(NSString *)category
{
    if (self.collections[category] == nil)
    {
        return [NSArray array];
    }
    else
    {
        return [self getCollectionsForCategory:category];
    }
}

#pragma mark - syncrhonized object
-(void) refresh
{
    [self stopTimer];
    [self getAllCollections];
    [self startTimer];
}

-(void) synchronize
{
    [self saveCategories];
}

-(void) stopSynchronization
{
    [self stopTimer];
}

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
@end
