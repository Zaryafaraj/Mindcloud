//
//  MainScreenRowViewDelegate.h
//  Lists
//
//  Created by Ali Fathalian on 4/21/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListRow.h"

@protocol MainScreenRowViewDelegate <NSObject>

-(void) deletePressed:(UIView<ListRow> *) sender;
-(void) renamePressed:(UIView<ListRow> *) sender;
-(void) sharePressed:(UIView<ListRow> *) sender;

@end
