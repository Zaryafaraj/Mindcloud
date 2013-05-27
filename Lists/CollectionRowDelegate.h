//
//  MainScreenRowViewDelegate.h
//  Lists
//
//  Created by Ali Fathalian on 4/21/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListRowProtocol.h"

@protocol CollectionRowDelegate <NSObject>

-(void) deletePressed:(UIView<ListRowProtocol> *) sender;
-(void) renamePressed:(UIView<ListRowProtocol> *) sender;
-(void) sharePressed:(UIView<ListRowProtocol> *) sender;
-(void) selectedRow:(UIView<ListRowProtocol> *) sender;
-(void) tappedRow:(UIView<ListRowProtocol> *) sender;
-(void) doubleTappedRow:(UIView<ListRowProtocol> *) sender;
-(BOOL) isEditingRows;

@end
