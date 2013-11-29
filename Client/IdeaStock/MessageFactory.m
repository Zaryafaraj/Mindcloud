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

+(ClearMessage *) clearMessage
{
    NSString * msgId = [AttributeHelper generateUUID];
    return [[ClearMessage alloc] initWithMessageId:msgId];
}

@end
