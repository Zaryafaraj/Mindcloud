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

@end

@implementation StubListTableViewDatasource

-(id) init
{
    self = [super init];
    self.model = [NSMutableDictionary dictionary];
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
}

-(void) incrementAllIndexesAfterIndex:(int) afterIndex
{
    NSMutableDictionary * newModel = [NSMutableDictionary dictionary];
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
    }
    self.model = newModel;
}

-(void) removeItemAtIndex:(int)index
{
    [self decrementAllIndexesAfterIndex:index-1];
}

-(void) decrementAllIndexesAfterIndex:(int)afterIndex
{
    NSMutableDictionary * newModel = [NSMutableDictionary dictionary];
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
        }
    }
    self.model = newModel;
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
    return 0;
}

-(int) numberOfItemsAfterIndex:(int) index
{
    return 0;
}

-(int) numberOfSubItemsBeforeIndex:(int) index
{
    return 0;
}

-(int) numberOfSubItemsAfterIndex:(int) index
{
    return 0;
}

-(int) numberOfSubItemsInIndex:(int) index
{
    return 0;
}
@end
