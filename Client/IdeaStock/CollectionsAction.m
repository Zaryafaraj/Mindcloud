//
//  AccountsAction.m
//  IdeaStock
//
//  Created by Ali Fathalian on 10/19/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CollectionsAction.h"
#import "HTTPHelper.h"
#import "XoomlManifestParser.h"
#import "MindcloudBaseAction.h"

@interface CollectionsAction()

//I wish objective C was a better language so that I could treat callbacks
//as first class
@property (atomic, strong) NSMutableURLRequest * request;

@end

@implementation CollectionsAction

-(id) initWithUserID:(NSString *)userID
{
    self = [super init];
    NSString * resourcePath = [NSString stringWithFormat:@"%@/Collections", userID];
    resourcePath = [resourcePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * url = [NSURL URLWithString:
                   [self.baseURL stringByAppendingString:resourcePath]];
    
    NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:url
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
    self.request = theRequest;
    return self;
}

#define COLLECTION_KEY @"Collections"
-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    [super connectionDidFinishLoading:connection];
    NSDictionary * result = self.getDataAsDictionary;
    if ([self.request.HTTPMethod isEqualToString:@"GET"])
    {
        
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status %d", self.lastStatusCode);
            self.getCallback(nil);
            return;
        }
        
        NSArray * resultArray = result[COLLECTION_KEY];
        self.getCallback(resultArray);
    }
    else if ([self.request.HTTPMethod isEqualToString:@"POST"])
    {
        
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status %d", self.lastStatusCode);
            self.postCallback();
            return;
        }
        
        if ([result[STATUS_KEY] isEqualToString:@"200"])
        {
            self.postCallback();
        }
    }
}

-(void) executePOST
{
    [self.request setHTTPMethod:@"POST"];
    NSData * postFile = [XoomlManifestParser getEmptyBulletinBoardXooml];
    self.request = [HTTPHelper addPostFile:postFile
                                  withName:@"collection.xml"
                                 andParams:self.postArguments
                                        to:self.request];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    if (!theConnection)
    {
        NSLog(@"Failed to connect to %@", self.request.URL);
    }
}


@end
