//
//  ListTableViewDatasource.h
//  Lists
//
//  Created by Ali Fathalian on 4/20/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListItem.h"

@protocol ListDatasource <NSObject>

-(void) addItem:(ListItem *) item
        atIndex:(int) index;

-(void) removeItemAtIndex:(int) index;

-(void) incrementAllIndexesAfterIndex:(int) afterIndex;

-(void) decrementAllIndexesAfterIndex:(int) afterIndex;

-(void) setTitle:(NSString *) title
        ForItemAtIndex:(int) index;

-(NSString *) titleForItemAtIndex:(int) index;

-(void) setImage:(UIImage *) image
  ForItemAtIndex:(int) index;

-(UIImage *) imageForItemAtIndex:(int) index;

-(int) count;

@end
