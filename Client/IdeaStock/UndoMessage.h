//
//  UndoMessage.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "PeerMessage.h"

@interface UndoMessage : PeerMessage

@property (nonatomic, strong, readonly) NSArray * orderIndices;

/*!
 orderIndexes is a NSArray of NSNumbers containing NSIntegers 
 for the indexes that should be undone
 */
-(instancetype) initWithMessageId:(NSString *)messageId
                  andOrderIndices:(NSArray *) orderIndexes;


@end
