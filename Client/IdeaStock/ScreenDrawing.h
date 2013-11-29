//
//  ScreenDrawing.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/1/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiffableSerializableObject.h"

@interface ScreenDrawing : NSObject <DiffableSerializableObject, NSCoding>

/*! gridDictionary is a dictionary keyed on grid index.
    the values are another set of dictionaries keyed on order index
    the values of that are NSSets that contain all the drawings for that
    orderIndex. 
    UndidIndexes is a set of NSSNumbers which contains the indexes of 
    the views who have been undone
 */
-(instancetype) initWithGridDictionary:(NSDictionary *) gridDictionary
                       andUndidIndexes:(NSSet *) undidIndexes;

/*! returns a dictionary keyed on orderIndex and valued on NSSet of all the 
    drawings in that index. 
    returns nil if non exists
 */
-(NSDictionary *) getDrawingsForGridIndex: (int) i ;

/*! returns an array of NSNumbers that contain ints of the grid index
    for which This ScreenDrawing has information about
 */
-(NSArray *) getAvailableGridIndices;

-(BOOL) hasAnyThingToSave;

-(BOOL) hasDiffToSend;

@end
