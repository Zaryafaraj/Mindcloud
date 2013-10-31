//
//  BrushColors.h
//  Mindcloud
//
//  Created by Ali Fathalian on 10/30/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrushColors : NSObject

-(int) numberOfColors;

-(UIColor *) colorForIndexPath:(NSIndexPath *) indexPath;

-(NSSet *) getLightColors;

-(NSArray *) getAllColors;

-(NSInteger) defaultColorIndex;

@end
