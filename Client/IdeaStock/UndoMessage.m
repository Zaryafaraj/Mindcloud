//
//  UndoMessage.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "UndoMessage.h"

@interface UndoMessage()

@property (nonatomic, strong) NSArray * orderIndices;

@end

@implementation UndoMessage

-(instancetype) initWithMessageId:(NSString *)messageId
                  andOrderIndices:(NSArray *) orderIndexes
{
    self = [super initWithMessageId:messageId];
    if (self)
    {
        self.orderIndices = orderIndexes;
    }
    return self;
}

-(NSString *) messageString
{
    NSString * msg =  @"{'action':'undo','orderIndexes:{";
    for (int i = 0; i< self.orderIndices.count; i++)
    {
        NSNumber * number = self.orderIndices[i];
        msg = [msg stringByAppendingString:number.stringValue];
        if (i != self.orderIndices.count - 1)
        {
            msg = [msg stringByAppendingString:@","];
        }
        
    }
    msg = [msg stringByAppendingString:@"}}"];
    return msg;
}

@end
