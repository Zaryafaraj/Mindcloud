//
//  DrawingTraceContainer.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/19/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "DrawingTraceContainer.h"

@interface DrawingTraceContainer()

//keyed on the order index and valued on a set of all the drawings done in
//that order index
@property (atomic, strong) NSMutableDictionary * drawings;

@end

@implementation DrawingTraceContainer

-(instancetype) init
{
    self = [super init];
    if (self)
    {
        self.drawings = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) addDrawingTrace:(DrawingTrace *)trace
          forOrderIndex:(NSInteger)index
{
    NSValue * indexObj = [NSNumber numberWithInteger:index];
    
   if ([self.drawings objectForKey:indexObj] == nil)
   {
       NSMutableSet * drawingsForIndex = [NSMutableSet set];
       self.drawings[indexObj] = drawingsForIndex;
   }
    
    NSMutableSet * drawings = self.drawings[indexObj];
    [drawings addObject:trace];
}

-(void) removeDrawingTracesAtOrderIndex:(NSInteger)index
{
    NSValue * indexObj = [NSNumber numberWithInteger:index];
    //ARC will automatically call the dealloc on the drawingTrace objects
    //and release the CGPath
    [self.drawings removeObjectForKey:indexObj];
}

-(void) clearAllTraces
{
    [self.drawings removeAllObjects];
}

-(NSArray *) getAllTracers
{
    NSMutableArray * result = [NSMutableArray array];
    for (NSSet * drawingSet in self.drawings.allValues)
    {
        [result addObjectsFromArray:drawingSet.allObjects];
    }
    return result;
}

@end
