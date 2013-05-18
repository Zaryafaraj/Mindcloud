//
//  StubListTableViewDatasource.m
//  Lists
//
//  Created by Ali Fathalian on 4/20/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "StubListTableViewDatasource.h"

@interface StubListTableViewDatasource()

//dictionary of list items
@property (strong, nonatomic) NSMutableDictionary * model;

//Keyed on index. For each index indicates how many open subItems are before it
@property (strong, nonatomic) NSMutableDictionary * cumalitiveSubItems;
@end

@implementation StubListTableViewDatasource

-(id) init
{
    self = [super init];
    self.model = [NSMutableDictionary dictionary];
    self.cumalitiveSubItems = [NSMutableDictionary dictionary];
    return self;
}

-(NSString *) titleForItemAtIndex:(int) index
{
    NSNumber * indexObj = [NSNumber numberWithInt:index];
    ListItem * item = self.model[indexObj];
    return item.name;
}

-(UIImage *) imageForItemAtIndex:(int) index
{
    return nil;
}

-(void) setTitle:(NSString *) title
        ForItemAtIndex:(int) index
{
    NSNumber * indexObject = [NSNumber numberWithInt:index];
    if (self.model[indexObject])
    {
        ListItem * item = self.model[indexObject];
        item.name = title;
    }
}

-(void) setImage:(UIImage *) image
  ForItemAtIndex:(int) index
{
    ;
}

-(void) addItem:(ListItem *) item
        atIndex:(int) index;
{
    [self incrementAllIndexesAfterIndex:index-1];
    NSNumber * indexObj = [NSNumber numberWithInt:index];
    self.model[indexObj] = item;
    if (index - 1 >= 0)
    {
        NSNumber * prevIndexObj = [NSNumber numberWithInt:index -1];
        ListItem * prevItem = self.model[prevIndexObj];
        NSNumber * prevCumilitiveSubItems = self.cumalitiveSubItems[prevIndexObj];
        int currentCumilitiveSubItems = [prevCumilitiveSubItems intValue];
        if (prevItem.areSubItemsVisible)
        {
            currentCumilitiveSubItems += [prevItem numberOfSubItems];
        }
        NSNumber * cumilitiveSubNotes = [NSNumber numberWithInt:currentCumilitiveSubItems];
        self.cumalitiveSubItems[indexObj] = cumilitiveSubNotes;
    }
    else
    {
        self.cumalitiveSubItems[indexObj] = [NSNumber numberWithInt:0];
    }
    
    if (item.areSubItemsVisible)
    {
        [self addSubItemsOfItem:item
        toCumilitiveSubItemsAfterIndex:index];
    }
}

-(void) addSubItemsOfItem:(ListItem *) item
toCumilitiveSubItemsAfterIndex:(int) index
{
    int addedSubItems = [item numberOfSubItems];
    for (NSNumber * nextIndex in self.cumalitiveSubItems.allKeys)
    {
        if ([nextIndex intValue] > index)
        {
            NSNumber * subItems = self.cumalitiveSubItems[nextIndex];
            int newCumilitiveSubItems = [subItems intValue] + addedSubItems;
            NSNumber * finalSubItems = [NSNumber numberWithInt:newCumilitiveSubItems];
            self.cumalitiveSubItems[nextIndex] = finalSubItems;
        }
    }
}

-(void) removeSubItemsOfItem:(ListItem *)item
fromCumilitiveSubItemsAfterIndex:(int) index
{
    int removedSubItems = [item numberOfSubItems];
    for (NSNumber * nextIndex in self.cumalitiveSubItems.allKeys)
    {
        if ([nextIndex intValue] > index)
        {
            NSNumber * subItems = self.cumalitiveSubItems[nextIndex];
            int newCumilitiveSubItems = [subItems intValue] - removedSubItems;
            NSNumber * finalSubItems = [NSNumber numberWithInt:newCumilitiveSubItems];
            self.cumalitiveSubItems[nextIndex] = finalSubItems;
        }
    }
}

