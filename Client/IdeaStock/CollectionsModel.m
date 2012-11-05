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
    self.collections[ALL] = [collections mutableCopy];
    self.collections[UNCATEGORIZED_KEY] = [collections mutableCopy];
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
        [self.collections[UNCATEGORIZED_KEY] addObject:collection];
    }
    //if we add to a category it should be in all automatically
    else
    {
        [self.collections[ALL] addObject:collection];
    }
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
    
    //if the deleted from all we need to delete it from the corresponding category
    if ([cateogry isEqualToString:ALL])
    {
        for (NSString * category in self.collections)
        {
            [self.collections[category] removeObject:collection];
        }
    }
    //if we deleted from something other than all we need to delete it from all
    else
    {
        [self.collections[ALL] removeObject:collection];
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
        [category isEqualToString:ALL])
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
    }
}

-(void) moveCollection:(NSString *)collectionName
          fromCategory:(NSString *)oldCategory
         toNewCategory:(NSString *)newCategory
{
    //you can't move stuff from all categories
    if ([oldCategory isEqualToString:ALL]) return;
    
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
    
    self.collections[ALL] = [collections copy];
    self.collections[UNCATEGORIZED_KEY] = uncategorized;
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
        [category isEqualToString:ALL])
    {
        return NO;
    }
    else
    {
        return YES;
    }
    
}
@end
