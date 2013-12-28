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

-(void) addDrawingTracesFromArray:(NSArray *) drawingTraces
                    forOrderIndex:(NSInteger) index;

-(void) removeDrawingTracesAtOrderIndex:(NSInteger) index;

-(void) clearAllTraces;

/*! The results are sorted based on their order index */
-(NSArray *) getAllTracers;

-(NSArray *) getDrawingTracesAtOrderIndex:(NSInteger) index;

-(void) applyBaseContainer:(DrawingTraceContainer *) base;

-(NSDictionary *) getNewTraces;

/*! keyed on orderIndex and valued on drawing trace set */
-(NSDictionary *) getAllTracesDictionary;

-(void) rebaseTraces;

/*! dictionary keyed on orderIndex and valued on a set of drawingTraces */
-(void) setAllDrawingsTo: (NSDictionary *) drawings;
-(void) applyDiffDrawingsFrom:(NSDictionary *) drawings;

-(int) getMaxOrderIndex;

-(void) debug_saveContainerToFile;

+(instancetype) containerWithTheContentsOfTheFile:(NSString *) filename;

-(instancetype) copy;

@end
