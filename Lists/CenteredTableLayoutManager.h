//
//  MainScreenListLayout.h
//  Lists
//
//  Created by Ali Fathalian on 4/8/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableLayoutManagerProtocol.h"

@interface CenteredTableLayoutManager : NSObject <TableLayoutManagerProtocol>

@property CGFloat rowDivider;
@property (nonatomic) CGFloat verticalOffsetFromTop;
@property (nonatomic) CGFloat rowWidth;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) CGFloat subItemHeight;
@property (nonatomic) CGFloat contextualMenuHoriziontalOffset;

-(id) initWithDivider:(CGFloat) dividerSpace;

@end
