//
//  TempImageAction.m
//  Mindcloud
//
//  Created by Ali Fathalian on 3/2/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "TempImageAction.h"

@implementation TempImageAction

-(id) initWithUserId:(NSString *) userId
       andCollection:(NSString *) collectionName
             andSubCollection:(NSString *) subCollectionName
       andTempSecret:(NSString *) imgSecret
              andURL:(NSString *) baseURL
    andSharingSecret:(NSString *) sharingSecret
{
    self = [super init];
    NSString * resourcePath = [NSString stringWithFormat:@"/SharingSpace/%@/%@/%@/%@/%@", sharingSecret,userId, collectionName, subCollectionName, imgSecret];
    resourcePath = [resourcePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:[baseURL stringByAppendingString:resourcePath]];
    NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:url
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
    self.request = theRequest;
    return self;
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    [super connectionDidFinishLoading:connection];
    
    if ([self.request.HTTPMethod isEqualToString:@"GET"])
    {
        
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status %d", self.lastStatusCode);
            self.getCallback(nil);
            return;
        }
        
        self.getCallback(self.receivedData);
    }
}
@end
