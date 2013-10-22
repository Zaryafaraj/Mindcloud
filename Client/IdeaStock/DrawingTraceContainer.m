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
@property (atomic ,strong) NSArray * baseDrawings;

@end

@implementation DrawingTraceContainer

-(instancetype) init
{
    self = [super init];
    if (self)
    {
        self.drawings = [NSMutableDictionary dictionary];
        self.baseDrawings = [NSMutableArray array];
    }
    return self;
}

-(void) applyBaseContainer:(DrawingTraceContainer *) base
{
    self.baseDrawings = [base getAllTracers];
}

-(void) addDrawingTrace:(DrawingTrace *)trace
          forOrderIndex:(NSInteger)index
{
    NSNumber * indexObj = [NSNumber numberWithInteger:index];
    
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
    NSNumber * indexObj = [NSNumber numberWithInteger:index];
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
    //first add the base
    [result addObjectsFromArray:self.baseDrawings];
    NSMutableArray * allKeys = [self.drawings.allKeys mutableCopy];
    NSSortDescriptor * lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [allKeys sortUsingDescriptors:@[lowestToHighest]];
    for (NSNumber * number in allKeys)
    {
        NSSet * drawingSet = self.drawings[number];
        [result addObjectsFromArray:drawingSet.allObjects];
    }
    return result;
}


@end
