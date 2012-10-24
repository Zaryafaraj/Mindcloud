//
//  AccountsAction.m
//  IdeaStock
//
//  Created by Ali Fathalian on 10/19/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "AccountsAction.h"

@interface AccountsAction()

//I wish objective C was a better language so that I could treat callbacks
//as first class
@property (atomic, strong) NSMutableURLRequest * request;
@property (nonatomic, strong) get_collections_callback getCallback;

@end

@implementation AccountsAction

@synthesize request = _request;
@synthesize getCallback = _getCallback;

-(id) initWithUserID:(NSString *)userID
         andCallback:(get_collections_callback)callback
{
    self = [super init];
    NSString * resourcePath = [NSString stringWithFormat:@"%@/Collections", userID];
    NSURL * url = [NSURL URLWithString:
                   [self.baseURL stringByAppendingString:resourcePath]];
    NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:url
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
    self.request = theRequest;
    self.getCallback = callback;
    return self;
}

#define COLLECTION_KEY @"Collections"
-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    [super connectionDidFinishLoading:connection];
    NSDictionary * result = self.getDataAsDictionary;
    NSArray * resultArray = result[COLLECTION_KEY];
    self.getCallback(resultArray);
}

@end
