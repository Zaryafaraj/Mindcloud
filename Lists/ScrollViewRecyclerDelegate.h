//
//  ScrollViewRecyclerDelegate.h
//  Lists
//
//  Created by Ali Fathalian on 4/16/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainScreenRow.h"

@protocol ScrollViewRecyclerDelegate <NSObject>
-(UIView<ListRow> *) rowForIndex:(int) index
             withPrototype:(id<ListRow> ) prototype;

-(int) lowestIndexInView;

-(int) highestIndexInView;

@end
