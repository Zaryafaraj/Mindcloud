//
//  PreviewImageAction.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/10/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "PreviewImageAction.h"
#import "HTTPHelper.h"

@implementation PreviewImageAction

-(id) initWithUserID:(NSString *)userID
       andCollection:(NSString *)collectionsName
{
    self = [super init];
    NSString * resourcePath = [NSString
                               stringWithFormat:@"%@/Collections/%@/Thumbnail", userID, collectionsName];
    resourcePath = [resourcePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:
                   [self.baseURL stringByAppendingString:resourcePath]];
    NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:url
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
    self.request = theRequest;
    return self;
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    [super connectionDidFinishLoading:connection];
    if (self.getCallback != nil)
    {
        self.getCallback(self.receivedData);
    }
    else if (self.postCallback != nil)
    {
        self.postCallback();
    }
}

-(void) executePOST
{
    [self.request setHTTPMethod:@"POST"];
    self.request = [HTTPHelper addPostFile:self.previewData
                                  withName:@"thumbnail.jpg"
                                 andParams:nil
                                        to:self.request];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    if (!theConnection)
    {
        NSLog(@"Failed to connect to %@", self.request.URL);
    }
}
@end
