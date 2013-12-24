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
/*! if true is returned it means that the tap should not 
    be captured for drawing */
-(BOOL) screenTapped;
-(void) doubleTapDetectedAtLocation:(CGPoint) location;

@end
