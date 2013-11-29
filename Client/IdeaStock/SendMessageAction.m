//
//  SendMessageAction.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "SendMessageAction.h"
#import "HTTPHelper.h"

@implementation SendMessageAction

-(id) initWithUserId:(NSString *) userId
   andCollectionName:(NSString *) collectionName
    andSharingSecret:(NSString *) sharingSecret
  andSharingSpaceURL:(NSString *) url
          andMessage:(NSString *) message
        andMessageId:(NSString *) messageId
{
    
    self = [super init];
    if (self)
    {
        NSString * resourcePath = [NSString stringWithFormat:@"%@/SharingSpace/%@/Message", url, sharingSecret];
        NSURL * url = [NSURL URLWithString:resourcePath];
        NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:url
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:60.0];
        self.request = theRequest;
        self.request.HTTPMethod = @"POST";
        NSDictionary * params = @{@"user_id" : userId,
                                  @"collection_name" : collectionName,
                                  @"msg" : message,
                                  @"msg_id": messageId};
        self.request = [HTTPHelper addPostParams:params
                                              to:self.request];
    }
    return self;
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    [super connectionDidFinishLoading:connection];
    
    if ([self.request.HTTPMethod isEqualToString:@"POST"])
    {
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status %d", self.lastStatusCode);
            self.postCallback(NO);
        }
        else
        {
            self.postCallback(YES);
        }
    }
}
@end
