//
//  AccountsAction.m
//  IdeaStock
//
//  Created by Ali Fathalian on 10/19/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "AccountsAction.h"
#import "HTTPHelper.h"
#import "XoomlParser.h"
#import "MindcloudBaseAction.h"

@interface AccountsAction()

//I wish objective C was a better language so that I could treat callbacks
//as first class
@property (atomic, strong) NSMutableURLRequest * request;

@end

@implementation AccountsAction

-(id) initWithUserID:(NSString *)userID
{
    self = [super init];
    NSString * resourcePath = [NSString stringWithFormat:@"%@/Collections", userID];
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
        NSArray * resultArray = result[COLLECTION_KEY];
        self.getCallback(resultArray);
    }
    else if ([self.request.HTTPMethod isEqualToString:@"POST"])
    {
        if ([result[STATUS_KEY] isEqualToString:@"200"])
        {
            self.postCallback();
        }
    }
    else if ([self.request.HTTPMethod isEqualToString:@"DELETE"])
    {
        if ([result[STATUS_KEY] isEqualToString:@"200"])
        {
            self.deleteCallback();
        }
    }
}

-(void) executePOST
{
    [self.request setHTTPMethod:@"POST"];
    NSData * postFile = [XoomlParser getEmptyBulletinBoardXooml];
    self.request = [HTTPHelper addPostFile:postFile
                                  withName:@"xooml.xml"
                                 andParams: self.postArguments
                                        to:self.request];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    if (!theConnection)
    {
        NSLog(@"Failed to connect to %@", self.request.URL);
    }
}



@end