-(void) incrementAllIndexesAfterIndex:(int) afterIndex
{
    NSMutableDictionary * newModel = [NSMutableDictionary dictionary];
    NSMutableDictionary * newCumilitiveSubItems = [NSMutableDictionary dictionary];
    
    for(NSNumber * index in self.model.allKeys)
    {
        int newIndex = -1;
        ListItem * newItem = nil;
        if ([index intValue] > afterIndex)
        {
            newIndex = [index intValue]+1;
            NSString * title = [NSString stringWithFormat:@"%d", newIndex];
            newItem =  [[ListItem alloc] initWithName:title andIndex:newIndex];
        }
        else
        {
            newIndex = [index intValue];
            newItem = self.model[index];
        }
        
        NSNumber * newIndexObj = [NSNumber numberWithInt:newIndex];
        newModel[newIndexObj] = newItem;
        newCumilitiveSubItems[newIndexObj] = self.cumalitiveSubItems[index];
    }
    self.model = newModel;
    self.cumalitiveSubItems = newCumilitiveSubItems;
}

-(void) removeItemAtIndex:(int)index
{
    NSNumber * indexObj = [NSNumber numberWithInt:index];
    ListItem * item = self.model[indexObj];
    if (item.areSubItemsVisible)
    {
        [self removeSubItemsOfItem:item fromCumilitiveSubItemsAfterIndex:index];
    }
    [self decrementAllIndexesAfterIndex:index-1];
}

-(void) decrementAllIndexesAfterIndex:(int)afterIndex
{
    NSMutableDictionary * newModel = [NSMutableDictionary dictionary];
    NSMutableDictionary * newCumilitiveSubItems = [NSMutableDictionary dictionary];
    for(NSNumber * index in self.model.allKeys)
    {
        int newIndex = -1;
        if ([index intValue] > afterIndex)
        {
            newIndex = [index intValue]-1;
        }
        else
        {
            newIndex = [index intValue];
        }
        
        NSNumber * newIndexObj = [NSNumber numberWithInt:newIndex];
        if (newIndex >= 0)
        {
            ListItem * item = self.model[index];
            item.index = newIndex;
            newModel[newIndexObj] = self.model[index];
            newCumilitiveSubItems[newIndexObj] = self.cumalitiveSubItems[index];
        }
    }
    self.model = newModel;
    self.cumalitiveSubItems = newCumilitiveSubItems;
}

-(int) indexOfItemWithTitle:(NSString *)title
{
    for (NSNumber * index in self.model.allKeys)
    {
        ListItem * item = self.model[index];
        if ([item.name isEqualToString:title])
        {
            return item.index;
        }
    }
    return -1;
}


-(int) count
{
    return [self.model count];
}

#pragma mark - DataSource Indexer Protocol
-(int) numberOfItemsBeforeIndex:(int) index
{
    return index;
}

-(int) numberOfItemsAfterIndex:(int) index
{
    return [self.model count] - index - 1;
}

-(int) numberOfSubItemsBeforeIndex:(int) index
{
    NSNumber * indexObj = [NSNumber numberWithInt:index];
    NSNumber * beforeNotes = self.cumalitiveSubItems[indexObj];
    return [beforeNotes intValue];
}

-(int) numberOfSubItemsAfterIndex:(int) index
{
    NSNumber * indexObj = [NSNumber numberWithInt:index];
    NSNumber * beforeNotes = self.cumalitiveSubItems[indexObj];
    NSNumber * lastItemIndexObj = [NSNumber numberWithInt:[self.cumalitiveSubItems count] -1];
    NSNumber * allNotes = self.cumalitiveSubItems[lastItemIndexObj];
    ListItem * selfItem = self.model[indexObj];
    int  selfSubItems = [selfItem numberOfSubItems];
    int afterNotes = [allNotes intValue] - [beforeNotes intValue] - selfSubItems;
    return afterNotes;
}

-(int) numberOfSubItemsInIndex:(int) index
{
    NSNumber * indexObj = [NSNumber numberWithInt:index];
    ListItem * item = self.model[indexObj];
    return [item numberOfSubItems];
}
@end
