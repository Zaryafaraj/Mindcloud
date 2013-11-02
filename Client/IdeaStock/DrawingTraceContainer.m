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
@property (atomic ,strong) NSMutableDictionary * baseDrawings;

@end

@implementation DrawingTraceContainer

-(instancetype) init
{
    self = [super init];
    if (self)
    {
        self.drawings = [NSMutableDictionary dictionary];
        self.baseDrawings = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) applyBaseContainer:(DrawingTraceContainer *) base
{
    //self.baseDrawings = [base getAllTracers];
}

-(NSDictionary *) getNewTraces
{
    //I hope this is not a deep copy
    //double check
    NSDictionary * result =  [self.drawings copy];
    return result;
}

-(void) rebaseTraces
{
    for(NSNumber * num in self.drawings.allKeys)
    {
        NSSet * traces = self.drawings[num];
        if (self.baseDrawings[num] == nil)
        {
            self.baseDrawings[num] = [NSMutableSet set];
        }
        
        [self.baseDrawings[num] addObjectsFromArray:traces.allObjects];
    }
    
    [self.drawings removeAllObjects];
}

-(void) addDrawingTrace:(DrawingTrace *)trace
          forOrderIndex:(NSInteger)index
{
    NSNumber * indexObj = [NSNumber numberWithInteger:index];
    if ([self.baseDrawings objectForKey:indexObj])
    {
        NSMutableSet * drawings = self.baseDrawings[indexObj];
        [drawings addObject:trace];
    }
    else
    {
        if ([self.drawings objectForKey:indexObj] == nil)
        {
            NSMutableSet * drawingsForIndex = [NSMutableSet set];
            self.drawings[indexObj] = drawingsForIndex;
        }
    
        NSMutableSet * drawings = self.drawings[indexObj];
        [drawings addObject:trace];
    }
}

-(void) removeDrawingTracesAtOrderIndex:(NSInteger)index
{
    NSNumber * indexObj = [NSNumber numberWithInteger:index];
    //ARC will automatically call the dealloc on the drawingTrace objects
    //and release the CGPath
    [self.drawings removeObjectForKey:indexObj];
    [self.baseDrawings removeObjectForKey:indexObj];
}

-(void) clearAllTraces
{
    [self.drawings removeAllObjects];
    [self.baseDrawings removeAllObjects];
}

-(NSArray *) getAllTracers
{
    NSMutableArray * result = [NSMutableArray array];
    //first add the base
    [result addObjectsFromArray:[self createSortedArrayFromDictionary:self.baseDrawings]];
    [result addObjectsFromArray:[self createSortedArrayFromDictionary:self.drawings]];
    return result;
}

-(NSDictionary *) getAllTracesDictionary
{
    
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithDictionary:self.baseDrawings];
    for (NSNumber * number in self.drawings.allKeys)
    {
        NSSet * drawingSet = self.drawings[number];
        if (result[number])
        {
            NSMutableSet * pastDrawings = result[number];
            [pastDrawings addObjectsFromArray:drawingSet.allObjects];
        }
        else
        {
            result[number] = drawingSet;
        }
    }
    return result;
}

-(NSArray *) createSortedArrayFromDictionary:(NSDictionary *) dic
{
    NSMutableArray * result = [NSMutableArray array];
    NSMutableArray * allKeys = [dic.allKeys mutableCopy];
    NSSortDescriptor * lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [allKeys sortUsingDescriptors:@[lowestToHighest]];
    for (NSNumber * number in allKeys)
    {
        NSSet * drawingSet = dic[number];
        [result addObjectsFromArray:drawingSet.allObjects];
    }
    return result;
}

#pragma mark - NSCoding

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (!self) return nil;
    
    self.baseDrawings = [aDecoder decodeObjectForKey:@"drawings"];
    
    self.drawings = [NSMutableDictionary dictionary];
    
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    //first transfer everything in drawings to base drawings
//    [self.baseDrawings addObjectsFromArray:self.drawings.allValues];
//    [self.drawings removeAllObjects];
//    
//    [aCoder encodeObject:self.baseDrawings forKey:@"drawings"];
}

@end
