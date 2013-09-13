//
//  CollectionsModel.m
//  IdeaStock
//
//  Created by Ali Fathalian on 10/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MindcloudAllCollections.h"
#import "SharingAwareObject.h"
#import "MindcloudAllCollectionsGordon.h"

@interface MindcloudAllCollections()

/*Dictionary of arrays keyed on the category name. Each array contains all the collections
 belonging to that category*/
@property (nonatomic, strong) NSMutableDictionary * collections;
@property (atomic, strong) NSMutableDictionary * collectionImages;
@property (atomic, strong) MindcloudAllCollectionsGordon * gordonDataSource;
@property (weak, nonatomic) id<MindcloudAllCollectionsDelegate> delegate;
@end

@implementation MindcloudAllCollections

-(id<MindcloudAllCollectionsDelegate>) delegate
{
    if (_delegate != nil)
    {
        id<MindcloudAllCollectionsDelegate> tempDel = _delegate;
        return tempDel;
    }
    return nil;
}

-(id) initWithDelegate:(id<MindcloudAllCollectionsDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.collections = [NSMutableDictionary dictionary];
        self.collectionImages = [NSMutableDictionary dictionary];
        self.delegate = delegate;
        self.gordonDataSource = [[MindcloudAllCollectionsGordon alloc] initWithDelegate:self];
        
    }
    return self;
}

-(id) initWithCollections:(NSArray *)collections
            andCategories: (NSDictionary *) categories
              andDelegate:(id<MindcloudAllCollectionsDelegate>) delegate;
{
    self = [self initWithDelegate:delegate];
    [self applyCategories:categories toCollections:collections];
    return self;
}

-(void) applyCategories:(NSDictionary *)categories
{
    [self applyCategories:categories toCollections:self.collections[ALL]];
}

-(void) addCollection: (NSString *) collection
           toCategory: (NSString *) category
{
    [self.gordonDataSource addCollectionWithName:collection];
    
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
}

-(void) addCategory: (NSString *) category
{
    if (![category isEqualToString:ALL] &&
        ![category isEqualToString:UNCATEGORIZED_KEY] &&
        ![category isEqualToString:SHARED_COLLECTIONS_KEY]){
        self.collections[category] = [NSMutableArray array];
    }
    [self.gordonDataSource addEmptyCategory:category];
}

-(void) batchRemoveCollections:(NSArray *) collections
                  fromCategory:(NSString *) category
{

    [self.gordonDataSource deleteCollectionsWithName:collections];
    
    //a shared collection belongs to two categories so make sure you delete it from shared category too
    //remove it from internal data strcutures
    for(NSString * collectionName in collections)
    {
        if ([self.collections[SHARED_COLLECTIONS_KEY] containsObject:collectionName])
        {
            [self.gordonDataSource removeFromCategory:SHARED_COLLECTIONS_KEY collectionsWithName:@[collectionName]];
        }
        [self removeInternalStructuresForCollection:collectionName fromCategory:category];
    }
}

-(void) removeInternalStructuresForCollection:(NSString *) collection
                                 fromCategory: (NSString *) cateogry
{
    //make sure we remove the collection from the data structures
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
        for (NSString * otherCategory in self.collections)
        {
            if (self.collections[otherCategory] == nil)
            {
                NSLog(@"Null pointer in the collcetion Model");
                return;
            }
            
            [self.collections[otherCategory] removeObject:collection];
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
        [category isEqualToString:ALL])
    {
        return;
    }
    
    //move all the collections to uncategorized category
    for(NSString * collection in self.collections[category])
    {
        [self.collections[UNCATEGORIZED_KEY] addObject:collection];
    }
    
    [self.collections removeObjectForKey:category];
    
    [self.gordonDataSource removeCategory:category];
    
}

-(NSArray *) getAllCollections
{
    return [self.gordonDataSource getAllCollections];
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
    return [self.gordonDataSource getAllCategoriesMappings];
}

-(void) refresh
{
    [self.gordonDataSource refresh];
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
    
    [self.gordonDataSource renameCategory:category toNewName:newCategory];
}

-(void) renameCollection:(NSString *)collection
              inCategory:(NSString *)category
         toNewCollection:(NSString *)newCollection
{
    
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
    [self.gordonDataSource renameCollectionWithName:collection to:newCollection];
}


