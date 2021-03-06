//
//  ScreenDrawing.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/1/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "ScreenDrawing.h"


@interface ScreenDrawing ()

/*! grid traces is a dictionary keyed on grid index. 
    the values are another set of dictionaries keyed on order index
    the values of that are NSSets that contain all the drawings for that
    orderIndex
 */
@property (nonatomic, strong) NSDictionary * gridTraces;
/*! NSSet of NSNumbers indicating the index of views that have their items
    undone. So we know to communicate them even if they are empty
 */
@property (nonatomic, strong) NSSet * undidIndexes;

@end

@implementation ScreenDrawing


-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.gridTraces forKey:@"gridTraces"];
}

-(id) initWithCoder:(NSCoder *) coder
{
    self = [super init];
    if (self)
    {
        self.gridTraces = [coder decodeObjectForKey:@"gridTraces"];
        self.undidIndexes = [NSSet set];
        self.hasClear = NO;
    }
    return self;
}

-(instancetype) initWithGridDictionary:(NSDictionary *) gridDictionary
                       andUndidIndexes:(NSSet *) undidIndexes;
{
    self = [super init];
    if (self)
    {
        self.gridTraces = gridDictionary;
        self.undidIndexes = undidIndexes;
    }
    return self;
}

#pragma mark - diffable serializable object

-(BOOL) serializeToFile:(NSString *) filePath
{
    return [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

-(NSData *) serializeToData
{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

+(instancetype) deserializeFromData:(NSData *) data
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}


-(NSString *) description
{
    return [NSString stringWithFormat:@"%d grid cells", self.gridTraces.count];
}

-(NSString *) debugDescription
{
    NSString * result = [self description];
    NSString * viewsWithContent = @"Views With Content: \n";
    for(NSNumber * index in self.gridTraces)
    {
        NSDictionary * tracesInTheGrid = self.gridTraces[index];
        if (tracesInTheGrid.count > 0)
        {
            viewsWithContent = [NSString stringWithFormat:@"%@ == %@", viewsWithContent, tracesInTheGrid];
        }
    }
    return [NSString stringWithFormat:@"%@ \n === %@", result, viewsWithContent];
}


-(NSDictionary *) getDrawingsForGridIndex: (int) i
{
    NSNumber * indexObj = [NSNumber numberWithInt:i];
    if (self.gridTraces[indexObj])
    {
        return self.gridTraces[indexObj];
    }
    else
    {
        return nil;
    }
}

-(NSArray *) getAvailableGridIndices
{
    return self.gridTraces.allKeys;
}

-(BOOL) hasAnyThingToSave
{
    if (self.hasClear) return YES;
    
    for(NSNumber * index in self.gridTraces)
    {
        NSDictionary * tracesInTheGrid = self.gridTraces[index];
        if ([self.undidIndexes containsObject:index] || tracesInTheGrid.count > 0)
        {
            return YES;
        }
    }
    return NO;
}

-(BOOL) hasDiffToSend
{
    for(NSNumber * index in self.gridTraces)
    {
        NSDictionary * tracesInTheGrid = self.gridTraces[index];
        if (tracesInTheGrid.count > 0)
        {
            return YES;
        }
    }
    return NO;
}
@end
