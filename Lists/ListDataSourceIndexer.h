//
//  DataSourceIndexerProtocol.h
//  Lists
//
//  Created by Ali Fathalian on 5/17/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ListDataSourceIndexer <NSObject>

-(int) numberOfItemsBeforeIndex:(int) index;
-(int) numberOfItemsAfterIndex:(int) index;
-(int) numberOfSubItemsBeforeIndex:(int) index;
-(int) numberOfSubItemsAfterIndex:(int) index;
-(int) numberOfSubItemsInIndex:(int) index;
-(int) numberOfIndexes;

@end