-(void) moveCollections: (NSArray *) collections
           fromCategory: (NSString *) oldCategory
          toNewCategory: (NSString *) newCategory;
{
    
    if ([newCategory isEqualToString:ALL] ||
        [newCategory isEqualToString:SHARED_COLLECTIONS_KEY])
    {
        return;
    }
    
    if (!self.collections[oldCategory] || !self.collections[newCategory])
        return;
    
    
    //in each iteration of the for loop the original category may be different.
    //for example if we move multiple collections from all category that each
    //belong to a different category to a single new category
    //for this reason we use dictionaries that map an original category to collections
    //that are in there
    NSMutableArray * collectionsToAdd = [NSMutableArray array];
    NSMutableDictionary * collectionsToMove = [NSMutableDictionary dictionary];
    NSMutableDictionary * collectionsToRemove = [NSMutableDictionary dictionary];
    
    NSString * originalOldCat = oldCategory;
    for(NSString * collectionName in collections)
    {
        
        if ([self.collections[newCategory] containsObject:collectionName]) return;
        
        //IF the old category is a conceptual category find the real category
        if ([oldCategory isEqualToString:ALL] ||
            [oldCategory isEqualToString:UNCATEGORIZED_KEY] ||
            [oldCategory isEqualToString:SHARED_COLLECTIONS_KEY])
        {
            originalOldCat = [self findCategoryForCollection:collectionName];
            
            //always remove from uncategorized
            if ([self.collections[UNCATEGORIZED_KEY] containsObject:collectionName])
            {
                [self.collections[UNCATEGORIZED_KEY] removeObject:collectionName];
            }
        }
        
        [self.collections[newCategory] addObject:collectionName];
        
        //remove it from the conceptual category
        if (![oldCategory isEqualToString:ALL])
        {
            [self.collections[oldCategory] removeObject:collectionName];
        }
        
        //remove it from the actual category
        if (originalOldCat != nil)
        {
            [self.collections[originalOldCat] removeObject:collectionName];
        }
        
        //since uncategorized is a conceptual category we don't need to move the
        //collection we just remove it from the old category
        if ([newCategory isEqualToString:UNCATEGORIZED_KEY])
        {
            if (originalOldCat != nil)
            {
                if (!collectionsToRemove[originalOldCat])
                {
                    collectionsToRemove[originalOldCat] = [NSMutableArray array];
                }
                NSMutableArray * collectionList = collectionsToRemove[originalOldCat];
                [collectionList addObject:collectionName];
                collectionsToRemove[originalOldCat] = collectionList;
                
            }
        }
        //we are moving from a conceptual category so its not a move method but an
        //add method
        if (originalOldCat == nil)
        {
            [collectionsToAdd addObject:collectionName];
        }
        //this is a proper move
        else
        {
            if (originalOldCat != nil)
            {
                if (!collectionsToMove[originalOldCat])
                {
                    collectionsToMove[originalOldCat] = [NSMutableArray array];
                }
                NSMutableArray * collectionList = collectionsToMove[originalOldCat];
                [collectionList addObject:collectionName];
                collectionsToMove[originalOldCat] = collectionList;
                
            }
        }
    }
    
    //in this case we need to remove the collection from its category
    if ([newCategory isEqualToString:UNCATEGORIZED_KEY])
    {
        for(NSString * previousCategory in collectionsToRemove)
        {
            NSArray * allCollections = collectionsToRemove[previousCategory];
            [self.gordonDataSource removeFromCategory:previousCategory
                                  collectionsWithName:allCollections];
        }

    }

    if ([collectionsToMove count] > 0)
    {
        for(NSString * previousCategory in collectionsToMove)
        {
            NSArray * allCollections = collectionsToMove[previousCategory];
            [self.gordonDataSource moveCollections:allCollections
                                   fromOldCategory:previousCategory
                                     toNewCategory:newCategory];
        }

    }
    
    if ([collectionsToAdd count] > 0)
    {
            [self.gordonDataSource addToCategory:newCategory
                            collectionsWithNames:collectionsToAdd];
    }
}

-(NSString *) findCategoryForCollection:(NSString *) collectionName
{
    for(NSString * categoryName in self.collections)
    {
        //these are all abstract categories. Try finding the true category
        if ([categoryName isEqualToString:UNCATEGORIZED_KEY] ||
            [categoryName isEqualToString:ALL] ||
            [categoryName isEqualToString:SHARED_COLLECTIONS_KEY])
        {
            continue;
        }
        NSArray * allCollections = self.collections[categoryName];
        if ([allCollections containsObject:collectionName])
        {
            return categoryName;
        }
    }
    return nil;
}
/*! Categorises the collections based on the categories passed in.
 categories is a map keyed on categoryName and valued on an array of collectionNames belonging to the category */
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


