//
//  CollectionBoardDelegate.h
//  Mindcloud
//
//  Created by Ali Fathalian on 10/25/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CollectionBoardDelegate <NSObject>

-(void) didFinishDrawingOnScreen;
-(void) willBeginDrawingOnScreen;

@end
