//
//  MessageFactory.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UndoMessage.h"
#import "ClearMessage.h"
#import "RedoMessage.h"

@interface MessageFactory : NSObject

/*! orderIndexes is an NSArray of NSNumber of NSIntegers that contains
    undo order index to perform */
+(UndoMessage *) undoMessageWithOrderIndices:(NSArray *) orderIndexes;

+(RedoMessage *) redoMessageWithOrderIndices:(NSArray *) orderIndexes;

+(ClearMessage *) clearMessage;

+(PeerMessage *) messageFromString:(NSString *) message
                     withMessageId:(NSString *) messageId;

@end
