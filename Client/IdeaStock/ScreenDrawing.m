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

-(void) serializeToFile:(NSString *) filename
{
    
}
-(void) deserializeFromFile:(NSString *) filename
{
    
}

-(void) serializeDiffToFile:(NSString *) filename
{
    
}

-(void) deserializeDiffFromFile:(NSString *) filename
{
    
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"%d grid cells", self.gridTraces.count];
}

-(NSString *) debugDescription
{
    NSString * result = [self description];
    return [NSString stringWithFormat:@"%@ \n === %@", result, self.gridTraces];
}
@end
