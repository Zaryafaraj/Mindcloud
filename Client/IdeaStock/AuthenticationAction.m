//
//  AuthenticationAction.m
//  IdeaStock
//
//  Created by Ali Fathalian on 9/22/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "AuthenticationAction.h"

@interface AuthenticationAction()

@property (atomic,strong) NSMutableURLRequest * request;

@end

@implementation AuthenticationAction

@synthesize request = _request;

-(id) initWithUserId: (NSString *) userID
{
    self = [super init];
    
    NSURL * url = [NSURL URLWithString:
                   [[self.baseURL stringByAppendingString:@"Authorize/" ] stringByAppendingString:userID]];
    // Create the request.
    NSMutableURLRequest * theRequest=[NSMutableURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    self.request = theRequest;
    return self;
}

-(void) execute
{
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    if (!theConnection)
    {
        NSLog(@"Failed to connect to %@", self.request.URL);
    }
}


@end
