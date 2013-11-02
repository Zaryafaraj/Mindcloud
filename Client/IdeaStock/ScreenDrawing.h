//
//  ScreenDrawing.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/1/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiffableSerializableObject.h"

@interface ScreenDrawing : NSObject <DiffableSerializableObject>

/*! gridDictionary is a dictionary keyed on grid index.
    the values are another set of dictionaries keyed on order index
    the values of that are NSSets that contain all the drawings for that
    orderIndex
 */
-(instancetype) initWithGridDictionary:(NSDictionary *) gridDictionary;

@end
