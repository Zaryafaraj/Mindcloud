//
//  SubscriptionAction.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/24/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "SubscriptionAction.h"
#import "HTTPHelper.h"
@interface SubscriptionAction()
@property (nonatomic, strong) NSString * sharingSecret;
@end
@implementation SubscriptionAction

-(id) initWithUserId:(NSString *)userId
    andSharingSecret:(NSString *)sharingSecret
{
    self = [super init];
    NSString * resourcePath = [NSString stringWithFormat:@"%@/Collections/ShareSpaces/Subscribe", userId];
    resourcePath = [resourcePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * url = [NSURL URLWithString:[self.baseURL stringByAppendingString:resourcePath]];
    
    NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:url
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
    
    self.request = theRequest;
    self.sharingSecret = sharingSecret;
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
            return;
        }
        
        NSDictionary * result = self.getDataAsDictionary;
        NSString * collectionName = result[@"collection_name"];
        self.postCallback(collectionName);
    }
}

-(void) executePOST
{
    [self.request setHTTPMethod:@"POST"];
    
    self.request = [HTTPHelper addPostParams:@{@"sharing_secret": self.sharingSecret}
                                          to:self.request];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:self.request
                                                                   delegate:self];
    if (!theConnection)
    {
        NSLog(@"Failed to connect to %@", self.request.URL);
    }
}
@end
