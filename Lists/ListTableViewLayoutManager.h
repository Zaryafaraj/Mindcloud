//
//  ListTableViewLayoutManager.h
//  Lists
//
//  Created by Ali Fathalian on 4/19/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListRow.h"

@protocol ListTableViewLayoutManager <NSObject>

- (CGRect) frameForRowforIndex:(int) index
          inSuperView:(UIView *) superView;

- (CGPoint) originForFrameAfterFrame:(CGRect) frame;

- (int) lowestRowIndexInFrame:(CGRect) frame;

- (int) highestRowIndexInFrame:(CGRect) frame;


-(CGRect) frameForContextualMenuInRow:(UIView<ListRow> *) row;
@end
