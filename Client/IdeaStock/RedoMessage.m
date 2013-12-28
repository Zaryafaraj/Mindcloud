//
//  RedoMessage.m
//  Mindcloud
//
//  Created by Ali Fathalian on 12/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "RedoMessage.h"

@interface RedoMessage()

@property (nonatomic, strong) NSArray * orderIndices;

@end
@implementation RedoMessage

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
    NSString * msg =  @"{\"action\":\"redo\",\"orderIndexes\":[";
    for (int i = 0; i< self.orderIndices.count; i++)
    {
        NSNumber * number = self.orderIndices[i];
        
        NSString * numberMsg = [NSString stringWithFormat:@"\"%@\"", number.stringValue];
        msg = [msg stringByAppendingString:numberMsg];
        
        if (i != self.orderIndices.count - 1)
        {
            msg = [msg stringByAppendingString:@","];
        }
        
    }
    msg = [msg stringByAppendingString:@"]}"];
    return msg;
}

@end
