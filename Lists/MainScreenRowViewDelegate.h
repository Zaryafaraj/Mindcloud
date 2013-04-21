//
//  MainScreenRowViewDelegate.h
//  Lists
//
//  Created by Ali Fathalian on 4/21/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainScreenRow.h"

@protocol MainScreenRowViewDelegate <NSObject>

-(void) deletePressed:(MainScreenRow *) sender;
-(void) renamePressed:(MainScreenRow *) sender;
-(void) sharePressed:(MainScreenRow *) sender;

@end
