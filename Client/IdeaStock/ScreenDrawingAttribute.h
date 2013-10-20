//
//  ScreenDrawingAttribute.h
//  Mindcloud
//
//  Created by Ali Fathalian on 10/19/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlNamespaceElement.h"

@interface ScreenDrawingAttribute : NSObject

-(void) addTouchedDrawingTileWithIndex:(NSInteger) index;

-(XoomlNamespaceElement *) toXoomlNamespaceElement;

-(void) applyTilesInTheXoomlNamespaceElement:(XoomlNamespaceElement *) namespaceElement;

@end
