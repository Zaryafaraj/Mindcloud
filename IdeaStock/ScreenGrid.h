//
//  ScreenGrid.h
//  IdeaStock
//
//  Created by Ali Fathalian on 5/13/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScreenGrid : NSObject

- (id)initWithSize: (CGSize) size andRows: (int) rowCount andColomuns: (int) colCount;

- (void) addItem: (id) item WithRect: (CGRect) rect;

- (NSArray *) getOverlappingItemsForRect: (CGRect) rect;

-(void) resizeItem:




@end
