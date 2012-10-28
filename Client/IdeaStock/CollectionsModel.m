//
//  CollectionsModel.m
//  IdeaStock
//
//  Created by Ali Fathalian on 10/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CollectionsModel.h"

#define UNCATEGORIZED_KEY @"uncategorized"

@interface CollectionsModel()

/*Dictionary of arrays keyed on the category name. Each array contains all the collections
belonging to that category*/
@property (nonatomic, strong) NSMutableDictionary * collections;

@end

@implementation CollectionsModel

-(id) init
{
    self = [super init];
    self.collections = [NSMutableDictionary dictionary];
    return self;
}

-(id) initWithCollections:(NSArray *)collections
{
    self = [self init];
    self.collections[UNCATEGORIZED_KEY] = collections;
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
    if (self.collections[category]) [self.collections[category] addObject:collection];
    else self.collections[category] = [NSMutableArray arrayWithObject:collection];
}

-(void) addCategory: (NSString *) category
{
    self.collections[category] = [NSMutableArray array];
}

-(void) removeCollection:(NSString *) collection fromCategory: (NSString *) cateogry
{
    if (self.collections[cateogry])
    {
        if ([self.collections[cateogry] containsObject:collection])
        {
            [self.collections[cateogry] removeObject:collection];
        }
    }
}

-(void) removeCategory: (NSString *) category
{
    [self.collections removeObjectForKey:category];
}

-(NSArray *) getAllCategories
{
    return [[self.collections allKeys] copy];
}

-(NSArray *) getCollectionsForCategory: (NSString *) category
{
    return [self.collections[category] copy];
}

-(void) renameCategory:(NSString *)category toNewCategory:(NSString *)newCategory
{
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
    }
}

-(void) moveCollection:(NSString *)collectionName
          fromCategory:(NSString *)oldCategory
         toNewCategory:(NSString *)newCategory
{
    if (self.collections[oldCategory] && self.collections[newCategory])
    {
        [self.collections[newCategory] addObject:collectionName];
        [self.collections[oldCategory] removeObject:collectionName];
    }
}

-(void) applyCategories:(NSDictionary *)categories
        toCollections: (NSArray *) collections
{
    NSMutableDictionary * uncategorized = [NSMutableDictionary dictionary];
    for (NSString * collection in collections)
    {
        uncategorized[collection] = @YES;
    }
    
    for (NSString * key in categories)
    {
        self.collections[key] = categories[key];
        for (NSString * categorizedCollection in categories[key])
        {
            uncategorized[collections] = @NO;
        }
    }
    
    NSMutableArray * uncategorizedArray = [NSMutableArray array];
    for (NSString * collection in uncategorized)
    {
        if (uncategorized[collection])
        {
            [uncategorizedArray addObject:collection];
        }
    }
    
    self.collections[UNCATEGORIZED_KEY] = uncategorized;
}

@end
