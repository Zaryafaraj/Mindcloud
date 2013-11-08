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

@end

@implementation ScreenDrawing


-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.gridTraces forKey:@"gridTraces"];
}

-(instancetype) initWithGridDictionary:(NSDictionary *) gridDictionary
{
    self = [super init];
    if (self)
    {
        self.gridTraces = gridDictionary;
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
-(BOOL) deserializeFromFile:(NSString *) filename
{
    
    return true;
}

-(BOOL) deserializeFromData:(NSData *) data
{
    return YES;
}

-(BOOL) serializeDiffToFile:(NSString *) filename
{
    return true;
}

-(BOOL) deserializeDiffFromData:(NSData *)data
{
    return YES;
}

-(NSData *) serializeDiffToData
{
    return nil;
}

-(BOOL) deserializeDiffFromFile:(NSString *) filename
{
    return true;
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
