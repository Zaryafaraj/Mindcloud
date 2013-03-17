//
//  CollectionsModel.m
//  IdeaStock
//
//  Created by Ali Fathalian on 10/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CollectionsModel.h"


@interface CollectionsModel()

/*Dictionary of arrays keyed on the category name. Each array contains all the collections
 belonging to that category*/
@property (nonatomic, strong) NSMutableDictionary * collections;
@property (atomic, strong) NSMutableDictionary * collectionImages;

@end

@implementation CollectionsModel


@synthesize collectionImages = _collectionImages;

-(NSMutableDictionary *) collectionImages
{
    if (_collectionImages == nil)
    {
        _collectionImages = [NSMutableDictionary dictionary];
    }
    return _collectionImages;
}

-(void) setCollectionImages:(NSMutableDictionary *)collectionImages
{
    self.collectionImages = collectionImages;
}

-(id) init
{
    self = [super init];
    self.collections = [NSMutableDictionary dictionary];
    return self;
}

-(id) initWithCollections:(NSArray *)collections
{
    self = [self init];
    self.collections[ALL] = [collections mutableCopy];
    self.collections[UNCATEGORIZED_KEY] = [collections mutableCopy];
    self.collections[SHARED_COLLECTIONS_KEY] = [NSMutableArray array];
    return self;
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
}

-(void) addCollection: (NSString *) collection toCategory: (NSString *) category
{
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

-(NSArray *) getEditableCategories
{
    
    NSMutableArray * editablesArray = [[self.collections allKeys] mutableCopy];
    [editablesArray removeObject:ALL];
//    [editablesArray removeObject:UNCATEGORIZED_KEY];
//    [editablesArray removeObject:SHARED_COLLECTIONS_KEY];
    
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
    return self.collectionImages[collectionName];
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
@end
