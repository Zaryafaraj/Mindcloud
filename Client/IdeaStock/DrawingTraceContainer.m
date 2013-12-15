//
//  DrawingTraceContainer.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/19/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "DrawingTraceContainer.h"
#import "FileSystemHelper.h"

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
    
    self.baseDrawings = [aDecoder decodeObjectForKey:@"baseDrawings"];
    
    self.drawings = [aDecoder decodeObjectForKey:@"drawings"];
    
    return self;
}

-(void) setAllDrawingsTo: (NSDictionary *) drawings
{
    [self.baseDrawings removeAllObjects];
    [self.drawings removeAllObjects];
    self.baseDrawings = [drawings mutableCopy];
}

-(void) applyDiffDrawingsFrom:(NSDictionary *) drawings
{
    for(NSNumber * orderIndex in drawings.allKeys)
    {
        if (!self.baseDrawings[orderIndex])
        {
            self.baseDrawings[orderIndex] = drawings[orderIndex];
        }
        else
        {
            NSMutableSet * currentDrawings = self.baseDrawings[orderIndex];
            NSSet * mergingDrawings = drawings[orderIndex];
            [currentDrawings addObjectsFromArray:mergingDrawings.allObjects];
        }
    }
}

-(int) getMaxOrderIndex
{
    int maxOrderIndex = -1;
    for(NSNumber * num in self.drawings.allKeys)
    {
        if (num.intValue > maxOrderIndex)
        {
            maxOrderIndex = num.intValue;
        }
    }
    
    for(NSNumber * num in self.baseDrawings.allKeys)
    {
        if (num.intValue > maxOrderIndex)
        {
            maxOrderIndex = num.intValue;
        }
    }
    
    return maxOrderIndex;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.baseDrawings forKey:@"baseDrawings"];
    [aCoder encodeObject:self.drawings forKey:@"drawings"];
}

-(void) debug_saveContainerToFile
{
    NSString * prefix = [FileSystemHelper getPathForIntroBezierPath];
    NSLog(@"Saved the file to: %@", prefix);
    [NSKeyedArchiver archiveRootObject:self
                                toFile:prefix];
}

+(instancetype) containerWithTheContentsOfTheFile:(NSString *) filename
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
}

@end
