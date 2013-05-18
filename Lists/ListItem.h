//
//  ListItem.h
//  Lists
//
//  Created by Ali Fathalian on 5/17/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListSubItem.h"

@interface ListItem : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) UIImage * image;
@property int index;
@property BOOL areSubItemsVisible;

-(id) initWithName:(NSString *) name
          andIndex:(int) index;

-(int) numberOfSubItems;

-(ListSubItem *) subItemAtIndex:(int) index;

-(void) addSubItem: (ListSubItem *) subItem
           atIndex:(int) index;

-(void) removeSubItem:(ListSubItem *) subItem
              atIndex:(int) index;

-(void) swapSubItemAtIndex:(int) index1
        withSubItemAtIndex:(int) index2;

@end
