//
//  ScrollViewRecyclerDelegate.h
//  Lists
//
//  Created by Ali Fathalian on 4/16/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionRow.h"

@protocol ScrollViewRecyclerDelegate <NSObject>
-(UIView<ListRowProtocol> *) rowForIndex:(int) index
             withPrototype:(id<ListRowProtocol> ) prototype;

-(NSArray *) lowestAndHighestIndexInView;

-(void) didRecycledRow:(UIView<ListRowProtocol> *)recycledView
              ForIndex:(int) index;

@end
