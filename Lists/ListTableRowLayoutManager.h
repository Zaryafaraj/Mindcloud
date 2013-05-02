//
//  ListTableRowLayoutManager.h
//  Lists
//
//  Created by Ali Fathalian on 4/26/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListRow.h"

@protocol ListTableRowLayoutManager <NSObject>

- (CGRect) frameForOpenedRow:(CGRect) closedFrame;

-(CGRect) frameForButtonInBounds:(CGRect) parentBounds
              WithBackgroundView:(UIView *) backgroundView;

@end
