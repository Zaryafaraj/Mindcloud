//
//  PeerMessage.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeerMessage : NSObject

-(instancetype) initWithMessageId:(NSString *) messageId;

@property (nonatomic, strong, readonly) NSString * messageId;

-(NSString *) messageString;
@end
