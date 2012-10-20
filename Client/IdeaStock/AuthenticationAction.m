//
//  AuthenticationAction.m
//  IdeaStock
//
//  Created by Ali Fathalian on 9/22/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "AuthenticationAction.h"

@interface AuthenticationAction()

@property (nonatomic,strong) authentication_callback callback;

@end

@implementation AuthenticationAction

@synthesize callback = _callback;

-(id) initWithUserId: (NSString *) userID andCallback: (authentication_callback) callback
{
    self = [super init];
    
    NSURL * url = [NSURL URLWithString:
                   [[self.baseURL stringByAppendingString:@"Authorize/" ] stringByAppendingString:userID]];
    // Create the request.
    NSMutableURLRequest * theRequest=[NSMutableURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    super.request = theRequest;
    self.callback = callback;
    return self;
}

-(void) executePOST
{
    [self.request setHTTPMethod:@"POST"];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    if (!theConnection)
    {
        NSLog(@"Failed to connect to %@", self.request.URL);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [super connectionDidFinishLoading:connection];
    NSDictionary * result =  self.getDataAsDictionary;
    if (result)
    {
        self.callback(result);
    }
    
}


@end
