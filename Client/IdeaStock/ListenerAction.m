//
//  ListenerAction.m
//  Mindcloud
//
//  Created by Ali Fathalian on 3/2/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "ListenerAction.h"
#import "EventTypes.h"

@interface ListenerAction()
@property (strong, nonatomic) NSString *collectionName;
@property (strong, nonatomic) NSString * userId;
@property (strong, nonatomic) NSString * sharingSecret;
@end
@implementation ListenerAction

-(id) initWithUserId:(NSString *)userId
   andCollectionName:(NSString *)collectionName
    andSharingSecret:(NSString *)sharingSecret
  andSharingSpaceURL:(NSString *)baseUrl
{
    self = [super init];
    self.collectionName = collectionName;
    self.sharingSecret = sharingSecret;
    self.userId = userId;
    NSString * resourcePath = [NSString stringWithFormat:@"/SharingSpace/%@/Listen/%@", sharingSecret, userId];
    resourcePath = [resourcePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (baseUrl==nil) return  self;
    NSURL * url = [NSURL URLWithString:[baseUrl stringByAppendingString:resourcePath]];
    
    //one hour
    NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:url
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:3600];
    self.request = theRequest;
    return self;
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //in case of a timeout retry
    NSError * err = error.userInfo[@"NSUnderlyingError"];
    //server must have been down. Try to get new server info
    NSLog(@"Received Error code when establishing listener to %@ %@", self.request.URL, err);
    if (err.code == -1004)
    {
        NSDictionary * userInfo = @{@"result" :
  @{@"user" : self.userId,
    @"collectionName" : self.collectionName,
    @"sharingSecret" : self.sharingSecret
    }};
        [[NSNotificationCenter defaultCenter] postNotificationName:CONNECTION_FAILED
                                                            object:self
                                                          userInfo:userInfo];
    }
    if (err.code == -1001)
    {
        if ([self.request.HTTPMethod isEqualToString:@"POST"])
        {
            NSLog(@"Connection timedout; establishing connection again");
            [self executePOST];
        }
    }
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    [super connectionDidFinishLoading:connection];
    
    if ([self.request.HTTPMethod isEqualToString:@"POST"])
    {
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status for listener%d", self.lastStatusCode);
            self.postCallback(nil);
            return;
        }
        
        NSDictionary * result = self.getDataAsDictionary;
        if ([result count] != 0)
        {
            self.postCallback(result);
        }
    }
    
    if ([self.request.HTTPMethod isEqualToString:@"DELETE"])
    {
        
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status %d", self.lastStatusCode);
            
        }
        //no need to call back
//        self.deleteCallback();
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
