//
//  ListItem.m
//  Lists
//
//  Created by Ali Fathalian on 5/17/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ListItem.h"

@interface ListItem()
@property (nonatomic, strong) NSMutableDictionary * subNotes;
@end
@implementation ListItem

-(id) init
{
    self = [super init];
    if (self)
    {
        self.subNotes = [NSMutableDictionary dictionary];
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
    return [self.subNotes count];
}

-(ListSubItem *) subItemAtIndex:(int) index
{
    NSNumber * number = [NSNumber numberWithInt:index];
    if (self.subNotes[number])
    {
        return self.subNotes[number];
    }
    return nil;
}

-(void) addSubItem: (ListSubItem *) subItem
           atIndex:(int) index
{
    NSNumber * number = [NSNumber numberWithInt:index];
    self.subNotes[number] = subItem;
}

-(void) removeSubItem:(ListSubItem *) subItem
              atIndex:(int) index
{
    NSNumber * number = [NSNumber numberWithInt:index];
    if (self.subNotes[number])
    {
        [self.subNotes removeObjectForKey:number];
    }
}

-(void) swapSubItemAtIndex:(int) index1
        withSubItemAtIndex:(int) index2
{
    NSNumber * number1 = [NSNumber numberWithInt:index1];
    NSNumber * number2 = [NSNumber numberWithInt:index2];
    ListSubItem * item1 = self.subNotes[number1];
    ListSubItem * item2 = self.subNotes[number2];
    if (item1 && item2)
    {
        self.subNotes[number1] = item2;
        self.subNotes[number2] = item1;
    }
}

@end