-(NSSet *) getAllCollectionNames
{
    NSMutableSet * result = [NSMutableSet set];
    for (NSString * category in self.collections)
    {
        for (NSString * collection in self.collections[category])
        {
            [result addObject:collection];
        }
    }
    return result;
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
        NSData * imgData = [self.gordonDataSource getThumbnailForCollection:collectionName];
        if(imgData != nil)
        {
            [self setImageData: imgData forCollection: collectionName];
        }
        return imgData;
    }
}

-(void) subscribeToCollectionWithSecret:(NSString *) sharingSecret
{
    [self.gordonDataSource subscribeToCollectionWithSecret:sharingSecret];
}

-(void) shareCollection:(NSString *) collectionName
{
    [self.gordonDataSource shareCollection:collectionName];
}


-(void) unshareCollection:(NSString *) collectionName
{
    [self.gordonDataSource unshareCollection:collectionName];
}

#pragma mark notification events

-(void) createSharedCategoryIfNeccessaryWithCollection:(NSString *) collectionName
{
    //if we never had a shared category first create it
    if (self.collections[SHARED_COLLECTIONS_KEY] == nil)
    {
        self.collections[SHARED_COLLECTIONS_KEY] = [NSMutableArray array];
    }
    
    if ([self.collections[SHARED_COLLECTIONS_KEY] count] == 0)
    {
        [self.gordonDataSource addCategory:SHARED_COLLECTIONS_KEY withCollections:@[collectionName]];
    }
    
}
-(void) collectionGotShared:(NSString *) collectionName
                 withSecret:(NSString *)secret
{
    
    [self createSharedCategoryIfNeccessaryWithCollection:collectionName];
    id<MindcloudAllCollectionsDelegate> tempDel = self.delegate;
    [self moveCollections:@[collectionName] fromCategory:[tempDel activeCategory]
            toNewCategory:SHARED_COLLECTIONS_KEY];
    if (tempDel)
    {
        [tempDel sharedCollection:collectionName withSecret:secret];
        
    }
}

-(void) collectionsLoaded:(NSArray *) allCollections
{
    if (allCollections == nil) return;
    self.collections[ALL] = [allCollections mutableCopy];
    self.collections[UNCATEGORIZED_KEY] = [allCollections mutableCopy];
    self.collections[SHARED_COLLECTIONS_KEY] = [NSMutableArray array];
    
    
    id <MindcloudAllCollectionsDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        [tempDel collectionsLoaded];
    }
}

-(void) categoriesLoaded:(NSDictionary *) allCategoriesMappings
{
    [self applyCategories:allCategoriesMappings];
    
    id <MindcloudAllCollectionsDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        [tempDel categoriesLoaded];
    }
}

-(void) thumbnailLoadedForCollection:(NSString *) collectionName
                             andData:(NSData *) imgData
{
    [self setImageData:imgData forCollection:collectionName];
    
    id <MindcloudAllCollectionsDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        [tempDel thumbnailLoadedForCollection:collectionName
                                withImageData:imgData];
    }
    
}

-(void) failedToSubscribeToSharingSpace
{
    id <MindcloudAllCollectionsDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        [tempDel failedToSubscribeToSecret];
    }
}

-(void) subscribedToSharingSpaceForCollection:(NSString *) collectionName
{
    
    [self createSharedCategoryIfNeccessaryWithCollection:collectionName];
    id <MindcloudAllCollectionsDelegate> tempDel = self.delegate;
    if (self.collections[SHARED_COLLECTIONS_KEY])
    {
        for (NSString * existingCollection in self.collections[SHARED_COLLECTIONS_KEY])
        {
            if ([existingCollection isEqualToString:collectionName])
            {
                if (tempDel)
                {
                    [tempDel alreadySubscribedToCollectionWithName:collectionName];
                    return;
                }
            }
        }
        
        [self addCollection:collectionName toCategory:SHARED_COLLECTIONS_KEY];
        
        if (tempDel)
        {
            [tempDel subscribedToCollectionWithName:collectionName];
        }
    }
    else
    {
        [self addCollection:collectionName toCategory:SHARED_COLLECTIONS_KEY];
        
        if (tempDel)
        {
            [tempDel subscribedToCollectionWithName:collectionName];
        }
    }
}

@end
