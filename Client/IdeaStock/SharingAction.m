//
//  SharingAction.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/23/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "SharingAction.h"
#import "HTTPHelper.h"

@implementation SharingAction

-(id) initWithUserId:(NSString *)userId
   andCollectionName:(NSString *)collectionName
{
    self = [super init];
    NSString * resourcePath = [NSString stringWithFormat:@"%@/Collections/%@/Share", userId, collectionName];
    
    resourcePath = [resourcePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * url = [NSURL URLWithString:[self.baseURL stringByAppendingString:resourcePath]];
    
    NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:url
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
    
    self.request = theRequest;
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
            self.postCallback(nil);
            return;
        }
        
        NSDictionary * result = self.getDataAsDictionary;
        NSString * sharingSecret = result[@"sharing_secret"];
        self.postCallback(sharingSecret);
    }
    
    if ([self.request.HTTPMethod isEqualToString:@"DELETE"])
    {
        
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status %d", self.lastStatusCode);
        }
        self.deleteCallback();
    }
    
    if ([self.request.HTTPMethod isEqualToString:@"GET"])
    {
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            self.getCallback(nil);
        }
        NSDictionary * result = self.getDataAsDictionary;
        self.getCallback(result);
    }
}

-(void) executePOST
{
    [self.request setHTTPMethod:@"POST"];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:self.request
                                                                   delegate:self];
    if (!theConnection)
    {
        NSLog(@"Failed to connect to %@", self.request.URL);
    }
}

@end
