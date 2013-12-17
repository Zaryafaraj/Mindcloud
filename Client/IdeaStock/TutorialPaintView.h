//
//  TutorialPaintView.h
//  Mindcloud
//
//  Created by Ali Fathalian on 12/12/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingTraceContainer.h"

@protocol TutorialPaintViewDelegate <NSObject>

-(void) animationsStoppedAtIndex:(int) index;
-(void) animationsFinished;

@end

@interface TutorialPaintView : UIView

//order index of the drawing to stop animating for
@property (nonatomic, assign) int stopPoint;
@property (nonatomic, weak) id<TutorialPaintViewDelegate> delegate;

-(id) initWithContainer:(DrawingTraceContainer *) container;

-(void) startDrawing;

@end
