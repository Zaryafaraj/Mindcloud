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

#define MAX_BRUSH_WIDTH 20.0f
#define MIN_BRUSH_WIDTH 1.0f
#define DEFAULT_BRUSH_WIDTH 10.0f

@interface CollectionBoardView : UIView <PaintEnabledView>

@property (nonatomic, weak) id<CollectionBoardDelegate> delegate;

@property (nonatomic, strong) UIColor * currentColor;
@property (nonatomic) CGFloat currentWidth;

-(void) unload;

-(void) reload;

-(void) clearPaintedItems;

-(void) cleanupPinchArtifacts;

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
