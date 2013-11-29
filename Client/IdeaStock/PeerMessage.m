//
//  PeerMessage.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "PeerMessage.h"

@interface PeerMessage()

@property (nonatomic, strong) NSString * messageId;

@end

@implementation PeerMessage

-(instancetype) initWithMessageId:(NSString *) messageId
{
    self = [super init];
    if (self)
    {
        self.messageId = messageId;
    }
    return self;
}

-(NSString *) messageString
{
    return @"";
}

@end
