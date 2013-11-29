//
//  SendMessageAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface SendMessageAction : MindcloudBaseAction

typedef void (^message_sent_callback)(BOOL);

@property (nonatomic, strong) message_sent_callback postCallback;

-(id) initWithUserId:(NSString *) userId
   andCollectionName:(NSString *) collectionName
    andSharingSecret:(NSString *) sharingSecret
  andSharingSpaceURL:(NSString *) url
          andMessage:(NSString *) message
        andMessageId:(NSString *) messageId;
@end
