//
//  MessageFactory.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MessageFactory.h"
#import "AttributeHelper.h"


@implementation MessageFactory

/*! orderIndexes is an NSArray of NSNumber of NSIntegers that contains
    undo order index to perform */
+(UndoMessage *) undoMessageWithOrderIndices:(NSArray *) orderIndexes
{
    
    NSString * msgId = [AttributeHelper generateUUID];
    return [[UndoMessage alloc] initWithMessageId:msgId
                                  andOrderIndices:orderIndexes];
}

+(RedoMessage *) redoMessageWithOrderIndices:(NSArray *) orderIndexes
{
    NSString * msgId = [AttributeHelper generateUUID];
    return [[RedoMessage alloc] initWithMessageId:msgId
                                  andOrderIndices:orderIndexes];
}

+(ClearMessage *) clearMessage
{
    NSString * msgId = [AttributeHelper generateUUID];
    return [[ClearMessage alloc] initWithMessageId:msgId];
}

+(PeerMessage *) messageFromString:(NSString *) message
                     withMessageId:(NSString *) messageId
{
    
    NSError * err = nil;
    NSData * msgData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:msgData
                                         options:NSJSONReadingAllowFragments
                                           error:&err];
    if (err != nil)
    {
        NSLog(@"MessageFactory - Invalid Message. error %@", err);
    }
    NSString * msgType = result[@"action"];
    if (msgType != nil)
    {
        if ([msgType isEqualToString:@"undo"])
        {
            NSArray * orderIndexes = result[@"orderIndexes"];
            if (orderIndexes != nil)
            {
                return [[UndoMessage alloc] initWithMessageId:messageId
                                              andOrderIndices:orderIndexes];
            }
        }
        if([msgType isEqualToString:@"clear"])
        {
            return [[ClearMessage alloc] initWithMessageId:messageId];
        }
    }
    return nil;
}

@end
