//
//  CollectionAssetAction.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/3/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionAssetAction.h"
#import "HTTPHelper.h"

@interface CollectionAssetAction()

@property (nonatomic, strong) NSString * fileName;

@end
@implementation CollectionAssetAction

-(id) initWithUserId:(NSString *) userId
       andCollection:(NSString *) collectionName
         andFileName:(NSString *) fileName
{
    self = [super init];
    if (self)
    {
        self.fileName = fileName;
        NSString * resourcePath = [NSString
                                   stringWithFormat:@"%@/Collections/%@/Files", userId, collectionName];
        resourcePath = [resourcePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL * url = [NSURL URLWithString:
                       [self.baseURL stringByAppendingString:resourcePath]];
        NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:url
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:60.0];
        self.request = theRequest;
    }
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
        else
        {
            self.getCallback(self.receivedData);
        }
    }
    else if ([self.request.HTTPMethod isEqualToString:@"POST"])
    {
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status %d", self.lastStatusCode);
            self.postCallback(NO);
        }
        else
        {
            self.postCallback(YES);
        }
    }
    else if ([self.request.HTTPMethod isEqualToString:@"DELETE"])
    {
        
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status %d", self.lastStatusCode);
            self.deleteCallback(NO);
        }
        else
        {
            self.deleteCallback(YES);
        }
    }
}

-(void) executeGET
{
    self.request.URL = [self.request.URL URLByAppendingPathComponent:self.fileName];
    [super executeGET];
}

-(void) executePOST
{
    
    self.request.HTTPMethod = @"POST";
    NSDictionary * params ;
    if (self.sharingSecret)
    {
        
        params = @{@"fileName" : self.fileName,
                   @"sharing_secret" : self.sharingSecret};
    }
    else
    {
        
        params = @{@"fileName" : self.fileName};
    }
    self.request = [HTTPHelper addPostFile:self.postData
                                  withName: self.fileName
                                 andParams:params
                                        to:self.request];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:self.request
                                                                     delegate:self];
    if (!theConnection)
    {
        NSLog(@"Failed to connect to %@", self.request.URL);
    }
}

-(void) executeDELETE
{
    self.request.URL = [self.request.URL URLByAppendingPathComponent:self.fileName];
    [super executeDELETE];
}

@end
