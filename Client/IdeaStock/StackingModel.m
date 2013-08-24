//
//  StackingModel.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "StackingModel.h"

@implementation StackingModel

-(id) initWithName:(NSString *)name andScale:(NSString *)scale andRefIds:(NSSet *)refIds
{
    self = [super init];
    _refIds = [refIds copy];
    _name = name;
    _scale = scale;
    return self;
}

-(void) addNotes:(NSSet *) notes
{
    NSMutableSet * newRefs = [NSMutableSet set];
    for(NSString * note in notes)
    {
        [newRefs addObject:note];
    }
    for(NSString * note in _refIds)
    {
        [newRefs addObject:note];
    }
    
    _refIds = newRefs;
}

-(void) deleteNotes:(NSSet *) notes
{
    NSMutableArray * newRefs = [NSMutableSet set];
    for (NSString * note in _refIds)
    {
        if (![notes containsObject:note])
        {
            [newRefs addObject:note];
        }
    }
    _refIds = [newRefs copy];
}

@end
