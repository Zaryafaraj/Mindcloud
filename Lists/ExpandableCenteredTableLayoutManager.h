//
//  ExpandableCenteredTableViewLayoutManager.h
//  Lists
//
//  Created by Ali Fathalian on 5/12/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CenteredTableLayoutManager.h"
#import "ListDataSourceIndexer.h"

@interface ExpandableCenteredTableLayoutManager : CenteredTableLayoutManager

-(id) initWithDivider:(CGFloat)dividerSpace
       andItemIndexer:(id<ListDataSourceIndexer>) indexer;

@end
