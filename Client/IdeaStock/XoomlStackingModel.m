//
//  StackingModel.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "XoomlStackingModel.h"

@implementation XoomlStackingModel

-(id) initWithName:(NSString *)name andScale:(NSString *)scale andRefIds:(NSArray *)refIds
{
    self = [super init];
    _refIds = [refIds copy];
    _name = name;
    _scale = scale;
    return self;
}

@end
