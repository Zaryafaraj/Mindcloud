//
//  CollectionBoardView.h
//  Mindcloud
//
//  Created by Ali Fathalian on 10/15/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintEnabledView.h"
#import "CollectionBoardDelegate.h"

@interface CollectionBoardView : UIView <PaintEnabledView>

@property (nonatomic, weak) id<CollectionBoardDelegate> delegate;

-(void) unload;

-(void) reload;

-(void) clearPaintedItems;

@property (nonatomic) BOOL eraseModeEnabled;

-(void) undo;

@property BOOL drawingEnabled;

/*! NSDictionary of serialized data for the drawing. Its keyed on the 
    gird index*/
-(NSDictionary *) getAllDrawingData;

/*! only gets the views that have been touched since the touch
    recorder has been reseted
 */
-(NSDictionary *) getAllDrawingDataForTouchedViews;

-(void) resetTouchRecorder;

/*! NSDictionary of serialized data for the drawing. Its keyed on the 
 gird index*/
-(void) applyBaseDrawingData:(NSDictionary *) baseDrawingData;

@end
