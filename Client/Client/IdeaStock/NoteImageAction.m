//
//  NoteImageAction.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/10/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "NoteImageAction.h"
#import "HTTPHelper.h"

@implementation NoteImageAction

-(id) initWithUserId: (NSString *) userID
       andCollection: (NSString *) collectionName
             andNote: (NSString *) noteName
{
    self = [super init];
    NSString * resourcePath = [NSString stringWithFormat:@"%@/Collections/%@/Notes/%@/Image", userID, collectionName, noteName];
    
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
                                  withName:@"note.jpg"
                                 andParams:@{}
                                        to:self.request];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:self.request
                                                                     delegate:self];
    if (!theConnection)
    {
        NSLog(@"Failed to connect to %@", self.request.URL);
    }
}
@end