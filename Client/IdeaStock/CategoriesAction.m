//
//  CategoriesAction.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/10/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CategoriesAction.h"
#import "HTTPHelper.h"

@interface CategoriesAction()

@property (atomic, strong) NSMutableURLRequest * request;

@end

@implementation CategoriesAction

-(id) initWithUserID:(NSString *)userID
{
    self = [super init];
    NSString * resourcePath = [NSString stringWithFormat:@"%@/Categories", userID];
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
        
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status %d", self.lastStatusCode);
            self.getCallback(nil);
            return;
        }
        else
        {
            self.getCallback(self.receivedData);
        }
    }
    else if (self.postCallback != nil)
    {
        
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status %d", self.lastStatusCode);
            self.postCallback();
            return;
        }
        else
        {
            self.postCallback();
        }
    }
}

-(void) executePOST
{
    [self.request setHTTPMethod:@"POST"];
    self.request = [HTTPHelper addPostFile:self.categoriesData
                                  withName:@"categories.xml"
                                 andParams:nil
                                        to:self.request];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    if (!theConnection)
    {
        NSLog(@"Failed to connect to %@", self.request.URL);
    }
}
@end
