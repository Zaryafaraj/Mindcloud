//
//  Mindcloud
//
//  Created by Ali Fathalian on 1/10/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionSubCollectionsAction.h"
#import "HTTPHelper.h"

@implementation CollectionSubCollectionsAction

-(id) initWithUserID:(NSString *)userID
   andCollectionName:(NSString *)collectionName
{
    self = [super init];
    NSString * resourcePath = [NSString stringWithFormat:@"%@/Collections/%@/Notes", userID, collectionName];
    resourcePath = [resourcePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * url = [NSURL URLWithString:
                   [self.baseURL stringByAppendingString:resourcePath]];
    
    NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:url
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
    self.request = theRequest;
    return self;
}

#define NOTES_KET @"Notes"
-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    [super connectionDidFinishLoading:connection];
    NSDictionary *  result = self.getDataAsDictionary;
    
    if ([self.request.HTTPMethod isEqualToString:@"GET"])
    {
        
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status %d", self.lastStatusCode);
            self.getCallback(nil);
            return;
        }
        
        NSArray * resultArray = result[NOTES_KET];
        self.getCallback(resultArray);
    }
    else if ([self.request.HTTPMethod isEqualToString:@"POST"])
    {
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status %d", self.lastStatusCode);
        }
        self.postCallback();
    }
}

-(void) executePOST
{
    [self.request setHTTPMethod:@"POST"];
    self.request = [HTTPHelper addPostFile:self.postData
                                  withName:@"note.xml"
                                 andParams:self.postArguments
                                        to:self.request];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    if (!theConnection)
    {
        NSLog(@"Failed to connect to %@", self.request.URL);
    }
}
@end
