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
#import "ScreenDrawing.h"

@interface CollectionBoardView : UIView <PaintEnabledView>

@property (nonatomic, weak) id<CollectionBoardDelegate> delegate;

@property (nonatomic, strong) UIColor * currentColor;
@property (nonatomic) CGFloat currentWidth;


-(void) unload;

-(void) reload;

-(void) clearPaintedItems;

-(void) cleanupUnwantedArtifacts;

@property (nonatomic) BOOL eraseModeEnabled;

/*! Sometime when we undo the reason is that the there was an unwanted artifact
    for example a double tap that causing drawing. In this case we need to
    record them so that we don't communicate them at all with the server
 
    returns order index of the item that got undid. -1 if nothing got undid
 */
-(NSInteger) undo:(BOOL) isUnwantedArtifact;

-(NSInteger) redo;

-(void) undoItemsAtOrderIndex:(NSArray *) orderIndexes;

-(void) redoItemsAtOrderIndex:(NSArray *) orderIndexes;

-(ScreenDrawing *) getAllScreenDrawings;

//if shouldRebase is true all the new drawings that are return will be moved to old drawings
-(ScreenDrawing *) getNewScreenDrawingsWithRebasing:(BOOL) shouldRebase;

@property BOOL drawingEnabled;

-(void) resetTouchRecorder;

-(void) setAllDrawingContentTo:(ScreenDrawing *) allDrawings;

-(void) applyDiffDrawingContentFrom:(ScreenDrawing *) diffDrawings;


-(void) debug_captureBezier;

@end
