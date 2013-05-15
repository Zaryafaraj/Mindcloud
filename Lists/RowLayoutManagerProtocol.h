//
//  ListTableRowLayoutManager.h
//  Lists
//
//  Created by Ali Fathalian on 4/26/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListRowProtocol.h"

@protocol RowLayoutManagerProtocol <NSObject>

- (CGRect) frameForOpenedRow:(CGRect) closedFrame;

-(CGRect) frameForButtonInBounds:(CGRect) parentBounds
              WithBackgroundView:(UIView *) backgroundView;

@end
