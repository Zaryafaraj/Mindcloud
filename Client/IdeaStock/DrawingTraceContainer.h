//
//  DrawingTraceContainer.h
//  Mindcloud
//
//  Created by Ali Fathalian on 10/19/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrawingTrace.h"
@interface DrawingTraceContainer : NSObject <NSCoding>

-(void) addDrawingTrace:(DrawingTrace *) trace
          forOrderIndex:(NSInteger) index;

-(void) removeDrawingTracesAtOrderIndex:(NSInteger) index;

-(void) clearAllTraces;

-(NSArray *) getAllTracers;

-(void) applyBaseContainer:(DrawingTraceContainer *) base;

-(NSDictionary *) getNewTraces;

/*! keyed on orderIndex and valued on drawing trace set */
-(NSDictionary *) getAllTracesDictionary;

-(void) rebaseTraces;

/*! dictionary keyed on orderIndex and valued on a set of drawingTraces */
-(void) setAllDrawingsTo: (NSDictionary *) drawings;
-(void) applyDiffDrawingsFrom:(NSDictionary *) drawings;

-(int) getMaxOrderIndex;

@end
