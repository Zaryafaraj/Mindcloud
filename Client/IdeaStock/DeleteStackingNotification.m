//
//  DeleteStackingNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "DeleteStackingNotification.h"

@interface DeleteStackingNotification()

@property (atomic, strong) NSString * stackingId;

@end
@implementation DeleteStackingNotification

-(id) initWithStackingId:(NSString *)stackingId
{
    self = [super init];
    self.stackingId = stackingId;
    return self;
}

-(NSString *) getStackingId
{
    return self.stackingId;
}
@end
