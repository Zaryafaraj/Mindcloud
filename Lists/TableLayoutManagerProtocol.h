//
//  ListTableViewLayoutManager.h
//  Lists
//
//  Created by Ali Fathalian on 4/19/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListRowProtocol.h"

@protocol TableLayoutManagerProtocol <NSObject>

- (CGRect) frameForRowforIndex:(int) index
          inSuperView:(UIView *) superView;

- (CGPoint) originForFrameAfterFrame:(CGRect) frame;

- (int) lowestRowIndexInFrame:(CGRect) frame;

- (int) highestRowIndexInFrame:(CGRect) frame;


-(CGRect) frameForContextualMenuInRow:(UIView<ListRowProtocol> *) row;

-(CGFloat) distanceFromRowToContextualMenu;

@end