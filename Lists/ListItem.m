//
//  ListItem.m
//  Lists
//
//  Created by Ali Fathalian on 5/17/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ListItem.h"

@interface ListItem()
@property (nonatomic, strong) NSMutableDictionary * subItems;
@end
@implementation ListItem

-(id) init
{
    self = [super init];
    if (self)
    {
        self.subItems = [NSMutableDictionary dictionary];
    }
    return self;
}

-(id) initWithName:(NSString *) name
          andIndex:(int) index
{
    self = [self init];
    if (self)
    {
        self.name = name;
        self.index = index;
    }
    return self;
}

-(int) numberOfSubItems
{
    return [self.subItems count];
}

-(ListSubItem *) subItemAtIndex:(int) index
{
    NSNumber * number = [NSNumber numberWithInt:index];
    if (self.subItems[number])
    {
        return self.subItems[number];
    }
    return nil;
}

-(void) addSubItem: (ListSubItem *) subItem
           atIndex:(int) index
{
    NSMutableDictionary * newSubItems = [NSMutableDictionary dictionary];
    for (NSNumber * itemIndex in self.subItems.allKeys)
    {
        if([itemIndex intValue] >= index)
        {
            ListSubItem * subItem = self.subItems[itemIndex];
            subItem.subIndex += 1;
        }
        int newIndex = subItem.subIndex;
        NSNumber * newIndexObj = [NSNumber numberWithInt:newIndex];
        newSubItems[newIndexObj] = subItem;
    }
    
    subItem.subIndex = index;
    NSNumber * number = [NSNumber numberWithInt:index];
    newSubItems[number] = subItem;
    self.subItems = newSubItems;
    
}

-(void) appendSubItem:(ListSubItem *)subItem
{
    subItem.subIndex = [self numberOfSubItems];
    NSNumber * number = [NSNumber numberWithInt:[self numberOfSubItems]];
    self.subItems[number] = subItem;
}

-(void) removeSubItem:(ListSubItem *) subItem
              atIndex:(int) index
{
    NSNumber * number = [NSNumber numberWithInt:index];
    if (self.subItems[number])
    {
        [self.subItems removeObjectForKey:number];
    }
    for (NSNumber * itemIndex in self.subItems.allKeys)
    {
        if([itemIndex intValue]> index)
        {
            ListSubItem * subItem = self.subItems[itemIndex];
            subItem.subIndex -= 1;
        }
    }
}

-(void) swapSubItemAtIndex:(int) index1
        withSubItemAtIndex:(int) index2
{
    NSNumber * number1 = [NSNumber numberWithInt:index1];
    NSNumber * number2 = [NSNumber numberWithInt:index2];
    ListSubItem * item1 = self.subItems[number1];
    ListSubItem * item2 = self.subItems[number2];
    if (item1 && item2)
    {
        self.subItems[number1] = item2;
        self.subItems[number2] = item1;
    }
}

@end
